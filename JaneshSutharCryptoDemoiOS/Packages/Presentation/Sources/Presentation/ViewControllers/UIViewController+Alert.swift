//
//  UIViewController+Alert.swift
//  Presentation
//
//  Created by Janesh Suthar
//

import UIKit
import Common

extension UIViewController {
    public func showAlert(message: String, title: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(
            title: Localization.localizedString(for: "ok", defaultValue: "Ok"),
            style: .default
        ))
        present(alert, animated: true)
    }
}
