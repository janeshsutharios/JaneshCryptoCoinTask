//
//  NewsRepository.swift
//  NewsApp
//
//  Created by Janesh Suthar.
//
import Foundation
import Domain

/* APIService Manage the logic for fetching crypto coins list from the API */
public class NetworkServiceManager: APIServiceProtocol {
    public init() {}
    public func fetchCryptoCoins() async throws -> [CryptoCoinEntity] {
        let endpoint = Endpoint.createGETEndpoint(path: "", queryItems: [])
        do {
            let cryptoCoins: [CryptoCoinEntity] = try await NetworkManager.shared.request(endpoint: endpoint)
            return cryptoCoins
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.unknown(error)
        }
    }
}

