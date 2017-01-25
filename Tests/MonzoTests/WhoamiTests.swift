import XCTest
import S4
import Monzo

class WhoamiTests : XCTestCase {
    
    func test_whoamiRequestHasCorrectUri() {
        assertRequestUriEquals("https://api.monzo.com/ping/whoami", forClientAction: { sut in
            try sut.whoami()
        })
    }
    
    func test_givenAccessToken_thenTheRequestHasCorrectHeaders() {
        assertRequestHeadersEqual([
            "host": "api.monzo.com",
            "connection": "close",
            "authorization": "Bearer a_token"
            ], forClientAction: { sut in
                try sut.whoami(accessToken: "a_token")
        })
    }

    func test_givenNoAccessToken_thenTheRequestHasCorrectHeaders() {
        assertRequestHeadersEqual([
            "host": "api.monzo.com",
            "connection": "close"
            ], forClientAction: { sut in
                try sut.whoami()
        })
    }
    
    func test_whoamiRequestHasEmptyBody() {
        assertRequestBodyIsEmpty(forClientAction: { sut in
            try sut.whoami()
        })
    }

    func test_givenAnAuthenticatedResponse_thenCorrectAccessTokenInfoIsReturned() {
        assertParsing(forResponseBody: "{\"authenticated\":true,\"client_id\":\"a_client_id\",\"user_id\":\"a_user_id\"}", action: { sut in
            try sut.whoami(accessToken: "")
        }, assertions: { accessTokenInfo in
            guard case let .authenticated(clientId, userId) = accessTokenInfo else { XCTFail(#function); return }
            XCTAssertEqual(clientId, "a_client_id")
            XCTAssertEqual(userId, "a_user_id")
        })
    }
    
    func test_givenAnUnauthenticatedResponse_thenCorrectAccessTokenInfoIsReturned() {
        assertParsing(forResponseBody: "{\"authenticated\":false}", action: { sut in
            try sut.whoami(accessToken: "")
        }, assertions: { accessTokenInfo in
            guard case .notAuthenticated = accessTokenInfo else { XCTFail(#function); return }
        })
    }

    func test_givenAnInvalidResponseStatus_thenResponseErrorIsThrown() {
        assertThrows(forResponseStatus: .badRequest, action: { sut in
            try sut.whoami(accessToken: "")
        }, errorHandler: { error in
            guard case Monzo.ClientError.responseError(.badRequest) = error else { XCTFail(#function); return }
        })
    }

    func test_givenAnInvalidResponseBody_thenParsingErrorIsThrown() {
        assertThrows(forResponseBody: "{}", action: { sut in
            try sut.whoami(accessToken: "")
        }, errorHandler: { error in
            guard case Monzo.ClientError.parsingError = error else { XCTFail(#function); return }
        })
    }
    
    static var allTests : [(String, (WhoamiTests) -> () throws -> Void)] {
        return [
            ("test_whoamiRequestHasCorrectUri", test_whoamiRequestHasCorrectUri),
            ("test_givenAccessToken_thenTheRequestHasCorrectHeaders", test_givenAccessToken_thenTheRequestHasCorrectHeaders),
            ("test_givenNoAccessToken_thenTheRequestHasCorrectHeaders", test_givenNoAccessToken_thenTheRequestHasCorrectHeaders),
            ("test_whoamiRequestHasEmptyBody", test_whoamiRequestHasEmptyBody),
            ("test_givenAnAuthenticatedResponse_thenCorrectAccessTokenInfoIsReturned", test_givenAnAuthenticatedResponse_thenCorrectAccessTokenInfoIsReturned),
            ("test_givenAnUnauthenticatedResponse_thenCorrectAccessTokenInfoIsReturned", test_givenAnUnauthenticatedResponse_thenCorrectAccessTokenInfoIsReturned),
            ("test_givenAnInvalidResponseStatus_thenResponseErrorIsThrown", test_givenAnInvalidResponseStatus_thenResponseErrorIsThrown),
            ("test_givenAnInvalidResponseBody_thenParsingErrorIsThrown", test_givenAnInvalidResponseBody_thenParsingErrorIsThrown),
        ]
    }
    
}
