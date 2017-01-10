import S4
import Foundation

public enum ClientError : Error {
    case parameterEncodingError
    case accessTokenExpired
    case responseError(Status)
    case parsingError
}

public final class Client {
    
    public let httpClient: Responder
    
    private static let httpVersion = Version(major: 1, minor: 1)
    
    public init(httpClient: Responder) {
        self.httpClient = httpClient
    }
    
    public static func authorizationUri(clientId: String, redirectUri: String, nonce: String) throws -> URI {
        let query = try "client_id=\(urlQueryPercentEncode(clientId))&redirect_uri=\(urlQueryPercentEncode(redirectUri))&state=\(urlQueryPercentEncode(nonce))"
        
        return URI(scheme: "https", host: "auth.getmondo.co.uk", query: query)
    }
    
    public func authenticate(withCode authorizationCode: String, clientId: String, clientSecret: String) throws -> UserCredentials {
        
        let request = try type(of: self).authenticationRequest(authorizationCode: authorizationCode, clientId: clientId, clientSecret: clientSecret)
        let response = try httpClient.respond(to: request)
        
        guard case .ok = response.status else { throw ClientError.responseError(response.status) }
        guard
            case .buffer(let responseData) = response.body,
            let jsonResponse = try? JSONSerialization.jsonObject(with: Data(responseData.bytes), options: [.allowFragments])
            else { throw ClientError.parsingError }
        
        return try UserCredentials(jsonObject: jsonResponse)
    }
    
    private static func authenticationRequest(authorizationCode: String, clientId: String, clientSecret: String) throws -> Request {
        let tokenUri = uri(withPath: "oauth2/token")
        let authHeaders = headers(contentType: "application/x-www-form-urlencoded; charset=utf-8")
        let stringBody = try "grant_type=authorization_code&client_id=\(urlFormPercentEncode(clientId))&client_secret=\(urlFormPercentEncode(clientSecret))&redirect_uri=&code=\(urlFormPercentEncode(authorizationCode))"
        guard let bodyData = stringBody.data(using: .utf8) else { throw ClientError.parameterEncodingError }
        let body = Body.buffer(Data([Byte](bodyData)))
        
        return Request(method: .post, uri: tokenUri, version: httpVersion, headers: authHeaders, body: body)
    }
    
    private static func uri(withPath path: String, query: String? = nil) -> URI {
        return URI(scheme: "https", host: "api.getmondo.co.uk", path: path, query: query)
    }
    
    private static func headers(contentType: String? = nil) -> Headers {
        var headers = Headers([
            "host": "api.getmondo.co.uk",
            "connection": "close",
            ])
        if let contentType = contentType {
            headers["content-type"] = contentType
        }
        
        return headers
    }
    
}

fileprivate func urlQueryPercentEncode(_ string: String) throws -> String {
    guard let escaped = string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { throw ClientError.parameterEncodingError }
    return escaped
}

fileprivate func urlFormPercentEncode(_ string: String) throws -> String {
    // RFC 3986 allowed characters
    let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-._~ "))
    guard let encoded = string.addingPercentEncoding(withAllowedCharacters: allowed) else { throw ClientError.parameterEncodingError }
    return encoded.replacingOccurrences(of: " ", with: "+")
}
