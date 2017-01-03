import XCTest
@testable import monzo_swift

class monzo_swiftTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(monzo_swift().text, "Hello, World!")
    }


    static var allTests : [(String, (monzo_swiftTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
