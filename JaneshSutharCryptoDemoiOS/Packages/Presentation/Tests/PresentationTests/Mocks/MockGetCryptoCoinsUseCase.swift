//
//  MockGetCryptoCoinsUseCase.swift
//  CryptoCoinTests
//
//  Created by Janesh Suthar
//

import Foundation
import Domain
@testable import Presentation

final class MockGetCryptoCoinsUseCase: FetchCryptoCoinsUseCaseProtocol, @unchecked Sendable {
    var mockedCoins: [CryptoCoinEntity] = []
    var errorToThrow: (any Error)?
    var executeCallCount = 0

    func execute() async throws -> [CryptoCoinEntity] {
        executeCallCount += 1
        if let error = errorToThrow {
            throw error
        }
        return mockedCoins
    }

    func execute(fromNetwork: Bool) async throws -> [CryptoCoinEntity] {
        try await execute()
    }
}
