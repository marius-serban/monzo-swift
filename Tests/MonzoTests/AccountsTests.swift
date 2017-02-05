import XCTest
import S4
import Monzo

class AccountsTests : XCTestCase {
    
    func test_requestHasCorrectMethod() {
        let method = request(forClientAction: { sut in
            try sut.accounts(accessToken: "")
        }).method
        
        XCTAssertEqual(method, Method.get)
    }
    
    func test_requestHasCorrectUri() {
        let uri = request(forClientAction: { sut in
            try sut.accounts(accessToken: "")
        }).uri
        
        XCTAssertEqual(uri.description, "https://api.monzo.com/accounts")
    }
    
    func test_requestHasCorrectHeaders() {
        let headers = request(forClientAction: { sut in
            try sut.accounts(accessToken: "a_token")
        }).headers.headers
        
        XCTAssertEqual(headers, [
            "host": "api.monzo.com",
            "connection": "close",
            "authorization": "Bearer a_token"
            ])
    }
    
    func test_requestHasEmptyBody() {
        let body = requestBody(forClientAction: { sut in
            try sut.accounts(accessToken: "")
        })
        
        XCTAssertNotNil(body)
        XCTAssertTrue(body!.isEmpty)
    }
    
    func test_givenASucessfulResponse_thenCorrectAccountsAreReturned() {
        let sut = configuredClient(withResponseBody: "{\"accounts\":[{\"id\":\"an_account_id\",\"created\":\"2016-01-26T18:42:04.924Z\",\"description\":\"this is a description\"}]}")
        
        do {
            let accounts = try sut.accounts(accessToken: "")
            XCTAssertEqual(accounts.count, 1)
            let account = accounts.first!
            XCTAssertEqual(account.id, "an_account_id")
            XCTAssertEqual(account.created.description, "2016-01-26 18:42:04 +0000")
            XCTAssertEqual(account.description, "this is a description")
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func test_givenAnInvalidResponseStatus_thenResponseErrorIsThrown() {
        let sut = configuredClient(withResponseBody: "", responseStatus: .badRequest)
        
        XCTAssertThrowsError(try sut.accounts(accessToken: ""), #function) { error in
            guard case Monzo.ClientError.responseError(.badRequest) = error else { XCTFail(#function); return }
        }
    }

    func test_givenAnInvalidResponseBody_thenParsingErrorIsThrown() {
        let sut = configuredClient(withResponseBody: "{}")
        
        XCTAssertThrowsError(try sut.accounts(accessToken: ""), #function) { error in
            guard case Monzo.ClientError.parsingError = error else { XCTFail(#function); return }
        }
    }

    static var allTests : [(String, (AccountsTests) -> () throws -> Void)] {
        return [
            ("test_requestHasCorrectMethod", test_requestHasCorrectMethod),
            ("test_requestHasCorrectUri", test_requestHasCorrectUri),
            ("test_requestHasCorrectHeaders", test_requestHasCorrectHeaders),
            ("test_requestHasEmptyBody", test_requestHasEmptyBody),
            ("test_givenASucessfulResponse_thenCorrectAccountsAreReturned", test_givenASucessfulResponse_thenCorrectAccountsAreReturned),
            ("test_givenAnInvalidResponseStatus_thenResponseErrorIsThrown", test_givenAnInvalidResponseStatus_thenResponseErrorIsThrown),
            ("test_givenAnInvalidResponseBody_thenParsingErrorIsThrown", test_givenAnInvalidResponseBody_thenParsingErrorIsThrown),
        ]
    }
}
