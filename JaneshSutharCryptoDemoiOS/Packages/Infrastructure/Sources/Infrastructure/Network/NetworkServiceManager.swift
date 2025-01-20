import Foundation
import Domain

public class NetworkServiceManager: APIServiceProtocol {
    private let networkManager: NetworkManager

    public init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }

    public func fetchCryptoCoins() async throws -> [CryptoCoinEntity] {
        let endpoint = Endpoint.createGETEndpoint(path: "/crypto/coins", queryItems: [])
        do {
            let cryptoCoins: [CryptoCoinEntity] = try await networkManager.request(endpoint: endpoint)
            return cryptoCoins
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.unknown(error)
        }
    }
}
