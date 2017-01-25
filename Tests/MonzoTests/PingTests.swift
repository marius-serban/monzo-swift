import XCTest
import S4
import Monzo

class PingTests : XCTestCase {
    
    func test_requestHasCorrectUri() {
        assertRequestUriEquals("https://api.monzo.com/ping", forClientAction: { sut in
            try sut.ping()
        })
    }
    
    func test_givenAccessToken_thenTheRequestHasCorrectHeaders() {
        assertRequestHeadersEqual([
            "host": "api.monzo.com",
            "connection": "close",
            "authorization": "Bearer a_token"
            ], forClientAction: { sut in
                try sut.ping(accessToken: "a_token")
        })
    }
    
    func test_givenNoAccessToken_thenTheRequestHasCorrectHeaders() {
        assertRequestHeadersEqual([
            "host": "api.monzo.com",
            "connection": "close"
            ], forClientAction: { sut in
                try sut.ping()
        })
    }
    
    func test_requestHasEmptyBody() {
        assertRequestBodyIsEmpty(forClientAction: { sut in
            try sut.ping()
        })
    }
    
    func test_givenASuccessfulResponse_thenNoExceptionIsThrown() {
        assertParsing(forResponseBody: "{\"ping\":\"pong\"}", action: { sut in
            try sut.ping(accessToken: "")
        }, assertions: nil)
    }
    
    func test_givenAnInvalidResponseStatus_thenResponseErrorIsThrown() {
        assertThrows(forResponseStatus: .badRequest, action: { sut in
            try sut.ping(accessToken: "")
        }, errorHandler: { error in
            guard case Monzo.ClientError.responseError(.badRequest) = error else { XCTFail(#function); return }
        })
    }
    
    func test_givenAnInvalidResponseBody_thenParsingErrorIsThrown() {
        assertThrows(forResponseBody: "{}", action: { sut in
            try sut.ping(accessToken: "")
        }, errorHandler: { error in
            guard case Monzo.ClientError.parsingError = error else { XCTFail(#function); return }
        })
    }
    
    static var allTests : [(String, (PingTests) -> () throws -> Void)] {
        return [
            ("test_requestHasCorrectUri", test_requestHasCorrectUri),
            ("test_givenAccessToken_thenTheRequestHasCorrectHeaders", test_givenAccessToken_thenTheRequestHasCorrectHeaders),
            ("test_givenNoAccessToken_thenTheRequestHasCorrectHeaders", test_givenNoAccessToken_thenTheRequestHasCorrectHeaders),
            ("test_requestHasEmptyBody", test_requestHasEmptyBody),
            ("test_givenASuccessfulResponse_thenNoExceptionIsThrown", test_givenASuccessfulResponse_thenNoExceptionIsThrown),
            ("test_givenAnInvalidResponseStatus_thenResponseErrorIsThrown", test_givenAnInvalidResponseStatus_thenResponseErrorIsThrown),
            ("test_givenAnInvalidResponseBody_thenParsingErrorIsThrown", test_givenAnInvalidResponseBody_thenParsingErrorIsThrown),
        ]
    }
    
}
