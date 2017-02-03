import XCTest
import S4
import Monzo
import Foundation

class TransactionTests : XCTestCase {
    
    func test_requestHasCorrectUri() {
        assertRequestUriEquals("https://api.monzo.com/transactions/txId1234", forClientAction: { sut in
            try sut.transaction(accessToken: "", id: "txId1234")
        })
    }
    
    func test_requestHasCorrectHeaders() {
        assertRequestHeadersEqual([
            "host": "api.monzo.com",
            "connection": "close",
            "authorization": "Bearer a_token"
            ], forClientAction: { sut in
                try sut.transaction(accessToken: "a_token", id: "")
        })
    }

    func test_requestHasEmptyBody() {
        assertRequestBodyIsEmpty(forClientAction: { sut in
            try sut.transaction(accessToken: "", id: "txId1234")
        })
    }

    func test_givenASucessfulResponse_thenCorrectTransactionIsReturned() {
        let jsonTransaction = contentsOfTextFile("JSON/Transaction.json")
        assertParsing(forResponseBody: jsonTransaction, action: { sut in
            try sut.transaction(accessToken: "", id: "")
        }, assertions: { transaction in
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
    
    static var allTests : [(String, (TransactionTests) -> () throws -> Void)] {
        return [
            ("test_requestHasCorrectUri", test_requestHasCorrectUri),
            ("test_requestHasCorrectHeaders", test_requestHasCorrectHeaders),
            ("test_requestHasEmptyBody", test_requestHasEmptyBody),
            ("test_givenASucessfulResponse_thenCorrectTransactionIsReturned", test_givenASucessfulResponse_thenCorrectTransactionIsReturned),
            ("test_givenAnInvalidResponseStatus_thenResponseErrorIsThrown", test_givenAnInvalidResponseStatus_thenResponseErrorIsThrown),
            ("test_givenAnInvalidResponseBody_thenParsingErrorIsThrown", test_givenAnInvalidResponseBody_thenParsingErrorIsThrown),
        ]
    }
}
