# ImagifyAI – Application Architecture

This document describes the current architecture, Clean Architecture principles adopted, and guidelines for maintaining a clear separation between View and ViewModel layers.

---

## 1. Clean Architecture Overview

The project follows **Clean Architecture** with three main layers:

```
┌─────────────────────────────────────────────────────────────────┐
│  PRESENTATION (view/, viewModel/)                                │
│  • Screens (View layer): UI only, no business logic             │
│  • ViewModels: State + business logic, depend on Domain only     │
└───────────────────────────────┬─────────────────────────────────┘
                                │ depends on
┌───────────────────────────────▼─────────────────────────────────┐
│  DOMAIN (domain/)                                                │
│  • Repository interfaces (contracts)                              │
│  • No dependencies on Data or Presentation                       │
└───────────────────────────────┬─────────────────────────────────┘
                                │ implemented by
┌───────────────────────────────▼─────────────────────────────────┐
│  DATA (repositories/, models/, Core/services)                    │
│  • Repository implementations                                    │
│  • API service, local storage, DTOs (models)                     │
└─────────────────────────────────────────────────────────────────┘
```

- **Presentation** must not import Data layer directly; it depends on **Domain** (repository interfaces). ViewModels receive repository implementations via constructor injection (typed to interfaces).
- **Domain** contains only contracts (abstract repositories); no Flutter or HTTP.
- **Data** implements domain contracts and handles API, persistence, and DTOs.

---

## 2. Folder Structure (Target)

```
lib/
├── core/                    # Shared kernel (theme, constants, routing, utils, shared widgets)
│   ├── constants/
│   ├── custom_widget/
│   ├── services/            # API client, ads, analytics, storage – used by Data layer
│   ├── theme/
│   └── utils/
├── domain/                  # Business rules & contracts
│   └── repositories/       # Abstract repository interfaces (IAuthRepository, IWallpaperRepository)
├── data/                    # Implementation details (optional future: move repos + models here)
│   └── (repositories live in lib/repositories for now; they implement domain interfaces)
├── repositories/            # Repository implementations (implement domain interfaces)
├── models/                  # DTOs / request–response models (shared by Domain & Data)
├── view/                    # Presentation – screens (UI only)
├── viewModel/               # Presentation – state and business logic (depends on domain)
├── main.dart
└── firebase_options.dart
```

- **view/** and **viewModel/** together form the **Presentation** layer.
- **domain/repositories/** holds only abstract classes (interfaces).
- **repositories/** holds concrete implementations that implement domain interfaces.

---

## 3. View vs ViewModel Responsibilities

### View (UI layer)

- **Only** builds UI from state and forwards user actions to the ViewModel.
- **Does not**: call APIs, repositories, or services; perform validation; decide navigation (except executing it when ViewModel requests via callback or return).
- **May**: call `context.read<ViewModel>().method(context)` or use `Consumer` to react to state.
- **Navigation**: Prefer ViewModel returning a result (e.g. “navigate to X”) or calling a callback passed from the View; the View performs `Navigator.pushNamed` etc. so that the View remains the only place that knows about routes.

### ViewModel (Presentation logic)

- Holds **all** UI state and **business logic** for the screen (loading, errors, list data, form state).
- Calls **domain** (repository interfaces) and **core** services (e.g. ads, analytics, limits).
- Exposes state via getters and methods; calls `notifyListeners()` after state changes.
- Does **not** import Flutter widgets or build UI; may use `BuildContext` only for navigation, snackbars, or dialogs when passed from the View.

### State management

- **Provider (ChangeNotifier)** is the single mechanism for screen-level state.
- **Avoid `setState`** for state that affects business logic or is shared; move that state into the ViewModel and use `Consumer` or `context.watch` in the View.
- **setState** is acceptable only for **purely local, ephemeral UI state** (e.g. animation keyframes, focus) that does not need to be tested or reused.

**Remaining setState (intentional):** The only remaining `setState` usages are in `_LoadingOverlay` (used on both Image Generate and Image Created screens). They update `_displayedStage` inside `didUpdateWidget` to drive a fade animation when the loading stage text changes. This is purely presentational animation state and is left in the widget per the guideline above.

---

## 4. Dependency Rule

- **Presentation** (view, viewModel) → may depend on **Domain** and **Core** (theme, utils). ViewModels depend on repository **interfaces** from Domain, not on concrete repositories from Data.
- **Domain** → must not depend on Presentation or Data (only on models/DTOs if they are treated as shared).
- **Data** (repositories, ApiService, etc.) → may depend on Domain (implements interfaces) and Core.

Constructor injection in ViewModels:

```dart
// ViewModel depends on abstraction (domain)
class SignInViewModel extends ChangeNotifier {
  SignInViewModel({IAuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository();
  final IAuthRepository _authRepository;
}
```

---

## 5. Current State vs Target (Summary)

| Area | Current | Target |
|------|--------|--------|
| Repository usage | ViewModels use concrete `AuthRepository` / `WallpaperRepository` | ViewModels use `IAuthRepository` / `IWallpaperRepository` from domain |
| State in Views | setState used for checklist index, contact subject, notifications switch, image error/retry | Move to ViewModels; use Provider; keep only purely presentational setState (e.g. overlay animation) |
| Business logic | Mostly in ViewModels; some navigation and dialogs in View | All business logic in ViewModel; View only renders and dispatches to ViewModel |
| Token refresh | Set in `main.dart` / `my_app.dart` using `AuthRepository` directly | Can stay (app bootstrap) or move to a small Auth/TokenService used by app shell |

---

## 6. Naming and Conventions

- **Repository interfaces**: `IAuthRepository`, `IWallpaperRepository` (or `AuthRepositoryInterface` if you prefer).
- **ViewModels**: One per screen or major flow; suffix `ViewModel`.
- **Views**: Descriptive screen names; no business logic; minimal local state.

---

## 7. Testing (Future)

- With repository interfaces in Domain, ViewModels can be unit-tested by injecting mock implementations of `IAuthRepository` and `IWallpaperRepository` without touching the real API or Flutter.
