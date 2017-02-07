import XCTest
import S4
import Monzo

class AuthorizationTests : XCTestCase {
    
    func test_givenClientIdAndRedirectUriAndNonce_thenAuthorizationUriIsCorrect() {
        let uri = Client.authorizationUri(clientId: "aClientId", redirectUri: "http://host.com/?test=[]#fragment", nonce: "abc123")
        
        let uriString = uri.debugDescription
        XCTAssertTrue(uriString.hasPrefix("https://auth.getmondo.co.uk/?"))
        XCTAssertNotNil(uriString.range(of: "client_id=aClientId"))
        XCTAssertNotNil(uriString.range(of: "redirect_uri=http://host.com/?test=%5B%5D%23fragment"))
        XCTAssertNotNil(uriString.range(of: "state=abc123"))
    }
    
    static var allTests : [(String, (AuthorizationTests) -> () throws -> Void)] {
        return [
            ("test_givenClientIdAndRedirectUriAndNonce_thenAuthorizationUriIsCorrect", test_givenClientIdAndRedirectUriAndNonce_thenAuthorizationUriIsCorrect),
        ]
    }
}
