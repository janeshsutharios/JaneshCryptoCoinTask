# Refactoring & Unit Test Summary — CryptoCoin iOS

> **Branch:** `refactor/architecture-and-tests`  
> **Plan:** [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md)

---

## Summary of Changes

### 1. Composition Root & Module Boundaries
- **`Presentation/Package.swift`**: Removed `Data` and `Infrastructure` dependencies so `Presentation` depends only on `Domain` and `Common`. Removed unused `import Data` / `import Infrastructure` from `CoinListViewController.swift`, `NoDataView.swift`, and `LoaderView.swift`.
- **`AppDIContainer.swift` & `SceneDelegate.swift`**: Moved dependency graph construction into `AppDIContainer` and wired `CryptoListViewController` programmatically in `SceneDelegate` (removed `UISceneStoryboardFile` / `INFOPLIST_KEY_UIMainStoryboardFile` from `Info.plist` and `project.pbxproj`).
- **`Common/Utils/Extensions.swift` & `Presentation/.../UIViewController+Alert.swift`**: Moved `UIViewController.showAlert` out of `Common` into `Presentation` to keep `Common` platform-agnostic.

### 2. Presentation, Startup Flow & Search/Filter State
- **`CryptoListViewModel.swift`**:
  - Made `init(getCryptoCoinsUseCase:)` synchronous and side-effect free, depending on `FetchCryptoCoinsUseCaseProtocol`.
  - Stored `searchQuery` and filter selections as ViewModel state and computed `filteredCoins` from all criteria together so search and filters combine cleanly instead of overwriting each other.
  - Handled opposite filter pairs (`Active` + `Inactive`, `Only Coins` + `Only Tokens`) as inclusive within each dimension and intersected across dimensions.
- **`CoinListViewController.swift` & `CoinListViewController+Extension.swift`**:
  - Connected `setupBindings()` before triggering a single `fetchCoins()`, removed redundant `DispatchQueue.main.async` inside `@MainActor` closures, and added `[weak self]` captures.
  - Updated `searchBarCancelButtonClicked` to reset via `viewModel.searchCoins(query: "")`.
- **`FilterView.swift`**: Removed `DispatchQueue.main.async` around layout setup and switched bottom-sheet presentation to Auto Layout constraints respecting `safeAreaLayoutGuide`.

### 3. Domain, Data & Networking Hardening
- **`FetchCryptoCoinsUseCase.swift` & `CryptoRepositoryProtocol.swift`**: Added `FetchCryptoCoinsUseCaseProtocol` and removed the duplicate cache write so `CryptoRepository` is the single owner of caching.
- **`CryptoRepository.swift`**: Added network-first with automatic cache-fallback policy in `fetchCryptoCoins()` (caches once on network success; falls back to cached coins on network failure; rethrows if cache is empty).
- **`CoreDataHelper.swift`, `CryptoLocalDataSourceImpl.swift` & `CryptoCoinModel+CoreDataMapper.swift`**:
  - Replaced `fatalError` with throwing `CoreDataHelper.init(inMemory:)` (`CoreDataError`), enabled `automaticallyMergesChangesFromParent`, and added `/dev/null` SQLite store support for isolated tests.
  - Preserved `self.id` in `toCoreData(context:)`.
  - Persisted background context saves before merging `NSBatchDeleteRequest` deleted object IDs onto `mainContext.perform`.
- **`NetworkManager.swift`, `Endpoints.swift`, `HTTPMethod.swift`, `APIServiceProtocol.swift`, `CryptoNetworkDataSourceImpl.swift` & `Reachability.swift`**:
  - Fixed `NetworkManager` header merging (`Content-Type: application/json` + `endpoint.headers`), injected `NetworkSessionProtocol` (`URLSessionTransport`), mapped `URLError` offline/timeout cases, and removed force-unwraps in `Endpoint` and `Reachability` (`NetworkReachabilityProtocol`).
  - Injected `any APIServiceProtocol: Sendable` into `CryptoNetworkDataSourceImpl`.

---

## Verification

Verified with `xcodebuild test` (`Xcode-beta`, iPhone SE (3rd generation) Simulator, iOS 27.0) — **37 / 37 tests passed, 0 Swift compiler warnings**:

| Target | Result | Cases Passed |
|--------|--------|--------------|
| `CommonTests` | `TEST SUCCEEDED` | 3 / 3 |
| `DomainTests` | `TEST SUCCEEDED` | 6 / 6 |
| `InfrastructureTests` | `TEST SUCCEEDED` | 9 / 9 |
| `DataTests` | `TEST SUCCEEDED` | 7 / 7 |
| `PresentationTests` | `TEST SUCCEEDED` | 11 / 11 |
| `JaneshSutharCryptoDemoiOSTests` | `TEST SUCCEEDED` | 1 / 1 |
