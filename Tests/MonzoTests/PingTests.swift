import XCTest
import S4
import Monzo

class PingTests : XCTestCase {
    
    func test_givenPingParameters_whenPinging_thenTheRequestHasCorrectUri() {
        let spyHttpClient = SpyHttpClient()
        let sut = Monzo.Client(httpClient: spyHttpClient)
        
        try? sut.ping(accessToken: "")
        
        let uri = spyHttpClient.lastCapturedRequest.uri
        XCTAssertEqual(uri.description, "https://api.monzo.com/ping")
    }
    
    func test_givenAccessToken_whenPinging_thenTheRequestHasCorrectHeaders() {
        let spyHttpClient = SpyHttpClient()
        let sut = Monzo.Client(httpClient: spyHttpClient)

        try? sut.ping(accessToken: "a_token")

        let headers = spyHttpClient.lastCapturedRequest.headers.headers
        let expectedHeaders: [CaseInsensitiveString: String] = [
            "host": "api.monzo.com",
            "connection": "close",
            "authorization": "Bearer a_token"
        ]
        XCTAssertEqual(headers, expectedHeaders)
    }
    
    func test_givenAccessToken_whenPinging_thenTheRequestHasEmptyBody() {
        let spyHttpClient = SpyHttpClient()
        let sut = Monzo.Client(httpClient: spyHttpClient)
        
        try? sut.ping(accessToken: "a_token")
        
        guard case .buffer(let bodyData) = spyHttpClient.lastCapturedRequest.body else { XCTFail(#function); return }
        let bodyString = String(bytes: bodyData.bytes, encoding: .utf8)
        XCTAssertEqual(bodyString, "")
    }
    
    func test_givenASuccessfulResponse_whenPinging_thenNoExceptionIsThrown() {
        let responseBodyData = S4.Data([Byte]("{\"ping\":\"pong\"}".data(using: .utf8)!))
        let mockSuccessfulPingnResponse = Response(version: Version(major: 1, minor: 1), status: .ok, headers: Headers(), cookieHeaders: [], body: .buffer(responseBodyData))
        let stubHttpClient = StubHttpClient(response: mockSuccessfulPingnResponse)
        let sut = Monzo.Client(httpClient: stubHttpClient)
        
        do {
            try sut.ping(accessToken: "")
        } catch let error as CustomStringConvertible {
            XCTFail(error.description)
        } catch {
            XCTFail("Unknown error while authenticating")
        }
    }
    
    func test_givenAnInvalidResponseStatus_whenPinging_thenResponseErrorIsThrown() {
        let mockBadRequestStatusResponse = Response(version: Version(major: 0, minor: 0), status: .badRequest, headers: Headers(), cookieHeaders: [], body: .buffer([]))
        let stubHttpClient = StubHttpClient(response: mockBadRequestStatusResponse)
        let sut = Monzo.Client(httpClient: stubHttpClient)
        
        do {
            try sut.ping(accessToken: "")
        } catch Monzo.ClientError.responseError(.badRequest) {
            return
        } catch { }
        XCTFail(#function)
    }
    
    func test_givenAnInvalidResponseBody_whenPinging_thenParsingErrorIsThrown() {
        let responseBodyData = S4.Data([Byte]("{}".data(using: .utf8)!))
        let mockInvalidBodyResponse = Response(version: Version(major: 1, minor: 1), status: .ok, headers: Headers(), cookieHeaders: [], body: .buffer(responseBodyData))
        let stubHttpClient = StubHttpClient(response: mockInvalidBodyResponse)
        let sut = Monzo.Client(httpClient: stubHttpClient)
        
        do {
            try sut.ping(accessToken: "")
        } catch Monzo.ClientError.parsingError {
            return
        } catch { }
        XCTFail(#function)
    }
    
    static var allTests : [(String, (PingTests) -> () throws -> Void)] {
        return [
            ("test_givenPingParameters_whenPinging_thenTheRequestHasCorrectUri", test_givenPingParameters_whenPinging_thenTheRequestHasCorrectUri),
            ("test_givenAccessToken_whenPinging_thenTheRequestHasCorrectHeaders", test_givenAccessToken_whenPinging_thenTheRequestHasCorrectHeaders),
            ("test_givenAccessToken_whenPinging_thenTheRequestHasEmptyBody", test_givenAccessToken_whenPinging_thenTheRequestHasEmptyBody),
            ("test_givenASuccessfulResponse_whenPinging_thenNoExceptionIsThrown", test_givenASuccessfulResponse_whenPinging_thenNoExceptionIsThrown),
            ("test_givenAnInvalidResponseStatus_whenPinging_thenResponseErrorIsThrown", test_givenAnInvalidResponseStatus_whenPinging_thenResponseErrorIsThrown),
            ("test_givenAnInvalidResponseBody_whenPinging_thenParsingErrorIsThrown", test_givenAnInvalidResponseBody_whenPinging_thenParsingErrorIsThrown),
        ]
    }
    
}
