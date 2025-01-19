import UIKit
import Domain
import Common
import Data
import Infrastructure

class CryptoListViewController: UIViewController {
    var viewModel: CryptoListViewModel!
    let tableView = UITableView()
    private var selectedFilterOptions: Set<FilterOption> = []
    private var filterView: FilterView?
    private var noDataView: NoDataView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        initializeViewModel()
        setupBindings()
        viewModel.fetchCoins()
    }
    
    //MARK: - Private Methods
    private func initializeViewModel() {
        let apiService = NetworkServiceManager()
        let networkDataSource = CryptoNetworkDataSourceImpl(apiService: apiService)
        let coreDataHelper = CoreDataHelper()
        let localDataSource = CryptoLocalDataSourceImpl(coreDataHelper: coreDataHelper)
        let repository = CryptoRepository(networkDataSource: networkDataSource, localDataSource: localDataSource)
        let useCase = FetchCryptoCoinsUseCase(repository: repository)
        viewModel = CryptoListViewModel(getCryptoCoinsUseCase: useCase)
    }
    
    private func setupUI() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 75
        tableView.estimatedRowHeight = 75
        tableView.register(CryptoTableViewCell.self, forCellReuseIdentifier: "CryptoTableViewCell")
        setupConstraints()
    }
    
    private func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: LayoutConstants.mediumMargin),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupBindings() {
        viewModel.reloadTableView = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.updateNoDataView()
            }
        }
        
        viewModel.showLoader = {
            DispatchQueue.main.async {
                LoaderView.showLoader(in: self.view)
            }
        }
        
        viewModel.hideLoader = {
            DispatchQueue.main.async {
                LoaderView.hideLoader()
            }
        }
        
        viewModel.manageError = { title, message in
            DispatchQueue.main.async {
                self.showAlert(message: message, title: title)
            }
        }
    }
    
    private func setupNavigationBar() {
        title = Localization.localizedString(for: "coin",defaultValue: "Coin")
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .systemBlue
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = Localization.localizedString(for: "search_crypto_coins",defaultValue: "Search Crypto Coins")
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.tintColor = .systemBlue
        navigationItem.searchController = searchController
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "flask"),
            style: .plain,
            target: self,
            action: #selector(showFilterOptions)
        )
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    //MARK: - Filter View Methods
    @objc private func hideFilterOptions() {
        UIView.animate(withDuration: 0.3, animations: {
            self.filterView?.frame.origin.y = self.view.frame.height
        }) { _ in
            self.filterView?.removeFromSuperview()
            self.filterView = nil
        }
    }
    
    @objc private func showFilterOptions() {
        guard filterView == nil else { return }
        let filterViewHeight = 200.0
        let filterFrame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: filterViewHeight)
        filterView = FilterView(frame: filterFrame)
        filterView?.onApplyFilters = { [weak self] selectedOptions in
            self?.applySelectedFilters(selectedOptions)
            self?.hideFilterOptions()
        }
        
        filterView?.onCancelFilters = { [weak self] in
            self?.hideFilterOptions()
        }
                
        filterView?.selectedFilters = selectedFilterOptions
        filterView?.updateButtonStates()
        
        view.addSubview(filterView!)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            self.filterView?.frame.origin.y = self.view.frame.height - filterViewHeight
        }
    }
    
    private func applySelectedFilters(_ selectedOptions: Set<FilterOption>) {
        selectedFilterOptions = selectedOptions
        let isActive = selectedOptions.contains(.activeCoins) ? true : nil
        let isInactive = selectedOptions.contains(.inactiveCoins) ? true : nil
        let isNew = selectedOptions.contains(.newCoins) ? true : nil
        let onlyCoins = selectedOptions.contains(.onlyCoins) ? "coin" : nil
        let onlyTokens = selectedOptions.contains(.onlyTokens) ? "token" : nil
        viewModel.filterCoins(isActive: isActive, isInactive: isInactive, onlyCoins: onlyCoins, isNew: isNew, onlyTokens: onlyTokens)
    }
    
    //MARK: - NoData View Methods
    private func showNoDataView() {
        if noDataView == nil {
            let newNoDataView = NoDataView(frame: .zero)
            newNoDataView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(newNoDataView)
            noDataView = newNoDataView
            
            NSLayoutConstraint.activate([
                newNoDataView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                newNoDataView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                newNoDataView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: LayoutConstants.defaultMargin),
                newNoDataView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -LayoutConstants.defaultMargin)
            ])
            
            newNoDataView.alpha = 0
            UIView.animate(withDuration: 0.2) {
                newNoDataView.alpha = 1
            }
        }
    }
    
    private func hideNoDataView() {
        guard let noDataView = noDataView else { return }
        
        UIView.animate(withDuration: 0.2, animations: {
            noDataView.alpha = 0
        }) { _ in
            noDataView.removeFromSuperview()
            self.noDataView = nil
        }
    }
    
    private func updateNoDataView() {
        if viewModel.isFilteredCoinsEmpty {
            showNoDataView()
        } else {
            hideNoDataView()
        }
    }
}
