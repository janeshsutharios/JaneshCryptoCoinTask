import Foundation

public protocol NetworkSessionProtocol: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

public struct URLSessionTransport: NetworkSessionProtocol {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await session.data(for: request)
    }
}

public actor NetworkManager {
    private let session: any NetworkSessionProtocol

    public init(session: any NetworkSessionProtocol = URLSessionTransport()) {
        self.session = session
    }

    // Optimized request method using async/await
    public func request<T: Decodable>(endpoint: Endpoint) async throws -> T {
        // Validate the URL
        guard !endpoint.fullUrl.isEmpty, let url = URL(string: endpoint.fullUrl) else {
            throw NetworkError.invalidURL
        }

        // Setup the request
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        var mergedHeaders = ["Content-Type": "application/json"]
        endpoint.headers?.forEach { mergedHeaders[$0.key] = $0.value }
        request.allHTTPHeaderFields = mergedHeaders
        request.httpBody = endpoint.body

        // Perform the network request and handle transport errors
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch let urlError as URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed:
                throw NetworkError.noInternet
            case .timedOut:
                throw NetworkError.timeout
            default:
                throw NetworkError.unknown(urlError)
            }
        } catch {
            throw NetworkError.unknown(error)
        }

        // Handle the response
        try handleResponse(response, data: data)

        // Decode and return the result
        return try decodeResponse(T.self, data: data)
    }

    // Handle HTTP response status codes
    private func handleResponse(_ response: URLResponse?, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.requestFailed(statusCode: 0)
        }

        switch httpResponse.statusCode {
        case 200...299:
            if data.isEmpty {
                throw NetworkError.noData
            }
        case 400...499, 500...599:
            throw NetworkError.requestFailed(statusCode: httpResponse.statusCode)
        default:
            throw NetworkError.requestFailed(statusCode: httpResponse.statusCode)
        }
    }

    // Decode the data into the appropriate model
    private func decodeResponse<T: Decodable>(_ type: T.Type, data: Data) throws -> T {
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
}
