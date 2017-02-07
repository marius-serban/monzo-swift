import XCTest
import S4
import Monzo

class CreateWebhookTests : XCTestCase {
    
    func test_requestHasCorrectMethod() {
        let method = request(forClientAction: { sut in
            try sut.createWebhook(accessToken: "", accountId: "", url: "")
        }).method
        
        XCTAssertEqual(method, Method.post)
    }
    
    func test_requestHasCorrectUri() {
        let uri = request(forClientAction: { sut in
            try sut.createWebhook(accessToken: "", accountId: "", url: "")
        }).uri
        
        XCTAssertEqual(uri.debugDescription, "https://api.monzo.com/webhooks")
    }
    
    func test_requestHasCorrectHeaders() {
        let headers = request(forClientAction: { sut in
            try sut.createWebhook(accessToken: "a_token", accountId: "", url: "")
        }).headers.headers
        
        XCTAssertEqual(headers, [
            "host": "api.monzo.com",
            "connection": "close",
            "content-type": "application/x-www-form-urlencoded; charset=utf-8",
            "authorization": "Bearer a_token"
            ])
    }
    
    func test_givenMetadata_thenRequestHasCorrectBody() {
        let body = requestBody(forClientAction: { sut in
            try sut.createWebhook(accessToken: "", accountId: "an_account_id", url: "http://host.domain/path?param1=1&param2=2")
        })
        
        XCTAssertNotNil(body?.range(of: "account_id=an_account_id"))
        XCTAssertNotNil(body?.range(of: "url=http%3A%2F%2Fhost.domain%2Fpath%3Fparam1%3D1%26param2%3D2"))
    }
    
    func test_givenASucessfulResponse_thenCorrectWebhookIsReturned() {
        let sut = configuredClient(withResponseBody: "{\"webhook\":{\"id\":\"webhook_00009Gp4yR1PX2LjWqOpzl\",\"account_id\":\"acc_000094YbZT50BLlMAqbRuj\",\"url\":\"http://host.domain/path?query=1&param1=2\"}}")
        
        do {
            let webhook = try sut.createWebhook(accessToken: "a_token", accountId: "", url: "")
            XCTAssertEqual(webhook.id, "webhook_00009Gp4yR1PX2LjWqOpzl")
            XCTAssertEqual(webhook.accountId, "acc_000094YbZT50BLlMAqbRuj")
            XCTAssertEqual(webhook.url, "http://host.domain/path?query=1&param1=2")
        } catch {
            XCTFail(String(describing: error))
        }
    }
    
    func test_givenAnInvalidResponseStatus_thenResponseErrorIsThrown() {
        let sut = configuredClient(withResponseBody: "", responseStatus: .badRequest)
        
        XCTAssertThrowsError(try sut.createWebhook(accessToken: "", accountId: "", url: ""), #function) { error in
            guard case Monzo.ClientError.responseError(.badRequest) = error else { XCTFail(#function); return }
        }
    }
    
    func test_givenAnInvalidResponseBody_thenParsingErrorIsThrown() {
        let sut = configuredClient(withResponseBody: "{}")
        
        XCTAssertThrowsError(try sut.createWebhook(accessToken: "", accountId: "", url: ""), #function) { error in
            guard case Monzo.ClientError.parsingError = error else { XCTFail(#function); return }
        }
    }
    
    static var allTests : [(String, (CreateWebhookTests) -> () throws -> Void)] {
        return [
            ("test_requestHasCorrectMethod", test_requestHasCorrectMethod),
            ("test_requestHasCorrectUri", test_requestHasCorrectUri),
            ("test_requestHasCorrectHeaders", test_requestHasCorrectHeaders),
            ("test_givenMetadata_thenRequestHasCorrectBody", test_givenMetadata_thenRequestHasCorrectBody),
            ("test_givenASucessfulResponse_thenCorrectWebhookIsReturned", test_givenASucessfulResponse_thenCorrectWebhookIsReturned),
            ("test_givenAnInvalidResponseStatus_thenResponseErrorIsThrown", test_givenAnInvalidResponseStatus_thenResponseErrorIsThrown),
            ("test_givenAnInvalidResponseBody_thenParsingErrorIsThrown", test_givenAnInvalidResponseBody_thenParsingErrorIsThrown)
        ]
    }
}
