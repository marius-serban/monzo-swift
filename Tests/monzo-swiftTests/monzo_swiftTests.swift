import XCTest
import S4
@testable import monzo_swift

class monzo_swiftTests : XCTestCase {
    
    func test_givenAHttpClient_whenInitialialised_thenHttpClientIsSet() {
        let httpClient = StubHttpClient(response: fakeResponse)
        
        let sut = MonzoClient(httpClient: httpClient)
        
        XCTAssertTrue(sut.httpClient is StubHttpClient)
    }
    
    func test_givenClientIdAndRedirectUriAndNonce_whenGeneratingAuthenticationUri_thenAuthenticationUriIsCorrect() {
        guard let uri = try? MonzoClient.authenticationUri(clientId: "aClientId", redirectUri: "http://monzo.com/?test=[]#fragment", nonce: "abc123") else { XCTFail(#function); return }
        
        XCTAssertEqual(uri.scheme, "https")
        XCTAssertEqual(uri.host, "auth.getmondo.co.uk")
        XCTAssertEqual(uri.query, "client_id=aClientId&redirect_uri=http://monzo.com/?test=%5B%5D%23frag&state=abc123")
        XCTAssertNil(uri.userInfo)
        XCTAssertNil(uri.port)
        XCTAssertNil(uri.path)
        XCTAssertNil(uri.fragment)
    }
    
    static var allTests : [(String, (monzo_swiftTests) -> () throws -> Void)] {
        return [
            ("test_givenAHttpCleint_whenInitialised_thenHttpClientIsSet", test_givenAHttpClient_whenInitialialised_thenHttpClientIsSet),
            ("test_givenClientIdAndRedirectUriAndNonce_whenGeneratingAuthenticationUri_thenAuthenticationUriIsCorrect", test_givenClientIdAndRedirectUriAndNonce_whenGeneratingAuthenticationUri_thenAuthenticationUriIsCorrect),
        ]
    }
}

struct StubHttpClient : Responder {
    let response: Response
    
    func respond(to request: Request) throws -> Response {
        return response
    }
}

let fakeResponse = Response(version: Version(major: 0, minor: 0), status: .ok, headers: Headers(), cookieHeaders: [], body: .buffer([]))
