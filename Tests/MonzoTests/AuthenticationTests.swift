import XCTest
import S4
import Monzo

class AuthenticationTests : XCTestCase {
    
    func test_givenAuthenticationParameters_whenAuthenticating_thenTheRequestHasCorrectUri() {
        let spyHttpClient = SpyHttpClient()
        let sut = Monzo.Client(httpClient: spyHttpClient)
        
        _ = try? sut.authenticate(withCode: "", clientId: "", clientSecret: "")
        
        let uri = spyHttpClient.lastCapturedRequest.uri
        XCTAssertEqual(uri.description, "https://api.monzo.com/oauth2/token")
    }
    
    func test_givenAuthenticationParameters_whenAuthenticating_thenTheRequestHasCorrectHeaders() {
        let spyHttpClient = SpyHttpClient()
        let sut = Monzo.Client(httpClient: spyHttpClient)
        
        _ = try? sut.authenticate(withCode: "", clientId: "", clientSecret: "")
        
        let headers = spyHttpClient.lastCapturedRequest.headers.headers
        let expectedHeaders: [CaseInsensitiveString: String] = [
            "host": "api.monzo.com",
            "connection": "close",
            "content-type": "application/x-www-form-urlencoded; charset=utf-8"
        ]
        XCTAssertEqual(headers, expectedHeaders)
    }
    
    func test_givenAuthenticationParameters_whenAuthenticating_thenTheRequestHasCorrectParametersInBody() {
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
    
    func test_givenASucessfulResponse_whenAuthenticating_thenCorrectUserCredentialsAreReturned() {
        let responseBodyData = S4.Data([Byte]("{\"access_token\":\"a token\",\"client_id\":\"a client id\",\"expires_in\":21599,\"refresh_token\":\"a refresh token\",\"token_type\":\"Bearer\",\"user_id\":\"a user id\"}".data(using: .utf8)!))
        let mockSuccessfulAuthenticationResponse = Response(version: Version(major: 1, minor: 1), status: .ok, headers: Headers(), cookieHeaders: [], body: .buffer(responseBodyData))
        let stubHttpClient = StubHttpClient(response: mockSuccessfulAuthenticationResponse)
        let sut = Monzo.Client(httpClient: stubHttpClient)
        
        do {
            let userCredentials = try sut.authenticate(withCode: "", clientId: "", clientSecret: "")
            XCTAssertEqual(userCredentials.accessToken, "a token")
            XCTAssertEqual(userCredentials.clientId, "a client id")
            XCTAssertEqual(userCredentials.expiresIn, 21599)
            XCTAssertEqual(userCredentials.refreshToken, "a refresh token")
            XCTAssertEqual(userCredentials.tokenType, "Bearer")
            XCTAssertEqual(userCredentials.userId, "a user id")
        } catch let error as CustomStringConvertible {
            XCTFail(error.description)
        } catch {
            XCTFail("Unknown error while authenticating")
        }
    }
    
    func test_givenAnInvalidResponseStatus_whenAuthenticating_thenResponseErrorIsThrown() {
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
    
    func test_givenAnInvalidResponseBody_whenAuthenticating_thenParsingErrorIsThrown() {
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
            ("test_givenAuthenticationParameters_whenAuthenticating_thenTheRequestHasCorrectUri", test_givenAuthenticationParameters_whenAuthenticating_thenTheRequestHasCorrectUri),
            ("test_givenAuthenticationParameters_whenAuthenticating_thenTheRequestHasCorrectHeaders", test_givenAuthenticationParameters_whenAuthenticating_thenTheRequestHasCorrectHeaders),
            ("test_givenAuthenticationParameters_whenAuthenticating_thenTheRequestHasCorrectParametersInBody", test_givenAuthenticationParameters_whenAuthenticating_thenTheRequestHasCorrectParametersInBody),
            ("test_givenASucessfulResponse_whenAuthenticating_thenCorrectUserCredentialsAreReturned", test_givenASucessfulResponse_whenAuthenticating_thenCorrectUserCredentialsAreReturned),
            ("test_givenAnInvalidResponseStatus_whenAuthenticating_thenResponseErrorIsThrown", test_givenAnInvalidResponseStatus_whenAuthenticating_thenResponseErrorIsThrown),
            ("test_givenAnInvalidResponseBody_whenAuthenticating_thenParsingErrorIsThrown", test_givenAnInvalidResponseBody_whenAuthenticating_thenParsingErrorIsThrown),
        ]
    }
    
}
