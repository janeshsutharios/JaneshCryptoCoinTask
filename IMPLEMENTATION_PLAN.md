# Implementation Plan — CryptoCoin iOS Refactoring & Unit Tests

> **Aligned with:** `Updated Crypto Coins Assignment-IOS.pdf`  
> **Branch:** `refactor/architecture-and-tests`  
> **Constraints:** Keep current app behavior & UI intact · Follow Swift 6 / Clean Architecture / SOLID best practices

---

## PDF Alignment & Behavior-Preservation Decisions

| Area | PDF Specification | Current App Behavior | Plan Action |
|------|-------------------|----------------------|-------------|
| **UI Framework** | Programmatic UIKit (no SwiftUI) | Programmatic UIKit (`CryptoListViewController`, `FilterView`, `CryptoTableViewCell`, `LoaderView`, `NoDataView`) | Keep programmatic UIKit; replace frame-based `FilterView` animation & `DispatchQueue.main.async` UI setup with Auto Layout so all devices/orientations work with **zero constraint warnings** |
| **Endpoint** | `https://37656be98b8f42ae8348e4da3ee3193f.api.mockbin.io/` | `https://raw.githubusercontent.com/janeshsutharios/REST_GET_API/refs/heads/main/crypto-coins.json` | **Keep current endpoint URL intact** (isolated in `APIConfig` / `NetworkServiceManager`) |
| **Cell Display** | Name, Symbol, Type; disabled state if inactive; NEW badge | Bold `name`, `(\(symbol))`, right icon (`activeCoin` / `inactiveCoin` / `token`), rotated `NEW` ribbon | **Keep current cell appearance intact**; verify zero Auto Layout warnings |
| **Search & Filter** | Search by name & symbol; multiple filters simultaneously | Search by name/symbol; 5 filter options (`Active Coins`, `Inactive Coins`, `Only Coins`, `Only Tokens`, `New Coins`) | Unify search + filter state so they combine cleanly instead of overwriting each other; handle opposite pairs (`Active`+`Inactive`, `Only Coins`+`Only Tokens`) as "any in that dimension" |
| **Offline Mode** | Runs smoothly offline | `Reachability` pre-check (with force-unwrap) + no cache fallback when request fails | Move network-with-cache-fallback policy to `CryptoRepository`: try network, cache once on success, fall back to Core Data cache on network failure |
| **Architecture & Modules** | Clean / MVVM, SOLID, modular segregation | 5 SPM packages (`Common`, `Domain`, `Infrastructure`, `Data`, `Presentation`), but `Presentation` imports `Data` & `Infrastructure` | Enforce clean dependency direction: `Presentation` depends **only** on `Domain` + `Common`; move DI composition to `AppDIContainer` + `SceneDelegate` |
| **Quality Gates** | Zero Xcode warnings, zero constraint errors, passing unit tests | Compile issues in `PresentationTests`, unused placeholders in `CommonTests`/`InfrastructureTests`, wrong container in `DataTests` | Fix all compiler/concurrency warnings (Swift 6) and build comprehensive unit tests across all 5 packages |

---

## Phase 1 — `Common` & `Domain` Layers

### 1.1 `Common` Package (Platform-Agnostic Utilities)
- `JaneshSutharCryptoDemoiOS/Packages/Common/Sources/Utils/Extensions.swift`: Remove `import UIKit` and `UIViewController.showAlert(...)` so `Common` remains platform-agnostic.
- `JaneshSutharCryptoDemoiOS/Packages/Common/Sources/Utils/Reachability.swift`:
  - Replace force-unwrap `defaultRouteReachability!` with `guard let`.
  - Define `public protocol NetworkReachabilityProtocol: Sendable { func isConnectedToNetwork() -> Bool }` and conform `Reachability` to it.

### 1.2 `Domain` Package (Pure Business Rules & Contracts)
- `JaneshSutharCryptoDemoiOS/Packages/Domain/Sources/Domain/Repositories/CryptoRepositoryProtocol.swift` & `FetchCryptoCoinsUseCase.swift`:
  - Introduce `public protocol FetchCryptoCoinsUseCaseProtocol: Sendable` so `Presentation` and tests never depend on or subclass the concrete `actor`.
  - Remove the duplicate `saveCryptoCoinsIntoCache` call from `FetchCryptoCoinsUseCase` so caching occurs **exactly once** per network fetch.
  - Add a resilient fetch path (`fetchCryptoCoins()`) where `CryptoRepository` owns the network-first + cache-fallback policy (while preserving `fromNetwork` / explicit cache methods cleanly).

---

## Phase 2 — `Infrastructure` & `Data` Layers

### 2.1 `Infrastructure` Package (Networking)
- `JaneshSutharCryptoDemoiOS/Packages/Infrastructure/Sources/Infrastructure/Network/NetworkManager.swift`:
  - Merge `["Content-Type": "application/json"]` with `endpoint.headers` instead of overwriting `allHTTPHeaderFields`.
  - Inject a `NetworkSessionProtocol` (defaulting to `URLSession.shared`) so HTTP status handling (`200...299`, `4xx`, `5xx`), header merging, `noData`, `URLError` mapping, and `decodingError` are unit-testable offline.
  - Remove the redundant `Reachability` pre-check from `NetworkManager` and map `URLError.notConnectedToInternet` / `.timedOut` to `NetworkError.noInternet` / `.timeout`.

