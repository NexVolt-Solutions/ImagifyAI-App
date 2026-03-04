# Rewarded Ads Placement – Senior Engineer Analysis

## Current state

- **Single placement:** Rewarded ad appears only on the **Image Generate** screen as an optional “Watch ad for 1 free generation” button below “Create Magic”.
- **Reward is not enforced:** The app has **no generation limit**. Users can generate as many times as they want. `RewardedAdService.getFreeGenerationsFromAds()` and `consumeOneFreeGeneration()` exist but are **never used** in the create/regenerate flow. So “1 free generation” is only a counter that never gates or consumes anything.
- **Create entry points:**
  1. **Image Generate tab** → “Create Magic” → `ImageGenerateViewModel.createWallpaper()` → success → `ImageCreatedScreen`.
  2. **Home** → “Generate Now” → switches to Create tab (same flow).
  3. **Image Created screen** → “Try Again” (Regenerate) → `ImageCreatedViewModel.recreate()`.

## Issues

1. **No limit → reward has no value.** Users can always generate; the “free generation” from the ad doesn’t change behavior.
2. **`consumeOneFreeGeneration()` is never called.** Even if you add a limit later, you must consume the reward when a generation actually happens (after successful create/recreate).
3. **Only one touchpoint.** Regenerate and “at limit” moments are better places for rewarded ads than a standalone button that doesn’t affect flow.

---

## Recommended approach (hybrid)

Introduce a **soft daily limit** (e.g. 5 free generations per day). When the user is **at limit**, offer: *“You’ve reached your daily limit. Watch a short ad for 1 more generation?”* Then show the rewarded ad; on reward, allow one more generation and **consume** it when the create/recreate API **succeeds**.

### 1. Where to place rewarded ads

| Place | When to show | Action on reward |
|-------|----------------|-------------------|
| **Create flow** (Image Generate) | User taps “Create Magic” and is at daily limit (and has no “free from ad” credit). | Show dialog → rewarded ad → on reward grant 1 credit; when `createWallpaper` **succeeds**, call `RewardedAdService.consumeOneFreeGeneration()`. |
| **Regenerate flow** (Image Created) | User taps “Try Again” and is at daily limit (and has no ad credit). | Same: dialog → ad → grant 1 credit; when `recreate` **succeeds**, call `consumeOneFreeGeneration()`. |
| **Optional: Create screen** | Keep a small “Watch ad for +1 free generation” (or “Free generations: X”) that **banks** a credit. | Same credit pool; when user later creates/regenerates, consume. No need to force ad before every create. |

So: **primary placements = gating at “Create Magic” and “Try Again” when at limit**; optional = banking on Create screen.

### 2. Logic to add

- **Limit storage:** e.g. `SharedPreferences`: `generations_used_today`, `last_limit_date`, and continue using `free_generations_from_ads` (from `RewardedAdService`) as the “banked” ad credits.
- **Before create:**  
  - If `generations_used_today < daily_limit` → allow and increment `generations_used_today` when API succeeds.  
  - Else if `getFreeGenerationsFromAds() > 0` → allow and call `consumeOneFreeGeneration()` when API succeeds.  
  - Else → show dialog “Watch ad for 1 more?” → show rewarded ad → on reward increment bank (already done in `RewardedAdService`) → then allow create and consume when API succeeds.
- **Before regenerate:** Same rules as create (check daily count, then ad credits, then offer ad).
- **Reset:** At app open or at start of create flow, if `last_limit_date != today` then reset `generations_used_today` to 0 and set `last_limit_date = today`.

### 3. Code touchpoints

| File | Change |
|------|--------|
| **New (e.g. `lib/Core/services/generation_limit_service.dart`)** | Daily limit + “can generate?” + “record generation” + “has ad credit?”. |
| **`ImageGenerateViewModel.createWallpaper()`** | Before starting create: if at limit and no ad credit, show dialog → show rewarded ad → if not rewarded return. When create **succeeds** (both immediate and after polling), call limit service “record generation” and if this generation used an ad credit call `RewardedAdService.consumeOneFreeGeneration()`. |
| **`ImageCreatedViewModel.recreate()`** | Same: before calling API check limit/ad credit/dialog; when recreate **succeeds**, record generation and optionally consume one ad credit. |
| **`image_generate_screen.dart`** | Replace or complement “Watch ad for 1 free generation” with “Free generations: X” (from `getFreeGenerationsFromAds()`) and/or keep “Watch ad for +1” to bank a credit. When at limit, “Create Magic” can open the “Watch ad for 1 more?” dialog instead of creating. |
| **`image_created_screen.dart`** | “Try Again” tap: if at limit, show same “Watch ad for 1 more?” dialog then proceed on reward. |

### 4. Optional: no limit, only “value‑add” placements

If you prefer **not** to add a daily limit:

- **Regenerate:** Add an explicit “Watch ad to regenerate” step before `recreate()` (e.g. dialog or secondary button). On reward, grant 1 banked credit and consume it when `recreate()` succeeds. So “free generations” only apply to regenerates (or to both create and regenerate if you use the same credit for both).
- **Create screen:** Keep “Watch ad for 1 free generation” as banking a credit; when user taps “Create Magic”, if they have banked credits use one (and consume on success). That way the button has a clear effect without a hard daily cap.

---

## Summary

- **Current:** Rewarded ad is only on the Create screen and the “free generation” is never used or consumed.
- **Recommendation:**  
  1. Add a **generation limit service** (daily limit + ad credit bank).  
  2. **Gate** “Create Magic” and “Try Again” when at limit; offer “Watch ad for 1 more?” and use existing `RewardedAdService`.  
  3. **Consume** the ad reward when the create/recreate API **succeeds** (in both view models).  
  4. Optionally show “Free generations: X” and “Watch ad for +1” on the Create screen so users can bank credits.

This ties rewarded ads to real value (extra generations when at limit) and uses `consumeOneFreeGeneration()` correctly.
