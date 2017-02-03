import XCTest
import S4
import Monzo
import Foundation

class TransactionsTests : XCTestCase {
    
    func test_givenNoPaginationOrFilter_requestHasCorrectUri() {
        assertRequestUriEquals("https://api.monzo.com/transactions?account_id=test", forClientAction: { sut in
            try sut.transactions(accessToken: "", accountId: "test")
        })
    }
    
    func test_givenBeforeFilter_requestHasCorrectUri() {
        assertRequestUriContains("before=1970-01-01T00:00:00.00Z", forClientAction: { sut in
            let epoch = Date(timeIntervalSince1970: 0)
            _ = try sut.transactions(accessToken: "", accountId: "test", before: epoch)
        })
    }
    
    func test_givenSinceDateFilter_requestHasCorrectUri() {
        assertRequestUriContains("since=1970-01-01T00:00:00.00Z", forClientAction: { sut in
            let epoch = Date(timeIntervalSince1970: 0)
            _ = try sut.transactions(accessToken: "", accountId: "test", since: .date(epoch))
        })
    }
    
    func test_givenSinceTransactionFilter_requestHasCorrectUri() {
        assertRequestUriContains("since=txid1234", forClientAction: { sut in
            try sut.transactions(accessToken: "", accountId: "test", since: .transaction("txid1234"))
        })
    }
    
    func test_givenPagination_requestHasCorrectUri() {
        assertRequestUriContains("limit=1", forClientAction: { sut in
            try sut.transactions(accessToken: "", accountId: "test", limit: 1)
        })
    }
    
    func test_requestHasCorrectHeaders() {
        assertRequestHeadersEqual([
            "host": "api.monzo.com",
            "connection": "close",
            "authorization": "Bearer a_token"
            ], forClientAction: { sut in
                try sut.transactions(accessToken: "a_token", accountId: "")
        })
    }

    func test_requestHasEmptyBody() {
        assertRequestBodyIsEmpty(forClientAction: { sut in
            try sut.transactions(accessToken: "", accountId: "account1")
        })
    }

    func test_givenASucessfulResponse_thenCorrectTransactionsAreReturned() {
        let jsonTransactions = contentsOfTextFile("JSON/Transactions.json")
        assertParsing(forResponseBody: jsonTransactions, action: { sut in
            try sut.transactions(accessToken: "", accountId: "")
        }, assertions: { transactions in
            XCTAssertEqual(transactions.count, 2)
            let transaction = transactions[1]
            XCTAssertEqual(transaction.id, "tx_00009GlgnSAVwnFhXZG4wL")
            XCTAssertEqual(transaction.created.description, "2017-01-25 10:48:40 +0000")
            XCTAssertEqual(transaction.description, "OFFLINE - TFL.GOV.UK/CP\\VICTORIA STREET\\TFL TRAVEL CH\\SW1H 0TL     GBR")
            XCTAssertEqual(transaction.amount, -390)
            XCTAssertEqual(transaction.currency, "GBP")
            XCTAssertEqual(transaction.merchant, "merch_0000987lak9C9IRzz93Xaj")
            XCTAssertEqual(transaction.notes, "Travel charge for Tuesday, 24 Jan")
            XCTAssertEqual(transaction.metadata, ["notes": "Travel charge for Tuesday, 24 Jan"])
            XCTAssertEqual(transaction.accountBalance, 15492)
            XCTAssertEqual(transaction.category, "transport")
            XCTAssertEqual(transaction.isLoad, false)
            XCTAssertEqual(transaction.settled.description, "2017-01-25 10:48:40 +0000")
            XCTAssertEqual(transaction.localAmount, -390)
            XCTAssertEqual(transaction.localCurrency, "GBP")
            XCTAssertEqual(transaction.updated.description, "2017-01-26 00:37:06 +0000")
            XCTAssertEqual(transaction.accountId, "acc_000094YbZT50BLlMAqbRuj")
            XCTAssertEqual(transaction.scheme, "gps_mastercard")
            XCTAssertEqual(transaction.dedupeId, "232813878170125840997523065")
            XCTAssertEqual(transaction.originator, false)
            XCTAssertEqual(transaction.includeInSpending, true)
        })
    }

    func test_givenAnInvalidResponseStatus_thenResponseErrorIsThrown() {
        assertThrows(forResponseStatus: .badRequest, action: { sut in
            try sut.transactions(accessToken: "", accountId: "")
        }, errorHandler: { error in
            guard case Monzo.ClientError.responseError(.badRequest) = error else { XCTFail(#function); return }
        })
    }

    func test_givenAnInvalidResponseBody_thenParsingErrorIsThrown() {
        assertThrows(forResponseBody: "{}", action: { sut in
            try sut.transactions(accessToken: "", accountId: "")
        }, errorHandler: { error in
            guard case Monzo.ClientError.parsingError = error else { XCTFail(#function); return }
        })
    }
    
    static var allTests : [(String, (TransactionsTests) -> () throws -> Void)] {
        return [
            ("test_givenNoPaginationOrFilter_requestHasCorrectUri", test_givenNoPaginationOrFilter_requestHasCorrectUri),
            ("test_givenBeforeFilter_requestHasCorrectUri", test_givenBeforeFilter_requestHasCorrectUri),
            ("test_givenSinceDateFilter_requestHasCorrectUri", test_givenSinceDateFilter_requestHasCorrectUri),
            ("test_givenSinceTransactionFilter_requestHasCorrectUri", test_givenSinceTransactionFilter_requestHasCorrectUri),
            ("test_givenPagination_requestHasCorrectUri", test_givenPagination_requestHasCorrectUri),
            ("test_requestHasCorrectHeaders", test_requestHasCorrectHeaders),
            ("test_requestHasEmptyBody", test_requestHasEmptyBody),
            ("test_givenASucessfulResponse_thenCorrectTransactionsAreReturned", test_givenASucessfulResponse_thenCorrectTransactionsAreReturned),
            ("test_givenAnInvalidResponseStatus_thenResponseErrorIsThrown", test_givenAnInvalidResponseStatus_thenResponseErrorIsThrown),
            ("test_givenAnInvalidResponseBody_thenParsingErrorIsThrown", test_givenAnInvalidResponseBody_thenParsingErrorIsThrown),
        ]
    }
}
