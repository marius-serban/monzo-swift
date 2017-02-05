import XCTest
import S4
import Monzo

class WhoamiTests : XCTestCase {
    
    func test_requestHasCorrectMethod() {
        let method = request(forClientAction: { sut in
            try sut.whoami()
        }).method
        
        XCTAssertEqual(method, Method.get)
    }
    
    func test_whoamiRequestHasCorrectUri() {
        let uri = request(forClientAction: { sut in
            try sut.whoami()
        }).uri
        
        XCTAssertEqual(uri.description, "https://api.monzo.com/ping/whoami")
    }
    
    func test_givenAccessToken_thenTheRequestHasCorrectHeaders() {
        let headers = request(forClientAction: { sut in
            try sut.whoami(accessToken: "a_token")
        }).headers.headers
        
        XCTAssertEqual(headers, [
            "host": "api.monzo.com",
            "connection": "close",
            "authorization": "Bearer a_token"
            ])
    }

    func test_givenNoAccessToken_thenTheRequestHasCorrectHeaders() {
        let headers = request(forClientAction: { sut in
            try sut.whoami()
        }).headers.headers
        
        XCTAssertEqual(headers, [
            "host": "api.monzo.com",
            "connection": "close"
            ])
    }
    
    func test_whoamiRequestHasEmptyBody() {
        let body = requestBody(forClientAction: { sut in
            try sut.whoami()
        })
        
        XCTAssertNotNil(body)
        XCTAssertTrue(body!.isEmpty)
    }

    func test_givenAnAuthenticatedResponse_thenCorrectAccessTokenInfoIsReturned() {
        let sut = configuredClient(withResponseBody: "{\"authenticated\":true,\"client_id\":\"a_client_id\",\"user_id\":\"a_user_id\"}")
        
        do {
            let accessTokenInfo = try sut.whoami(accessToken: "")
            guard case let .authenticated(clientId, userId) = accessTokenInfo else { XCTFail(#function); return }
            XCTAssertEqual(clientId, "a_client_id")
            XCTAssertEqual(userId, "a_user_id")
        } catch {
            XCTFail(String(describing: error))
        }
    }
    
    func test_givenAnUnauthenticatedResponse_thenCorrectAccessTokenInfoIsReturned() {
        let sut = configuredClient(withResponseBody: "{\"authenticated\":false}")
        
        do {
            let accessTokenInfo = try sut.whoami(accessToken: "")
            guard case .notAuthenticated = accessTokenInfo else { XCTFail(#function); return }
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func test_givenAnInvalidResponseStatus_thenResponseErrorIsThrown() {
        let sut = configuredClient(withResponseBody: "", responseStatus: .badRequest)
        
        XCTAssertThrowsError(try sut.whoami(accessToken: ""), #function) { error in
            guard case Monzo.ClientError.responseError(.badRequest) = error else { XCTFail(#function); return }
        }
    }

    func test_givenAnInvalidResponseBody_thenParsingErrorIsThrown() {
        let sut = configuredClient(withResponseBody: "{}")
        
        XCTAssertThrowsError(try sut.whoami(accessToken: ""), #function) { error in
            guard case Monzo.ClientError.parsingError = error else { XCTFail(#function); return }
        }
    }
    
    static var allTests : [(String, (WhoamiTests) -> () throws -> Void)] {
        return [
            ("test_requestHasCorrectMethod", test_requestHasCorrectMethod),
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
