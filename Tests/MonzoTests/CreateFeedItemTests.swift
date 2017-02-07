import XCTest
import S4
import Monzo

class CreateFeedItemTests : XCTestCase {
    
    func test_requestHasCorrectMethod() {
        let method = request(forClientAction: { sut in
            try sut.createFeedItem(accessToken: "", accountId: "", title: "", imageUrl: "")
        }).method
        
        XCTAssertEqual(method, Method.post)
    }
    
    func test_requestHasCorrectUri() {
        let uri = request(forClientAction: { sut in
            try sut.createFeedItem(accessToken: "", accountId: "", title: "", imageUrl: "")
        }).uri
        
        XCTAssertEqual(uri.debugDescription, "https://api.monzo.com/feed")
    }
    
    func test_requestHasCorrectHeaders() {
        let headers = request(forClientAction: { sut in
            try sut.createFeedItem(accessToken: "a_token", accountId: "", title: "", imageUrl: "")
        }).headers.headers
        
        XCTAssertEqual(headers, [
            "host": "api.monzo.com",
            "connection": "close",
            "content-type": "application/x-www-form-urlencoded; charset=utf-8",
            "authorization": "Bearer a_token"
            ])
    }
    
    func test_givenAllParameters_thenRequestHasCorrectBody() {
        let body = requestBody(forClientAction: { sut in
            try sut.createFeedItem(accessToken: "", accountId: "an_account_id", title: "happy days! 🕺🏽", imageUrl: "http://images.domain/an-image.jpeg?param=j&other=k", url: "http://my.website/?param1=1&param2=2", body: "this is a sample body", backgroundColor: "#FFFFFF", bodyColor: "#AAAAAA", titleColor: "#BBBBBB")
        })
        
        XCTAssertNotNil(body?.range(of: "account_id=an_account_id"))
        XCTAssertNotNil(body?.range(of: "params[title]=happy+days%21+%F0%9F%95%BA%F0%9F%8F%BD"))
        XCTAssertNotNil(body?.range(of: "params[image_url]=http%3A%2F%2Fimages.domain%2Fan-image.jpeg%3Fparam%3Dj%26other%3Dk"))
        XCTAssertNotNil(body?.range(of: "url=http%3A%2F%2Fmy.website%2F%3Fparam1%3D1%26param2%3D2"))
        XCTAssertNotNil(body?.range(of: "params[body]=this+is+a+sample+body"))
        XCTAssertNotNil(body?.range(of: "params[background_color]=%23FFFFFF"))
        XCTAssertNotNil(body?.range(of: "params[body_color]=%23AAAAAA"))
        XCTAssertNotNil(body?.range(of: "params[title_color]=%23BBBBBB"))
    }
    
    func test_givenASucessfulResponse_thenNoExceptionIsThrown() {
        let sut = configuredClient(withResponseBody: "")
        
        do {
            try sut.createFeedItem(accessToken: "", accountId: "", title: "", imageUrl: "")
        } catch {
            XCTFail(String(describing: error))
        }
    }
    
    func test_givenAnInvalidResponseStatus_thenResponseErrorIsThrown() {
        let sut = configuredClient(withResponseBody: "", responseStatus: .badRequest)
        
        XCTAssertThrowsError(try sut.createFeedItem(accessToken: "", accountId: "", title: "", imageUrl: ""), #function) { error in
            guard case Monzo.ClientError.responseError(.badRequest) = error else { XCTFail(#function); return }
        }
    }
    
    static var allTests : [(String, (CreateFeedItemTests) -> () throws -> Void)] {
        return [
            ("test_requestHasCorrectMethod", test_requestHasCorrectMethod),
            ("test_requestHasCorrectUri", test_requestHasCorrectUri),
            ("test_requestHasCorrectHeaders", test_requestHasCorrectHeaders),
            ("test_givenAllParameters_thenRequestHasCorrectBody", test_givenAllParameters_thenRequestHasCorrectBody),
            ("test_givenASucessfulResponse_thenNoExceptionIsThrown", test_givenASucessfulResponse_thenNoExceptionIsThrown),
            ("test_givenAnInvalidResponseStatus_thenResponseErrorIsThrown", test_givenAnInvalidResponseStatus_thenResponseErrorIsThrown)
        ]
    }
}
