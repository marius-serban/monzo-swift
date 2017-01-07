import XCTest
import S4
@testable import monzo_swift

class monzo_swiftTests: XCTestCase {
    
    func test_givenAHttpClient_whenInitialialised_thenHttpClientIsSet() {
        let httpClient = StubHttpClient(response: fakeResponse)
        
        let sut = MonzoClient(httpClient: httpClient)
        
        XCTAssertTrue(sut.httpClient is StubHttpClient)
    }
    
    static var allTests : [(String, (monzo_swiftTests) -> () throws -> Void)] {
        return [
            ("test_givenAHttpCleint_whenInitialised_thenHttpClientIsSet", test_givenAHttpClient_whenInitialialised_thenHttpClientIsSet),
        ]
    }
}

struct StubHttpClient: Responder {
    let response: Response
    
    func respond(to request: Request) throws -> Response {
        return response
    }
}

let fakeResponse = Response(version: Version(major: 0, minor: 0), status: .ok, headers: Headers(), cookieHeaders: [], body: .buffer([]))
