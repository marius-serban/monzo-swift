import XCTest
import S4
import Monzo

class DeleteWebhookTests : XCTestCase {
    
    func test_requestHasCorrectMethod() {
        let method = request(forClientAction: { sut in
            try sut.deleteWebhook(accessToken: "", id: "")
        }).method
        
        XCTAssertEqual(method, Method.delete)
    }
    
    func test_requestHasCorrectUri() {
        let uri = request(forClientAction: { sut in
            try sut.deleteWebhook(accessToken: "", id: "a_webhook_id")
        }).uri
        
        XCTAssertEqual(uri.debugDescription, "https://api.monzo.com/webhooks/a_webhook_id")
    }
    
    func test_requestHasCorrectHeaders() {
        let headers = request(forClientAction: { sut in
            try sut.deleteWebhook(accessToken: "a_token", id: "")
        }).headers.headers
        
        XCTAssertEqual(headers, [
            "host": "api.monzo.com",
            "connection": "close",
            "authorization": "Bearer a_token"
            ])
    }
    
    func test_requestHasEmptyBody() {
        let body = requestBody(forClientAction: { sut in
            try sut.deleteWebhook(accessToken: "", id: "")
        })
        
        XCTAssertNotNil(body)
        XCTAssertTrue(body!.isEmpty)
    }
    
    func test_givenASucessfulResponse_thenNoExceptionIsThrown() {
        let sut = configuredClient(withResponseBody: "")
        
        do {
            try sut.deleteWebhook(accessToken: "", id: "")
        } catch {
            XCTFail(String(describing: error))
        }
    }
    
    func test_givenAnInvalidResponseStatus_thenResponseErrorIsThrown() {
        let sut = configuredClient(withResponseBody: "", responseStatus: .badRequest)
        
        XCTAssertThrowsError(try sut.deleteWebhook(accessToken: "", id: ""), #function) { error in
            guard case Monzo.ClientError.responseError(.badRequest) = error else { XCTFail(#function); return }
        }
    }
    
    static var allTests : [(String, (DeleteWebhookTests) -> () throws -> Void)] {
        return [
            ("test_requestHasCorrectMethod", test_requestHasCorrectMethod),
            ("test_requestHasCorrectUri", test_requestHasCorrectUri),
            ("test_requestHasCorrectHeaders", test_requestHasCorrectHeaders),
            ("test_requestHasEmptyBody", test_requestHasEmptyBody),
            ("test_givenASucessfulResponse_thenNoExceptionIsThrown", test_givenASucessfulResponse_thenNoExceptionIsThrown),
            ("test_givenAnInvalidResponseStatus_thenResponseErrorIsThrown", test_givenAnInvalidResponseStatus_thenResponseErrorIsThrown)
        ]
    }
}
