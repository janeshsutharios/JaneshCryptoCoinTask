import UIKit
import Common
import Foundation

class LoaderView: UIView {

    private let logoImageView: UIImageView
    private let messageLabel: UILabel
    private static var currentLoader: LoaderView?

    // MARK: - Initialization Methods
    override init(frame: CGRect) {
        logoImageView = UIImageView(image: UIImage(named: "bitCoin"))
        messageLabel = UILabel()
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = UIColor(white: 0, alpha: 0.5)

        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.heightAnchor.constraint(equalToConstant: LayoutConstants.iconHeight).isActive = true
        logoImageView.widthAnchor.constraint(equalToConstant: LayoutConstants.iconHeight).isActive = true

        messageLabel.text = Localization.localizedString(for: "loading", defaultValue: "Loading....")
        messageLabel.textColor = .white
        messageLabel.font = UIFont.systemFont(ofSize: LayoutConstants.defaultFontSize, weight: .medium)
        messageLabel.textAlignment = .center
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView(arrangedSubviews: [logoImageView, messageLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = Spacing.smallVerticalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    // MARK: - Private Methods
    private func stopLoader() {
        removeFromSuperview()
    }

    private func showLoader(in view: UIView) {
        view.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.topAnchor),
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // Class method to show the loader
    class func showLoader(in view: UIView) {
        if currentLoader == nil {
            let loader = LoaderView(frame: .zero)
            loader.showLoader(in: view)
            currentLoader = loader
        }
    }

    // Class method to hide the loader
    class func hideLoader() {
        currentLoader?.stopLoader()
        currentLoader = nil
    }
}
