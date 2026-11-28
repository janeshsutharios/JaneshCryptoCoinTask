//
//  CoinListViewController+Extension.swift
//  CryptoCoin
//
//  Created by Janesh Suthar.
//

import UIKit

// MARK: - CryptoListViewController UITableViewDelegate
extension CryptoListViewController: UITableViewDelegate, UITableViewDataSource {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.filteredCoins.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CryptoTableViewCell", for: indexPath) as? CryptoTableViewCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        let coin = viewModel.filteredCoins[indexPath.row]
        var image = coin.isActive ? UIImage(named: "activeCoin") : UIImage(named: "inactiveCoin")
        image = coin.type == "token" ? UIImage(named: "token") : image
        cell.configure(title: coin.name, subtitle: "(\(coin.symbol))", image: image, isNew: coin.isNew)
        return cell
    }
}

// MARK: - CryptoListViewController UISearchBarDelegate
extension CryptoListViewController: UISearchBarDelegate {
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }

    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchCoins(query: searchText)
    }

    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.searchCoins(query: "")
        searchBar.text = ""
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
    }
}
