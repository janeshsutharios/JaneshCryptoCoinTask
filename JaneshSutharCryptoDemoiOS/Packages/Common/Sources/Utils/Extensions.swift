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

public class BlurEffectView: UIView {
    private var blurEffectView: UIVisualEffectView?

    /// Sets up the blur effect view with the specified style.
    /// - Parameter style: The style of the blur effect. Default is `.dark`.
    public func setupBlurEffect(style: UIBlurEffect.Style = .dark) {
        guard blurEffectView == nil else { return }
        
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.alpha = 0
        addSubview(blurEffectView)
        
        self.blurEffectView = blurEffectView
    }

    /// Displays the blur effect with a fade-in animation.
    /// - Parameter duration: The duration of the animation. Default is `0.2` seconds.
    public func showBlurEffect(duration: TimeInterval = 0.2) {
        setupBlurEffect()
        UIView.animate(withDuration: duration) {
            self.blurEffectView?.alpha = 1
        }
    }

    /// Hides the blur effect with a fade-out animation and removes it from the view.
    /// - Parameter duration: The duration of the animation. Default is `0.2` seconds.
    public func hideBlurEffect(duration: TimeInterval = 0.2) {
        guard let blurEffectView = blurEffectView else { return }
        
        UIView.animate(withDuration: duration, animations: {
            blurEffectView.alpha = 0
        }) { _ in
            blurEffectView.removeFromSuperview()
            self.blurEffectView = nil
        }
    }
}
