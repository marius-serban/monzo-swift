import XCTest
import S4
import Monzo

class AuthenticationTests : XCTestCase {
    
    func test_requestHasCorrectMethod() {
        let method = request(forClientAction: { sut in
            try sut.authenticate(withCode: "", clientId: "", clientSecret: "")
        }).method
        
        XCTAssertEqual(method, Method.post)
    }
    
    func test_requestHasCorrectUri() {
        let uri = request(forClientAction: { sut in
            try sut.authenticate(withCode: "", clientId: "", clientSecret: "")
        }).uri
        
        XCTAssertEqual(uri.description, "https://api.monzo.com/oauth2/token")
    }
    
    func test_requestHasCorrectHeaders() {
        let headers = request(forClientAction: { sut in
            try sut.authenticate(withCode: "", clientId: "", clientSecret: "")
        }).headers.headers
        
        XCTAssertEqual(headers, [
            "host": "api.monzo.com",
            "connection": "close",
            "content-type": "application/x-www-form-urlencoded; charset=utf-8"
            ])
    }
    
    func test_givenAuthenticationParameters_thenTheRequestHasCorrectParametersInBody() {
        let body = requestBody(forClientAction: { sut in
            try sut.authenticate(withCode: ":/?#[]@!$&'()*+,;=🌎-._~ ", clientId: "a string with spaces", clientSecret: "")
        })
        
        XCTAssertNotNil(body?.range(of: "grant_type=authorization_code"))
        XCTAssertNotNil(body?.range(of: "client_id=a+string+with+spaces"))
        XCTAssertNotNil(body?.range(of: "client_secret="))
        XCTAssertNotNil(body?.range(of: "redirect_uri="))
        XCTAssertNotNil(body?.range(of: "code=%3A%2F%3F%23%5B%5D%40%21%24%26%27%28%29%2A%2B%2C%3B%3D%F0%9F%8C%8E-._~+"))
    }
    
    func test_givenASucessfulResponse_thenCorrectCredentialsAreReturned() {
        let sut = configuredClient(withResponseBody: "{\"access_token\":\"a token\",\"client_id\":\"a client id\",\"expires_in\":21599,\"refresh_token\":\"a refresh token\",\"token_type\":\"Bearer\",\"user_id\":\"a user id\"}")
        
        do {
            let credentials = try sut.authenticate(withCode: "", clientId: "", clientSecret: "")
            XCTAssertEqual(credentials.accessToken, "a token")
            XCTAssertEqual(credentials.clientId, "a client id")
            XCTAssertEqual(credentials.expiresIn, 21599)
            XCTAssertEqual(credentials.refreshToken, "a refresh token")
            XCTAssertEqual(credentials.tokenType, "Bearer")
            XCTAssertEqual(credentials.userId, "a user id")
        } catch {
            XCTFail(String(describing: error))
        }
    }
    
    func test_givenAnInvalidResponseStatus_thenResponseErrorIsThrown() {
        let sut = configuredClient(withResponseBody: "", responseStatus: .badRequest)
        
        XCTAssertThrowsError(try sut.authenticate(withCode: "", clientId: "", clientSecret: ""), #function) { error in
            guard case Monzo.ClientError.responseError(.badRequest) = error else { XCTFail(#function); return }
        }
    }
    
    func test_givenAnInvalidResponseBody_thenParsingErrorIsThrown() {
        let sut = configuredClient(withResponseBody: "{}")
        
        XCTAssertThrowsError(try sut.authenticate(withCode: "", clientId: "", clientSecret: ""), #function) { error in
            guard case Monzo.ClientError.parsingError = error else { XCTFail(#function); return }
        }
    }
    
    static var allTests : [(String, (AuthenticationTests) -> () throws -> Void)] {
        return [
            ("test_requestHasCorrectMethod", test_requestHasCorrectMethod),
            ("test_requestHasCorrectUri", test_requestHasCorrectUri),
            ("test_requestHasCorrectHeaders", test_requestHasCorrectHeaders),
            ("test_givenAuthenticationParameters_thenTheRequestHasCorrectParametersInBody", test_givenAuthenticationParameters_thenTheRequestHasCorrectParametersInBody),
            ("test_givenASucessfulResponse_thenCorrectCredentialsAreReturned", test_givenASucessfulResponse_thenCorrectCredentialsAreReturned),
            ("test_givenAnInvalidResponseStatus_thenResponseErrorIsThrown", test_givenAnInvalidResponseStatus_thenResponseErrorIsThrown),
            ("test_givenAnInvalidResponseBody_thenParsingErrorIsThrown", test_givenAnInvalidResponseBody_thenParsingErrorIsThrown),
        ]
    }
    
}
