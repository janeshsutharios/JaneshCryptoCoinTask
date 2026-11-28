//
//  JaneshSutharCryptoDemoiOSTests.swift
//  JaneshSutharCryptoDemoiOSTests
//
//  Created by Janesh Suthar-M2 on 19/01/25.
//

import XCTest
import Presentation
@testable import JaneshSutharCryptoDemoiOS

final class JaneshSutharCryptoDemoiOSTests: XCTestCase {

    @MainActor
    func testAppDIContainer_buildsNavigationWithCryptoListViewController() throws {
        let root = try AppDIContainer.makeCoinListViewController()
        let navController = try XCTUnwrap(root as? UINavigationController)
        XCTAssertTrue(navController.viewControllers.first is CryptoListViewController)
    }
}
