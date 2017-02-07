import XCTest
import S4
import Monzo

class BalanceTests : XCTestCase {
    
    func test_requestHasCorrectMethod() {
        let method = request(forClientAction: { sut in
            try sut.balance(accessToken: "", accountId: "")
        }).method
        
        XCTAssertEqual(method, Method.get)
    }
    
    func test_requestHasCorrectUri() {
        let uri = request(forClientAction: { sut in
            try sut.balance(accessToken: "", accountId: "test")
        }).uri
        
        XCTAssertEqual(uri.debugDescription, "https://api.monzo.com/balance?account_id=test")
    }
    
    func test_requestHasCorrectHeaders() {
        let headers = request(forClientAction: { sut in
            try sut.balance(accessToken: "a_token", accountId: "")
        }).headers.headers
        
        XCTAssertEqual(headers, [
            "host": "api.monzo.com",
            "connection": "close",
            "authorization": "Bearer a_token"
            ])
    }
    
    func test_requestHasEmptyBody() {
        let body = requestBody(forClientAction: { sut in
            try sut.balance(accessToken: "", accountId: "account1")
        })
        
        XCTAssertNotNil(body)
        XCTAssertTrue(body!.isEmpty)
    }
    
    func test_givenASucessfulResponse_thenCorrectBalanceIsReturned() {
        let sut = configuredClient(withResponseBody: "{\"balance\":9223372036854775807,\"currency\":\"GBP\",\"spend_today\":-34250}")
        
        do {
            let balance = try sut.balance(accessToken: "", accountId: "")
            XCTAssertEqual(balance.balance, 9223372036854775807)
            XCTAssertEqual(balance.currency, "GBP")
            XCTAssertEqual(balance.spendToday, -34250)
        } catch {
            XCTFail(String(describing: error))
        }
    }
    
    func test_givenAnInvalidResponseStatus_thenResponseErrorIsThrown() {
        let sut = configuredClient(withResponseBody: "", responseStatus: .badRequest)
        
        XCTAssertThrowsError(try sut.balance(accessToken: "", accountId: ""), #function) { error in
            guard case Monzo.ClientError.responseError(.badRequest) = error else { XCTFail(#function); return }
        }
    }
    
    func test_givenAnInvalidResponseBody_thenParsingErrorIsThrown() {
        let sut = configuredClient(withResponseBody: "{}")
        
        XCTAssertThrowsError(try sut.balance(accessToken: "", accountId: ""), #function) { error in
            guard case Monzo.ClientError.parsingError = error else { XCTFail(#function); return }
        }
    }
    
    static var allTests : [(String, (BalanceTests) -> () throws -> Void)] {
        return [
            ("test_requestHasCorrectMethod", test_requestHasCorrectMethod),
            ("test_requestHasCorrectUri", test_requestHasCorrectUri),
            ("test_requestHasCorrectHeaders", test_requestHasCorrectHeaders),
            ("test_requestHasEmptyBody", test_requestHasEmptyBody),
            ("test_givenASucessfulResponse_thenCorrectBalanceIsReturned", test_givenASucessfulResponse_thenCorrectBalanceIsReturned),
            ("test_givenAnInvalidResponseStatus_thenResponseErrorIsThrown", test_givenAnInvalidResponseStatus_thenResponseErrorIsThrown),
            ("test_givenAnInvalidResponseBody_thenParsingErrorIsThrown", test_givenAnInvalidResponseBody_thenParsingErrorIsThrown),
        ]
    }
}
