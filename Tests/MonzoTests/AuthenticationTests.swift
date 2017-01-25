import XCTest
import S4
import Monzo

class AuthenticationTests : XCTestCase {
    
    func test_requestHasCorrectUri() {
        assertRequestUriEquals("https://api.monzo.com/oauth2/token", forClientAction: { sut in
            try sut.authenticate(withCode: "", clientId: "", clientSecret: "")
        })
    }
    
    func test_requestHasCorrectHeaders() {
        assertRequestHeadersEqual([
            "host": "api.monzo.com",
            "connection": "close",
            "content-type": "application/x-www-form-urlencoded; charset=utf-8"
            ], forClientAction: { sut in
                try sut.authenticate(withCode: "", clientId: "", clientSecret: "")
        })
    }
    
    func test_givenAuthenticationParameters_thenTheRequestHasCorrectParametersInBody() {
        let spyHttpClient = SpyHttpClient()
        let sut = Monzo.Client(httpClient: spyHttpClient)
        
        _ = try? sut.authenticate(withCode: ":/?#[]@!$&'()*+,;=🌎-._~ ", clientId: "a string with spaces", clientSecret: "")
        
        guard case .buffer(let bodyData) = spyHttpClient.lastCapturedRequest.body else { XCTFail(#function); return }
        let bodyString = String(bytes: bodyData.bytes, encoding: .utf8)
        XCTAssertNotNil(bodyString?.range(of: "grant_type=authorization_code"))
        XCTAssertNotNil(bodyString?.range(of: "client_id=a+string+with+spaces"))
        XCTAssertNotNil(bodyString?.range(of: "client_secret="))
        XCTAssertNotNil(bodyString?.range(of: "redirect_uri="))
        XCTAssertNotNil(bodyString?.range(of: "code=%3A%2F%3F%23%5B%5D%40%21%24%26%27%28%29%2A%2B%2C%3B%3D%F0%9F%8C%8E-._~+"))
    }
    
    func test_givenASucessfulResponse_thenCorrectCredentialsAreReturned() {
        assertParsing(forResponseBody: "{\"access_token\":\"a token\",\"client_id\":\"a client id\",\"expires_in\":21599,\"refresh_token\":\"a refresh token\",\"token_type\":\"Bearer\",\"user_id\":\"a user id\"}", action: { sut in
            try sut.authenticate(withCode: "", clientId: "", clientSecret: "")
        }, assertions: { credentials in
            XCTAssertEqual(credentials.accessToken, "a token")
            XCTAssertEqual(credentials.clientId, "a client id")
            XCTAssertEqual(credentials.expiresIn, 21599)
            XCTAssertEqual(credentials.refreshToken, "a refresh token")
            XCTAssertEqual(credentials.tokenType, "Bearer")
            XCTAssertEqual(credentials.userId, "a user id")
        })
    }
    
    func test_givenAnInvalidResponseStatus_thenResponseErrorIsThrown() {
        let mockBadRequestStatusResponse = Response(version: Version(major: 0, minor: 0), status: .badRequest, headers: Headers(), cookieHeaders: [], body: .buffer([]))
        let stubHttpClient = StubHttpClient(response: mockBadRequestStatusResponse)
        let sut = Monzo.Client(httpClient: stubHttpClient)
        
        do {
            _ = try sut.authenticate(withCode: "", clientId: "", clientSecret: "")
        } catch Monzo.ClientError.responseError(.badRequest) {
            return
        } catch { }
        XCTFail(#function)
    }
    
    func test_givenAnInvalidResponseBody_thenParsingErrorIsThrown() {
        let responseBodyData = S4.Data([Byte]("{}".data(using: .utf8)!))
        let mockInvalidBodyResponse = Response(version: Version(major: 1, minor: 1), status: .ok, headers: Headers(), cookieHeaders: [], body: .buffer(responseBodyData))
        let stubHttpClient = StubHttpClient(response: mockInvalidBodyResponse)
        let sut = Monzo.Client(httpClient: stubHttpClient)
        
        do {
            _ = try sut.authenticate(withCode: "", clientId: "", clientSecret: "")
        } catch Monzo.ClientError.parsingError {
            return
        } catch { }
        XCTFail(#function)
    }
    
    static var allTests : [(String, (AuthenticationTests) -> () throws -> Void)] {
        return [
            ("test_requestHasCorrectUri", test_requestHasCorrectUri),
            ("test_requestHasCorrectHeaders", test_requestHasCorrectHeaders),
            ("test_givenAuthenticationParameters_thenTheRequestHasCorrectParametersInBody", test_givenAuthenticationParameters_thenTheRequestHasCorrectParametersInBody),
            ("test_givenASucessfulResponse_thenCorrectCredentialsAreReturned", test_givenASucessfulResponse_thenCorrectCredentialsAreReturned),
            ("test_givenAnInvalidResponseStatus_thenResponseErrorIsThrown", test_givenAnInvalidResponseStatus_thenResponseErrorIsThrown),
            ("test_givenAnInvalidResponseBody_thenParsingErrorIsThrown", test_givenAnInvalidResponseBody_thenParsingErrorIsThrown),
        ]
    }
    
}