### 2.2 `Data` Package (Repository, Mapper, Core Data)
- `CryptoNetworkDataSourceImpl.swift`: Inject `any APIServiceProtocol` instead of concrete `NetworkServiceManager`.
- `CryptoRepository.swift`:
  - Single owner of cache writes (`getCryptoCoinsFromNetwork` saves once).
  - Implement resilient `fetchCryptoCoins()`: try network (which caches once); if network fails, fall back to local cache (throwing only if cache fails or is empty when offline/network failed).
- `CoreDataHelper.swift`:
  - Replace `fatalError` with throwing `init(inMemory: Bool = false)` and `CoreDataError`.
  - Configure `persistentContainer.viewContext.automaticallyMergesChangesFromParent = true`.
  - Support `inMemory == true` using `/dev/null` SQLite store URL so `NSBatchDeleteRequest` works in isolated unit tests.
- `CryptoLocalDataSourceImpl.swift`:
  - In `saveCryptoCoins(_:)`: execute `NSBatchDeleteRequest` (`.resultTypeObjectIDs`), insert new entities, **save the background context first**, then merge `[NSDeletedObjectsKey: deletedIDs]` on `mainContext` inside `await mainContext.perform { ... }`.
- `CryptoCoinModel+CoreDataMapper.swift`:
  - Preserve coin identity in `toCoreData`: `coreDataModel.id = self.id ?? UUID().uuidString`.

---

## Phase 3 — `Presentation` Layer & App Composition Root

### 3.1 Enforce Package Boundaries
- `JaneshSutharCryptoDemoiOS/Packages/Presentation/Package.swift`: Remove `"Data"` and `"Infrastructure"` dependencies (keep `"Common"` and `"Domain"` only).
- Remove `import Data` / `import Infrastructure` from `CoinListViewController.swift`, `NoDataView.swift`, and `LoaderView.swift`.

### 3.2 `CryptoListViewModel`
- Synchronous, side-effect-free `init(getCryptoCoinsUseCase: any FetchCryptoCoinsUseCaseProtocol, ...)`.
- Keep `searchQuery` and filter selections (`active`, `inactive`, `onlyCoins`, `onlyTokens`, `isNew`) as ViewModel state and derive `filteredCoins` from all criteria together:
  - **Status dimension:** `active` / `inactive` — if both selected or neither selected, include both; if one selected, filter to that status.
  - **Type dimension:** `onlyCoins` / `onlyTokens` — if both selected or neither selected, include both; if one selected, filter to that type.
  - **Newness dimension:** if `isNew` selected, require `isNew == true`.
  - **Search query:** case-insensitive match on `name` or `symbol`.
- Guarantee loader/reload lifecycle via `defer`.

### 3.3 `CoinListViewController`, `FilterView` & Auto Layout Hygiene
- Make `CryptoListViewController` `public` with `public init(viewModel: CryptoListViewModel)`.
- In `viewDidLoad()`: `setupNavigationBar()` → `setupUI()` → `setupBindings()` → single `Task { await viewModel.fetchCoins() }`.
- In `setupBindings()`: remove redundant `DispatchQueue.main.async` (already `@MainActor`) and capture `[weak self]` in all closures.
- In `searchBarCancelButtonClicked`: call `viewModel.searchCoins(query: "")` instead of mutating `filteredCoins`.
- Move `UIViewController.showAlert(...)` into `Presentation` (`UIViewController+Alert.swift`).
- In `FilterView.swift`: remove `DispatchQueue.main.async` around `setupUI()` and `updateButtonStates()` so layout is synchronous; use Auto Layout constraints with safe-area bottom inset for `FilterView` presentation in `CoinListViewController` so there are zero runtime constraint warnings on any device or orientation.

### 3.4 Composition Root in App Target
- Add `AppDIContainer` in `JaneshSutharCryptoDemoiOS/Application/` and register in `project.pbxproj`.
- Update `SceneDelegate.swift` to construct the `UIWindow` programmatically via `AppDIContainer.makeCoinListViewController()` and remove `UISceneStoryboardFile` (`Main`) from `Info.plist`.

---

## Phase 4 — Comprehensive Unit Tests & Verification

| Test Target | Planned Coverage |
|-------------|-----------------|
| **`CommonTests`** | `Localization` (known key & default fallback), `Reachability` protocol smoke test |
| **`DomainTests`** | Remove cross-layer imports & unused `MockGetCryptoCoinsUseCase`; test `FetchCryptoCoinsUseCase` success/failure + verify **1 cache save** per network fetch |
| **`InfrastructureTests`** | `Endpoint` URL & query item construction, `HTTPMethod`, `NetworkError` descriptions, `NetworkManager` (via `NetworkSessionProtocol` mock): header merge preserving `Content-Type`, 2xx decoding, decoding failure, 4xx/5xx `requestFailed`, `URLError` mapping, invalid URL |
| **`DataTests`** | `CryptoLocalDataSourceImpl` with injected in-memory `/dev/null` `CoreDataHelper`: save & fetch, ID preservation, repeated overwrite replacing prior coins, `mainContext` consistency after batch delete, empty list handling; `CryptoRepository`: network success caches once, network failure falls back to cache, empty cache / failure error propagation |
| **`PresentationTests`** | `MockGetCryptoCoinsUseCase` conforming to `FetchCryptoCoinsUseCaseProtocol`; synchronous `setUp()` and `await` calls; single fetch + callback order (`showLoader` → `reloadTableView` → `hideLoader`), error callback, search (name, case-insensitive symbol, empty reset, no match), all filters, combined search + filters, opposite-pair filters (`Active`+`Inactive`, `Only Coins`+`Only Tokens`) |
