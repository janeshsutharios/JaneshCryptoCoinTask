import UIKit
import Domain
import Common

@MainActor
public final class CryptoListViewController: UIViewController {
    public let viewModel: CryptoListViewModel
    let tableView = UITableView()
    private let searchBar = UISearchBar()
    private var selectedFilterOptions: Set<FilterOption> = []
    private var filterView: FilterView?
    private var filterViewTopConstraint: NSLayoutConstraint?
    private var noDataView: NoDataView?

    public init(viewModel: CryptoListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented; use init(viewModel:) instead.")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupBindings()
        Task { [weak self] in
            await self?.viewModel.fetchCoins()
        }
    }

    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = .systemBackground

        searchBar.delegate = self
        searchBar.placeholder = Localization.localizedString(
            for: "search_crypto_coins",
            defaultValue: "Search Crypto Coins"
        )
        searchBar.searchBarStyle = .minimal
        searchBar.tintColor = .systemBlue

        view.addSubview(searchBar)
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 75
        tableView.estimatedRowHeight = 75
        tableView.register(CryptoTableViewCell.self, forCellReuseIdentifier: "CryptoTableViewCell")
        setupConstraints()
    }

    private func setupConstraints() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: LayoutConstants.mediumMargin
            ),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 44),
            tableView.topAnchor.constraint(
                equalTo: searchBar.bottomAnchor,
                constant: LayoutConstants.mediumMargin
            ),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func setupBindings() {
        viewModel.reloadTableView = { [weak self] in
            self?.tableView.reloadData()
            self?.updateNoDataView()
        }

        viewModel.showLoader = { [weak self] in
            guard let self else { return }
            LoaderView.showLoader(in: self.view)
        }

        viewModel.hideLoader = {
            LoaderView.hideLoader()
        }

        viewModel.manageError = { [weak self] title, message in
            self?.showAlert(message: message, title: title)
        }
    }

    private func setupNavigationBar() {
        title = Localization.localizedString(for: "coin", defaultValue: "Coin")
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .systemBlue

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "flask"),
            style: .plain,
            target: self,
            action: #selector(showFilterOptions)
        )
    }

    // MARK: - Filter View Methods
    @objc private func hideFilterOptions() {
        guard let filterView else { return }
        filterViewTopConstraint?.isActive = false
        let offscreenConstraint = filterView.topAnchor.constraint(equalTo: view.bottomAnchor)
        offscreenConstraint.isActive = true
        filterViewTopConstraint = offscreenConstraint

        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        }) { [weak self] _ in
            self?.filterView?.removeFromSuperview()
            self?.filterView = nil
            self?.filterViewTopConstraint = nil
        }
    }

    @objc private func showFilterOptions() {
        guard filterView == nil else { return }

        let newFilterView = FilterView(frame: .zero)
        newFilterView.translatesAutoresizingMaskIntoConstraints = false
        newFilterView.onApplyFilters = { [weak self] selectedOptions in
            self?.applySelectedFilters(selectedOptions)
            self?.hideFilterOptions()
        }
        newFilterView.onCancelFilters = { [weak self] in
            self?.hideFilterOptions()
        }
        newFilterView.selectedFilters = selectedFilterOptions
        newFilterView.updateButtonStates()

        view.addSubview(newFilterView)
        let offscreenTop = newFilterView.topAnchor.constraint(equalTo: view.bottomAnchor)
        NSLayoutConstraint.activate([
            newFilterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            newFilterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            offscreenTop
        ])
        view.layoutIfNeeded()

        offscreenTop.isActive = false
        let visibleBottom = newFilterView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        visibleBottom.isActive = true

        self.filterView = newFilterView
        self.filterViewTopConstraint = visibleBottom

        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }

    private func applySelectedFilters(_ selectedOptions: Set<FilterOption>) {
        selectedFilterOptions = selectedOptions
        let isActive = selectedOptions.contains(.activeCoins) ? true : nil
        let isInactive = selectedOptions.contains(.inactiveCoins) ? true : nil
        let isNew = selectedOptions.contains(.newCoins) ? true : nil
        let onlyCoins = selectedOptions.contains(.onlyCoins) ? "coin" : nil
        let onlyTokens = selectedOptions.contains(.onlyTokens) ? "token" : nil
        viewModel.filterCoins(
            isActive: isActive,
            isInactive: isInactive,
            onlyCoins: onlyCoins,
            isNew: isNew,
            onlyTokens: onlyTokens
        )
    }

    // MARK: - NoData View Methods
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
        }) { [weak self] _ in
            noDataView.removeFromSuperview()
            self?.noDataView = nil
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
