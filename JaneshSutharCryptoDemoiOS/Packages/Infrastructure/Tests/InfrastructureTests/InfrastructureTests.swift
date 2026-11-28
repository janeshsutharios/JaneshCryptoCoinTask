import XCTest
import Domain
@testable import Infrastructure

final class MockNetworkSession: NetworkSessionProtocol, @unchecked Sendable {
    var capturedRequest: URLRequest?
    var resultToReturn: Result<(Data, URLResponse), any Error> = .failure(NetworkError.noData)

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        capturedRequest = request
        return try resultToReturn.get()
    }
}

final class InfrastructureTests: XCTestCase {

    // MARK: - Endpoint & Error Tests
    func testEndpointFullUrl_correctlyBuildsURLAndQueryItems() {
        let items = [URLQueryItem(name: "page", value: "2")]
        let endpoint = Endpoint.createGETEndpoint(path: "/coins", queryItems: items)
        XCTAssertTrue(endpoint.fullUrl.contains("raw.githubusercontent.com"))
        XCTAssertTrue(endpoint.fullUrl.contains("/coins"))
        XCTAssertTrue(endpoint.fullUrl.contains("page=2"))
    }

    func testHTTPMethod_rawValues() {
        XCTAssertEqual(HTTPMethod.GET.rawValue, "GET")
        XCTAssertEqual(HTTPMethod.POST.rawValue, "POST")
    }

    func testNetworkError_descriptions() {
        XCTAssertNotNil(NetworkError.invalidURL.errorDescription)
        XCTAssertNotNil(NetworkError.noInternet.errorDescription)
        XCTAssertNotNil(NetworkError.decodingError.errorDescription)
        XCTAssertNotNil(NetworkError.noData.errorDescription)
        XCTAssertNotNil(NetworkError.timeout.errorDescription)
        XCTAssertTrue(NetworkError.requestFailed(statusCode: 503).errorDescription?.contains("503") == true)
    }

    // MARK: - NetworkManager Tests
    func testRequest_mergesCustomHeadersWithDefaultContentType() async throws {
        let session = MockNetworkSession()
        let json = #"[{"id":"btc","name":"Bitcoin","symbol":"BTC","type":"coin","is_active":true,"is_new":false}]"#
        let url = URL(string: "https://raw.githubusercontent.com/coins")!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        session.resultToReturn = .success((Data(json.utf8), response))

        let manager = NetworkManager(session: session)
        let endpoint = Endpoint.createGETEndpoint(path: "/coins", headers: ["Authorization": "Bearer token"])
        let coins: [CryptoCoinEntity] = try await manager.request(endpoint: endpoint)

        XCTAssertEqual(coins.count, 1)
        XCTAssertEqual(coins.first?.symbol, "BTC")
        XCTAssertEqual(session.capturedRequest?.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(session.capturedRequest?.value(forHTTPHeaderField: "Authorization"), "Bearer token")
    }

    func testRequest_preservesDefaultContentTypeWhenEndpointHeadersNil() async throws {
        let session = MockNetworkSession()
        let json = #"[]"#
        let url = URL(string: "https://raw.githubusercontent.com/coins")!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        session.resultToReturn = .success((Data(json.utf8), response))

        let manager = NetworkManager(session: session)
        let endpoint = Endpoint.createGETEndpoint(path: "/coins")
        let coins: [CryptoCoinEntity] = try await manager.request(endpoint: endpoint)

        XCTAssertTrue(coins.isEmpty)
        XCTAssertEqual(session.capturedRequest?.value(forHTTPHeaderField: "Content-Type"), "application/json")
    }

    func testRequest_httpErrorThrowsRequestFailedWithStatusCode() async {
        let session = MockNetworkSession()
        let url = URL(string: "https://raw.githubusercontent.com/coins")!
        let response = HTTPURLResponse(url: url, statusCode: 404, httpVersion: nil, headerFields: nil)!
        session.resultToReturn = .success((Data(), response))

        let manager = NetworkManager(session: session)
        let endpoint = Endpoint.createGETEndpoint(path: "/coins")

        do {
            let _: [CryptoCoinEntity] = try await manager.request(endpoint: endpoint)
            XCTFail("Expected requestFailed")
        } catch NetworkError.requestFailed(let code) {
            XCTAssertEqual(code, 404)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testRequest_emptyDataThrowsNoData() async {
        let session = MockNetworkSession()
        let url = URL(string: "https://raw.githubusercontent.com/coins")!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        session.resultToReturn = .success((Data(), response))

        let manager = NetworkManager(session: session)
        let endpoint = Endpoint.createGETEndpoint(path: "/coins")

        do {
            let _: [CryptoCoinEntity] = try await manager.request(endpoint: endpoint)
            XCTFail("Expected noData")
        } catch NetworkError.noData {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testRequest_invalidJSONThrowsDecodingError() async {
        let session = MockNetworkSession()
        let url = URL(string: "https://raw.githubusercontent.com/coins")!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        session.resultToReturn = .success((Data("invalid-json".utf8), response))

        let manager = NetworkManager(session: session)
        let endpoint = Endpoint.createGETEndpoint(path: "/coins")

        do {
            let _: [CryptoCoinEntity] = try await manager.request(endpoint: endpoint)
            XCTFail("Expected decodingError")
        } catch NetworkError.decodingError {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testRequest_urlErrorOfflineMapsToNoInternet() async {
        let session = MockNetworkSession()
        session.resultToReturn = .failure(URLError(.notConnectedToInternet))

        let manager = NetworkManager(session: session)
        let endpoint = Endpoint.createGETEndpoint(path: "/coins")

        do {
            let _: [CryptoCoinEntity] = try await manager.request(endpoint: endpoint)
            XCTFail("Expected noInternet")
        } catch NetworkError.noInternet {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
