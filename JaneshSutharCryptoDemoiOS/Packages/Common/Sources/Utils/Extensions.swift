//
//  Extensions.swift
//  CryptoCoin
//
//  Created by Janesh Suthar
//

import UIKit

extension UIViewController {
    public func showAlert(message: String, title: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Localization.localizedString(for: "ok",defaultValue: "Ok"), style: .default))
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
}
