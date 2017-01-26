import XCTest
import S4
import Monzo

class AccountsTests : XCTestCase {
    
    func test_requestHasCorrectUri() {
        assertRequestUriEquals("https://api.monzo.com/accounts", forClientAction: { sut in
            try sut.accounts(accessToken: "")
        })
    }
    
    func test_requestHasCorrectHeaders() {
        assertRequestHeadersEqual([
            "host": "api.monzo.com",
            "connection": "close",
            "authorization": "Bearer a_token"
            ], forClientAction: { sut in
                try sut.accounts(accessToken: "a_token")
        })
    }
    
    func test_requestHasEmptyBody() {
        assertRequestBodyIsEmpty(forClientAction: { sut in
            try sut.accounts(accessToken: "")
        })
    }
    
    func test_givenASucessfulResponse_thenCorrectAccountsAreReturned() {
        assertParsing(forResponseBody: "{\"accounts\":[{\"id\":\"an_account_id\",\"created\":\"2016-01-26T18:42:04.924Z\",\"description\":\"this is a description\"}]}", action: { sut in
            try sut.accounts(accessToken: "")
        }, assertions: { accounts in
            XCTAssertEqual(accounts.count, 1)
            let account = accounts.first!
            XCTAssertEqual(account.id, "an_account_id")
            XCTAssertEqual(account.created.description, "2016-01-26 18:42:04 +0000")
            XCTAssertEqual(account.description, "this is a description")
        })
    }

    func test_givenAnInvalidResponseStatus_thenResponseErrorIsThrown() {
        assertThrows(forResponseStatus: .badRequest, action: { sut in
            try sut.accounts(accessToken: "")
        }, errorHandler: { error in
            guard case Monzo.ClientError.responseError(.badRequest) = error else { XCTFail(#function); return }
        })
    }

    func test_givenAnInvalidResponseBody_thenParsingErrorIsThrown() {
        assertThrows(forResponseBody: "{}", action: { sut in
            try sut.accounts(accessToken: "")
        }, errorHandler: { error in
            guard case Monzo.ClientError.parsingError = error else { XCTFail(#function); return }
        })
    }

    static var allTests : [(String, (AccountsTests) -> () throws -> Void)] {
        return [
            ("test_requestHasCorrectUri", test_requestHasCorrectUri),
            ("test_requestHasCorrectHeaders", test_requestHasCorrectHeaders),
            ("test_requestHasEmptyBody", test_requestHasEmptyBody),
            ("test_givenASucessfulResponse_thenCorrectAccountsAreReturned", test_givenASucessfulResponse_thenCorrectAccountsAreReturned),
            ("test_givenAnInvalidResponseStatus_thenResponseErrorIsThrown", test_givenAnInvalidResponseStatus_thenResponseErrorIsThrown),
            ("test_givenAnInvalidResponseBody_thenParsingErrorIsThrown", test_givenAnInvalidResponseBody_thenParsingErrorIsThrown),
        ]
    }
}
