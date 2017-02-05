import XCTest
import Monzo
import S4
import Foundation

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

    func request<T>(forClientAction action: (Monzo.Client) throws -> T) -> Request {
        let spyHttpClient = SpyHttpClient()
        let sut = Monzo.Client(httpClient: spyHttpClient)
        
        _ = try? action(sut)
        
        return spyHttpClient.lastCapturedRequest
    }
    
    func requestBody<T>(forClientAction action: (Monzo.Client) throws -> T) -> String? {
        let requestForAction = request(forClientAction: action)
        guard case .buffer(let bodyData) = requestForAction.body else { return nil }
        return String(bytes: bodyData.bytes, encoding: .utf8)
    }
    
    func configuredClient(withResponseBody body : String, responseStatus status: Status = .ok) -> Monzo.Client {
        let responseBodyData = S4.Data([Byte](body.data(using: .utf8, allowLossyConversion: true)!))
        let mockResponse = Response(version: Version(major: 1, minor: 1), status: status, headers: Headers(), cookieHeaders: [], body: .buffer(responseBodyData))
        let stubHttpClient = StubHttpClient(response: mockResponse)
        return Monzo.Client(httpClient: stubHttpClient)
    }
    
    func contentsOfTextFile(_ relativeFilePath: String) -> String {
        let parent = (#file).components(separatedBy: "/").dropLast().joined(separator: "/")
        let fileURL = URL(string: "file://\(parent)/\(relativeFilePath)")!
        return String(data: try! Data(contentsOf: fileURL), encoding: .utf8)!
    }
    
}

fileprivate struct StubHttpClient : Responder {
    let response: Response
    
    init(response: Response = fakeResponse) {
        self.response = response
    }
    
    func respond(to request: Request) throws -> Response {
        return response
    }
}

fileprivate class SpyHttpClient : Responder {
    var lastCapturedRequest: Request!
    
    func respond(to request: Request) throws -> Response {
        lastCapturedRequest = request
        return fakeResponse
    }
}

fileprivate let fakeResponse = Response(version: Version(major: 0, minor: 0), status: .ok, headers: Headers(), cookieHeaders: [], body: .buffer([]))
