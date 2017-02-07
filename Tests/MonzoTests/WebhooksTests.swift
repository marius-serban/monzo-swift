import XCTest
import S4
import Monzo

class WebhooksTests : XCTestCase {
    
    func test_requestHasCorrectMethod() {
        let method = request(forClientAction: { sut in
            try sut.webhooks(accessToken: "", accountId: "")
        }).method
        
        XCTAssertEqual(method, Method.get)
    }
    
    func test_requestHasCorrectUri() {
        let uri = request(forClientAction: { sut in
            try sut.webhooks(accessToken: "", accountId: "an_account_id")
        }).uri
        
        XCTAssertEqual(uri.debugDescription, "https://api.monzo.com/webhooks?account_id=an_account_id")
    }
    
    func test_requestHasCorrectHeaders() {
        let headers = request(forClientAction: { sut in
            try sut.webhooks(accessToken: "a_token", accountId: "")
        }).headers.headers
        
        XCTAssertEqual(headers, [
            "host": "api.monzo.com",
            "connection": "close",
            "authorization": "Bearer a_token"
            ])
    }
    
    func test_requestHasEmptyBody() {
        let body = requestBody(forClientAction: { sut in
            try sut.webhooks(accessToken: "", accountId: "")
        })
        
        XCTAssertNotNil(body)
        XCTAssertTrue(body!.isEmpty)
    }
    
    func test_givenASucessfulResponse_thenCorrectWebhooksAreReturned() {
        let sut = configuredClient(withResponseBody: "{\"webhooks\":[{\"id\":\"webhook_00009Gp4y7Uo83DbCAq4qP\",\"account_id\":\"acc_000094YbZT50BLlMAqbRuj\",\"url\":\"http://host.domain/\"},{\"id\":\"webhook_00009Gp4yHfoHzreY8TRNh\",\"account_id\":\"acc_000094YbZT50BLlMAqbRuj\",\"url\":\"http://host.domain/\"}]}")
        
        do {
            let webhooks = try sut.webhooks(accessToken: "", accountId: "")
            XCTAssertEqual(webhooks.count, 2)
            let webhook = webhooks.first!
            XCTAssertEqual(webhook.id, "webhook_00009Gp4y7Uo83DbCAq4qP")
            XCTAssertEqual(webhook.accountId, "acc_000094YbZT50BLlMAqbRuj")
            XCTAssertEqual(webhook.url, "http://host.domain/")
        } catch {
            XCTFail(String(describing: error))
        }
    }
    
    func test_givenAnInvalidResponseStatus_thenResponseErrorIsThrown() {
        let sut = configuredClient(withResponseBody: "", responseStatus: .badRequest)
        
        XCTAssertThrowsError(try sut.webhooks(accessToken: "", accountId: ""), #function) { error in
            guard case Monzo.ClientError.responseError(.badRequest) = error else { XCTFail(#function); return }
        }
    }
    
    func test_givenAnInvalidResponseBody_thenParsingErrorIsThrown() {
        let sut = configuredClient(withResponseBody: "{}")
        
        XCTAssertThrowsError(try sut.webhooks(accessToken: "", accountId: ""), #function) { error in
            guard case Monzo.ClientError.parsingError = error else { XCTFail(#function); return }
        }
    }
    
    static var allTests : [(String, (WebhooksTests) -> () throws -> Void)] {
        return [
            ("test_requestHasCorrectMethod", test_requestHasCorrectMethod),
            ("test_requestHasCorrectUri", test_requestHasCorrectUri),
            ("test_requestHasCorrectHeaders", test_requestHasCorrectHeaders),
            ("test_requestHasEmptyBody", test_requestHasEmptyBody),
            ("test_givenASucessfulResponse_thenCorrectWebhooksAreReturned", test_givenASucessfulResponse_thenCorrectWebhooksAreReturned),
            ("test_givenAnInvalidResponseStatus_thenResponseErrorIsThrown", test_givenAnInvalidResponseStatus_thenResponseErrorIsThrown),
            ("test_givenAnInvalidResponseBody_thenParsingErrorIsThrown", test_givenAnInvalidResponseBody_thenParsingErrorIsThrown),
        ]
    }
}
