import XCTest
import Monzo
import S4
import Foundation

struct StubHttpClient : Responder {
    let response: Response
    
    init(response: Response = fakeResponse) {
        self.response = response
    }
    
    func respond(to request: Request) throws -> Response {
        return response
    }
}

class SpyHttpClient : Responder {
    var lastCapturedRequest: Request!
    
    func respond(to request: Request) throws -> Response {
        lastCapturedRequest = request
        return fakeResponse
    }
}

let fakeResponse = Response(version: Version(major: 0, minor: 0), status: .ok, headers: Headers(), cookieHeaders: [], body: .buffer([]))

extension URI: CustomStringConvertible {
    public var description: String {
        let schemeString = (scheme ?? "") + "://"
        let userString = userInfo != nil ? "\(userInfo!.username):\(userInfo!.password)@" : ""
        let hostString = host ?? ""
        let portString = port != nil ? ":\(port!)" : ""
        let pathString = "/\(path ?? "")"
        let queryString = query != nil ? "?\(query!)" : ""
        let fragmentString = fragment != nil ? "#\(fragment!)" : ""
        
        return [schemeString, userString, hostString, portString, pathString, queryString, fragmentString].joined()
    }
}

extension XCTestCase {
    
    func assertRequestUriEquals<T>(_ expectedUri: String, forClientAction action: (Monzo.Client) throws -> T) {
        let uriForAction = uri(forClientAction: action)
        XCTAssertEqual(uriForAction.description, expectedUri)
    }
    
    func assertRequestUriContains<T>(_ string: String, forClientAction action: (Monzo.Client) throws -> T) {
        let uriForAction = uri(forClientAction: action)
        XCTAssertTrue(uriForAction.description.contains(string), "\(uriForAction) does not contain \(string)")
    }
    
    private func uri<T>(forClientAction action: (Monzo.Client) throws -> T) -> URI {
        let spyHttpClient = SpyHttpClient()
        let sut = Monzo.Client(httpClient: spyHttpClient)
        
        _ = try? action(sut)
        
        return spyHttpClient.lastCapturedRequest.uri
    }
    
    func assertRequestHeadersEqual<T>(_ expectedHeaders: [CaseInsensitiveString: String], forClientAction action: (Monzo.Client) throws -> T) {
        let spyHttpClient = SpyHttpClient()
        let sut = Monzo.Client(httpClient: spyHttpClient)
        
        _ = try? action(sut)
        
        let headers = spyHttpClient.lastCapturedRequest.headers.headers
        XCTAssertEqual(headers, expectedHeaders)
    }
    
    func assertRequestBodyIsEmpty<T>(_ testName: String = String(describing: #function), forClientAction action: (Monzo.Client) throws -> T) {
        let spyHttpClient = SpyHttpClient()
        let sut = Monzo.Client(httpClient: spyHttpClient)
        
        _ = try? action(sut)
        
        guard case .buffer(let bodyData) = spyHttpClient.lastCapturedRequest.body else { XCTFail(testName); return }
        let bodyString = String(bytes: bodyData.bytes, encoding: .utf8)
        XCTAssertEqual(bodyString, "")
    }
    
    func assertParsing<T>(forResponseBody body: String, action: (Monzo.Client) throws -> T, assertions assertBlock: ((T) -> Void)?) {
        let responseBodyData = S4.Data([Byte](body.data(using: .utf8)!))
        let mockSuccessfulResponse = Response(version: Version(major: 1, minor: 1), status: .ok, headers: Headers(), cookieHeaders: [], body: .buffer(responseBodyData))
        let stubHttpClient = StubHttpClient(response: mockSuccessfulResponse)
        let sut = Monzo.Client(httpClient: stubHttpClient)
        
        do {
            let parseResult = try action(sut)
            assertBlock?(parseResult)
        } catch {
            XCTFail(String(describing: error))
        }
    }
    
    func assertThrows<T>(_ testName: String = String(describing: #function), forResponseStatus status: Status, action: (Monzo.Client) throws -> T, errorHandler: (Error) -> Void) {
        let mockBadRequestStatusResponse = Response(version: Version(major: 0, minor: 0), status: status, headers: Headers(), cookieHeaders: [], body: .buffer([]))
        let stubHttpClient = StubHttpClient(response: mockBadRequestStatusResponse)
        let sut = Monzo.Client(httpClient: stubHttpClient)
        
        XCTAssertThrowsError(try action(sut), testName, errorHandler)
    }
    
    func assertThrows<T>(_ testName: String = String(describing: #function), forResponseBody body: String, action: (Monzo.Client) throws -> T, errorHandler: (Error) -> Void) {
        let responseBodyData = S4.Data([Byte](body.data(using: .utf8)!))
        let mockSuccessfulResponse = Response(version: Version(major: 1, minor: 1), status: .ok, headers: Headers(), cookieHeaders: [], body: .buffer(responseBodyData))
        let stubHttpClient = StubHttpClient(response: mockSuccessfulResponse)
        let sut = Monzo.Client(httpClient: stubHttpClient)
        
        XCTAssertThrowsError(try action(sut), testName, errorHandler)
    }
    
    func contentsOfTextFile(_ relativeFilePath: String) -> String {
        let parent = (#file).components(separatedBy: "/").dropLast().joined(separator: "/")
        let fileURL = URL(string: "file://\(parent)/\(relativeFilePath)")!
        return String(data: try! Data(contentsOf: fileURL), encoding: .utf8)!
    }
    
}
