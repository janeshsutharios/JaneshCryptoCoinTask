import XCTest
@testable import Common

final class CommonTests: XCTestCase {

    func testLocalizationFallback_returnsDefaultValue() {
        let result = Localization.localizedString(for: "nonexistent_key_xyz", defaultValue: "Fallback")
        XCTAssertEqual(result, "Fallback")
    }

    func testLocalizationWithFormatArgs_formatsDefaultString() {
        let result = Localization.localizedString(for: "nonexistent_fmt_xyz", defaultValue: "Hello %@", args: "World")
        XCTAssertEqual(result, "Hello World")
    }

    func testReachability_protocolConformanceDoesNotCrash() {
        let reachability: any NetworkReachabilityProtocol = Reachability()
        let connected = reachability.isConnectedToNetwork()
        XCTAssertTrue(connected == true || connected == false)
    }
}
