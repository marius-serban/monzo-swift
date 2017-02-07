import XCTest
import S4
import Monzo

class PingTests : XCTestCase {
    
    func test_requestHasCorrectMethod() {
        let method = request(forClientAction: { sut in
            try sut.ping()
        }).method
        
        XCTAssertEqual(method, Method.get)
    }
    
    func test_requestHasCorrectUri() {
        let uri = request(forClientAction: { sut in
            try sut.ping()
        }).uri
        
        XCTAssertEqual(uri.debugDescription, "https://api.monzo.com/ping")
    }
    
    func test_givenAccessToken_thenTheRequestHasCorrectHeaders() {
        let headers = request(forClientAction: { sut in
            try sut.ping(accessToken: "a_token")
        }).headers.headers
        
        XCTAssertEqual(headers, [
            "host": "api.monzo.com",
            "connection": "close",
            "authorization": "Bearer a_token"
            ])
    }
    
    func test_givenNoAccessToken_thenTheRequestHasCorrectHeaders() {
        let headers = request(forClientAction: { sut in
            try sut.ping()
        }).headers.headers
        
        XCTAssertEqual(headers, [
            "host": "api.monzo.com",
            "connection": "close"
            ])
    }
    
    func test_requestHasEmptyBody() {
        let body = requestBody(forClientAction: { sut in
            try sut.ping()
        })
        
        XCTAssertNotNil(body)
        XCTAssertTrue(body!.isEmpty)
    }
    
    func test_givenASuccessfulResponse_thenNoExceptionIsThrown() {
        let sut = configuredClient(withResponseBody: "{\"ping\":\"pong\"}")
        
        do {
            try sut.ping(accessToken: "")
        } catch {
            XCTFail(String(describing: error))
        }
    }
    
    func test_givenAnInvalidResponseStatus_thenResponseErrorIsThrown() {
        let sut = configuredClient(withResponseBody: "", responseStatus: .badRequest)
        
        XCTAssertThrowsError(try sut.ping(accessToken: ""), #function) { error in
            guard case Monzo.ClientError.responseError(.badRequest) = error else { XCTFail(#function); return }
        }
    }
    
    func test_givenAnInvalidResponseBody_thenParsingErrorIsThrown() {
        let sut = configuredClient(withResponseBody: "{}")
        
        XCTAssertThrowsError(try sut.ping(accessToken: ""), #function) { error in
            guard case Monzo.ClientError.parsingError = error else { XCTFail(#function); return }
        }
    }
    
    static var allTests : [(String, (PingTests) -> () throws -> Void)] {
        return [
            ("test_requestHasCorrectMethod", test_requestHasCorrectMethod),
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
