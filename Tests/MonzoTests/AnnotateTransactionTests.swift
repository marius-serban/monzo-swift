import XCTest
import S4
import Monzo

class AnnotateTransactionTests : XCTestCase {
    
    func test_requestHasCorrectMethod() {
        let method = request(forClientAction: { sut in
            try sut.annotate(transaction: "txId1234", with: [:], accessToken: "")
        }).method
        
        XCTAssertEqual(method, Method.patch)
    }
    
    func test_requestHasCorrectUri() {
        let uri = request(forClientAction: { sut in
            try sut.annotate(transaction: "txId1234", with: [:], accessToken: "")
        }).uri
        
        XCTAssertEqual(uri.description, "https://api.monzo.com/transactions/txId1234")
    }

    func test_requestHasCorrectHeaders() {
        let headers = request(forClientAction: { sut in
            try sut.annotate(transaction: "", with: [:], accessToken: "a_token")
        }).headers.headers
        
        XCTAssertEqual(headers, [
            "host": "api.monzo.com",
            "connection": "close",
            "content-type": "application/x-www-form-urlencoded; charset=utf-8",
            "authorization": "Bearer a_token"
            ])
    }

    func test_requestHasCorrectBody() {
        let body = requestBody(forClientAction: { sut in
            try sut.annotate(transaction: "txId1234", with: ["key1": "value1", "key2": "value2"], accessToken: "")
        })
        
        XCTAssertNotNil(body?.range(of: "metadata[key1]=value1"))
        XCTAssertNotNil(body?.range(of: "metadata[key2]=value2"))
    }

    func test_givenASucessfulResponse_thenNoExceptionIsThrown() {
        let sut = configuredClient(withResponseBody: "")
        
        do {
            try sut.annotate(transaction: "", with: [:], accessToken: "")
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func test_givenAnInvalidResponseStatus_thenResponseErrorIsThrown() {
        let sut = configuredClient(withResponseBody: "", responseStatus: .badRequest)
        
        XCTAssertThrowsError(try sut.annotate(transaction: "", with: [:], accessToken: ""), #function) { error in
            guard case Monzo.ClientError.responseError(.badRequest) = error else { XCTFail(#function); return }
        }
    }

    static var allTests : [(String, (AnnotateTransactionTests) -> () throws -> Void)] {
        return [
            ("test_requestHasCorrectMethod", test_requestHasCorrectMethod),
            ("test_requestHasCorrectUri", test_requestHasCorrectUri),
            ("test_requestHasCorrectHeaders", test_requestHasCorrectHeaders),
            ("test_requestHasCorrectBody", test_requestHasCorrectBody),
            ("test_givenASucessfulResponse_thenNoExceptionIsThrown", test_givenASucessfulResponse_thenNoExceptionIsThrown),
            ("test_givenAnInvalidResponseStatus_thenResponseErrorIsThrown", test_givenAnInvalidResponseStatus_thenResponseErrorIsThrown)
        ]
    }
}
