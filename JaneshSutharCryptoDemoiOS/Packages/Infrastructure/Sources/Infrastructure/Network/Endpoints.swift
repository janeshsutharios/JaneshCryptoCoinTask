import Foundation

public struct Endpoint: Sendable {
    public let path: String
    public let method: HTTPMethod
    public let queryItems: [URLQueryItem]?
    public let headers: [String: String]?
    public let body: Data?

    public var fullUrl: String {
        guard var components = URLComponents(string: APIConfig.baseUrl) else {
            return ""
        }
        components.path = path
        components.queryItems = queryItems
        return components.url?.absoluteString ?? ""
    }

    public init(
        path: String,
        method: HTTPMethod,
        queryItems: [URLQueryItem]? = nil,
        headers: [String: String]? = nil,
        body: Data? = nil
    ) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
        self.headers = headers
        self.body = body
    }

    public static func createGETEndpoint(
        path: String,
        queryItems: [URLQueryItem]? = nil,
        headers: [String: String]? = nil
    ) -> Endpoint {
        return Endpoint(path: path, method: .GET, queryItems: queryItems, headers: headers)
    }
}
