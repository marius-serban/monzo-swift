import XCTest
import S4
import Monzo

class BalanceTests : XCTestCase {
    
    func test_requestHasCorrectUri() {
        assertRequestUriEquals("https://api.monzo.com/balance", forClientAction: { sut in
            try sut.balance(accessToken: "")
        })
    }
    
    func test_requestHasCorrectHeaders() {
        assertRequestHeadersEqual([
            "host": "api.monzo.com",
            "connection": "close",
            "authorization": "Bearer a_token"
            ], forClientAction: { sut in
                try sut.balance(accessToken: "a_token")
        })
    }
    
    func test_requestHasEmptyBody() {
        assertRequestBodyIsEmpty(forClientAction: { sut in
            try sut.balance(accessToken: "")
        })
    }
    
    func test_givenASucessfulResponse_thenCorrectBalanceIsReturned() {
        assertParsing(forResponseBody: "{\"balance\":9223372036854775807,\"currency\":\"GBP\",\"spend_today\":-34250}", action: { sut in
            try sut.balance(accessToken: "")
        }, assertions: { balance in
            XCTAssertEqual(balance.balance, 9223372036854775807)
            XCTAssertEqual(balance.currency, "GBP")
            XCTAssertEqual(balance.spendToday, -34250)
        })
    }
    
    func test_givenAnInvalidResponseStatus_thenResponseErrorIsThrown() {
        assertThrows(forResponseStatus: .badRequest, action: { sut in
            try sut.balance(accessToken: "")
        }, errorHandler: { error in
            guard case Monzo.ClientError.responseError(.badRequest) = error else { XCTFail(#function); return }
        })
    }
    
    func test_givenAnInvalidResponseBody_thenParsingErrorIsThrown() {
        assertThrows(forResponseBody: "{}", action: { sut in
            try sut.balance(accessToken: "")
        }, errorHandler: { error in
            guard case Monzo.ClientError.parsingError = error else { XCTFail(#function); return }
        })
    }
    
    static var allTests : [(String, (BalanceTests) -> () throws -> Void)] {
        return [
            ("test_requestHasCorrectUri", test_requestHasCorrectUri),
            ("test_requestHasCorrectHeaders", test_requestHasCorrectHeaders),
            ("test_requestHasEmptyBody", test_requestHasEmptyBody),
            ("test_givenASucessfulResponse_thenCorrectBalanceIsReturned", test_givenASucessfulResponse_thenCorrectBalanceIsReturned),
            ("test_givenAnInvalidResponseStatus_thenResponseErrorIsThrown", test_givenAnInvalidResponseStatus_thenResponseErrorIsThrown),
            ("test_givenAnInvalidResponseBody_thenParsingErrorIsThrown", test_givenAnInvalidResponseBody_thenParsingErrorIsThrown),
        ]
    }
}
