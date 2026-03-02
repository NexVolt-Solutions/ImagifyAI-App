# How to Earn Money From ImagifyAI (Play Store App)

Your app is already on the Play Store. Here are practical ways to start earning, from quickest to more advanced.

---

## 1. **Google AdMob (Ads)** — Implemented

The app already uses **Rewarded** and **Interstitial** ads. All AdMob IDs are in **`.env`** and **`android/secrets.properties`** (see [ENV_SETUP.md](ENV_SETUP.md)).

### Current implementation
| Type | Where | When |
|------|--------|------|
| **Rewarded** | Generate screen | "Watch ad for 1 free generation" button; user opts in. |
| **Interstitial** | Full-screen | After user **downloads** an image (natural break). |

### What you need (already done)
- **AdMob account** and app linked.
- **App ID** in `android/secrets.properties` (or `key.properties`) as `ADMOB_APP_ID`; injected into AndroidManifest at build time.
- **Ad unit IDs** in `.env`: `ADMOB_REWARDED_AD_UNIT_ID`, `ADMOB_INTERSTITIAL_AD_UNIT_ID`.

### Adding more ad types (optional)
- **Banner**: Create a Banner ad unit in AdMob, add its ID to `.env`, and show a banner widget at the bottom of a screen (e.g. Home or Generate).

**Earnings**: Roughly **$0.50–5+ per 1000 ad impressions** (varies by country and ad type).

---

## 2. **In‑app purchases (IAP) / Subscriptions** — Best long-term

Users pay you directly. Fits an AI app well: limit free usage, charge for more.

### Options that fit ImagifyAI
- **Subscription (e.g. "ImagifyAI Pro")**
  - Unlimited generations per day.
  - All styles unlocked.
  - No ads (if you also add AdMob).
  - HD/4K download.
  - Price: e.g. $2.99/month or $19.99/year.
- **One-time "Pro" or "Lifetime"**
  - Single payment for permanent unlock (simpler, but no recurring revenue).
- **Credits / packs**
  - Free: 3–5 generations per day.
  - Buy "50 generations" for $1.99, "200" for $4.99, etc.

### What you need
- **Google Play Console**: Turn on **Monetization** → **In-app products** or **Subscriptions**.
- **Merchant account**: Link a Google Play merchant account (same as your developer account) so you can receive payouts.
- **Products**: Create product IDs (e.g. `imagifyai_pro_monthly`, `credits_50`) and set prices.

### Flutter implementation (high level)
1. Add dependency: `in_app_purchase: ^3.2.0` (or latest).
2. Implement:
   - Load products by ID.
   - Purchase flow (buy subscription or consumable).
   - Verify purchase on your backend (recommended) or client-only for MVP.
3. In the app:
   - If user has no subscription/credits → show paywall or "Get Pro" before generating.
   - If user has Pro or credits → allow generation and decrement credits if you use credits.

**Earnings**: You keep **~70%** of the price (Google takes ~30%). Example: 100 users at $2.99/month ≈ **~$210/month** to you (before tax).

---

## 3. **Optimize Play Store listing** — More installs = more revenue

More installs mean more ad views and more potential subscribers.

- **Title**: Include "AI Wallpaper" or "AI Art" (e.g. "ImagifyAI – AI Wallpaper Generator").
- **Short description**: Clear benefit: "Create custom AI wallpapers from text. Many styles, HD download."
- **Screenshots**: Show: prompt → style → result → set as wallpaper.
- **Reviews**: You already have in-app review; keep asking at good moments (e.g. after a few successful generations).
- **Keywords**: Use all 50 characters in the store listing for terms like: wallpaper, AI, generator, art, custom, etc.

---

## 4. **Combine: Ads + optional Pro (recommended)**

- **Free users**: See banners + interstitials (e.g. after some downloads/generations). Optionally: "Watch ad for 1 extra generation."
- **Pro users**: No ads, unlimited (or higher limit) generations, all styles, better quality.
- **Paywall**: Show "Upgrade to Pro" in Profile or after N free generations.

This way you earn from both ads and subscriptions.

---

## 5. **Where the money goes**

- **AdMob**: Paid to your AdMob account → link your **bank account / payment profile** in AdMob (Payments section). Payouts when balance reaches threshold (e.g. $100).
- **In-app purchases**: Paid to your **Google Play Developer** account → same merchant/bank you set in Play Console. Payouts on a schedule (e.g. monthly).

---

## Quick start checklist

- [x] Create AdMob account and add your Android app.
- [x] Add Rewarded + Interstitial in the app with `google_mobile_ads`; IDs in `.env`.
- [ ] In Play Console: set up In-app products or Subscriptions and link merchant account (for Pro/IAP).
- [ ] Add `in_app_purchase` and a simple paywall (e.g. "Pro" or "credits") if desired.
- [ ] Improve store listing (title, description, screenshots, keywords).
- [x] "Watch ad for 1 free generation" (Rewarded) and interstitial after download are implemented.
