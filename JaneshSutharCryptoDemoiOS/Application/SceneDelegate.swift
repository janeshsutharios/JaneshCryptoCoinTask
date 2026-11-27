//
//  SceneDelegate.swift
//  CryptoCoin
//
//  Created by Janesh Suthar.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        do {
            window.rootViewController = try AppDIContainer.makeCoinListViewController()
        } catch {
            let fallbackController = UIViewController()
            fallbackController.view.backgroundColor = .systemBackground
            window.rootViewController = UINavigationController(rootViewController: fallbackController)
            assertionFailure("Failed to initialize application dependencies: \(error)")
        }
        window.makeKeyAndVisible()
        self.window = window
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
