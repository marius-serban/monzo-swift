import XCTest
import S4
@testable import Monzo

class ClientGlobalTests : XCTestCase {
    
    func test_givenAHttpClient_whenInitialialised_thenHttpClientIsSet() {
        let httpClient = StubHttpClient()
        
        let sut = Monzo.Client(httpClient: httpClient)
        
        XCTAssertTrue(sut.httpClient is StubHttpClient)
    }
    
    func test_givenClientIdAndRedirectUriAndNonce_whenGeneratingAuthorizationUri_thenAuthorizationUriIsCorrect() {
        guard let uri = try? Client.authorizationUri(clientId: "aClientId", redirectUri: "http://monzo.com/?test=[]#fragment", nonce: "abc123") else { XCTFail(#function); return }
        
        XCTAssertEqual(uri.description, "https://auth.getmondo.co.uk/?client_id=aClientId&redirect_uri=http://monzo.com/?test=%5B%5D%23fragment&state=abc123")
    }
    
    static var allTests : [(String, (ClientGlobalTests) -> () throws -> Void)] {
        return [
            ("test_givenAHttpCleint_whenInitialised_thenHttpClientIsSet", test_givenAHttpClient_whenInitialialised_thenHttpClientIsSet),
            ("test_givenClientIdAndRedirectUriAndNonce_whenGeneratingAuthorizationUri_thenAuthorizationUriIsCorrect", test_givenClientIdAndRedirectUriAndNonce_whenGeneratingAuthorizationUri_thenAuthorizationUriIsCorrect),
        ]
    }
}
