//
//  SceneDelegate.swift
//  CryptoCoin
//
//  Created by Janesh Suthar.
//

import UIKit
import OSLog

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "CryptoCoin", category: "SceneDelegate")

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        let setupError = configureRootViewController(in: window)
        window.makeKeyAndVisible()
        self.window = window

        if let setupError {
            logger.error("Failed to initialize application dependencies: \(setupError.localizedDescription, privacy: .public)")
        }
    }

    @discardableResult
    private func configureRootViewController(in window: UIWindow) -> (any Error)? {
        do {
            window.rootViewController = try AppDIContainer.makeCoinListViewController()
            return nil
        } catch {
            let errorController = DependencyErrorViewController(
                error: error,
                onRetry: { [weak self, weak window] in
                    guard let self, let window else { return }
                    if let retryError = self.configureRootViewController(in: window) {
                        self.logger.error("Retry failed to initialize application dependencies: \(retryError.localizedDescription, privacy: .public)")
                    }
                }
            )
            window.rootViewController = UINavigationController(rootViewController: errorController)
            return error
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}

private final class DependencyErrorViewController: UIViewController {
    private let errorMessage: String
    private let onRetry: () -> Void

    init(error: any Error, onRetry: @escaping () -> Void) {
        self.errorMessage = error.localizedDescription
        self.onRetry = onRetry
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
    }

    private func setupUI() {
        let iconView = UIImageView(image: UIImage(systemName: "exclamationmark.triangle"))
        iconView.tintColor = .systemOrange
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 44),
            iconView.heightAnchor.constraint(equalToConstant: 44)
        ])

        let titleLabel = UILabel()
        titleLabel.text = "Unable to Start"
        titleLabel.font = .preferredFont(forTextStyle: .title2)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        let messageLabel = UILabel()
        messageLabel.text = "Local storage could not be initialized. Please try again.\n\n\(errorMessage)"
        messageLabel.font = .preferredFont(forTextStyle: .body)
        messageLabel.textColor = .secondaryLabel
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0

        let retryButton = UIButton(type: .system)
        retryButton.setTitle("Retry", for: .normal)
        retryButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        retryButton.addTarget(self, action: #selector(didTapRetry), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [iconView, titleLabel, messageLabel, retryButton])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -16)
        ])
    }

    @objc private func didTapRetry() {
        onRetry()
    }
}
