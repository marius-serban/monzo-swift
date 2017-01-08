import S4
import Foundation

public enum MonzoClientError : Error {
    case parameterEncodingError
}

public final class MonzoClient {
    
    public let httpClient: Responder
    
    public init(httpClient: Responder) {
        self.httpClient = httpClient
    }
    
    public static func authorizationUri(clientId: String, redirectUri: String, nonce: String) throws -> URI {
        let query = try "client_id=\(urlQueryPercentEncode(clientId))&redirect_uri=\(urlQueryPercentEncode(redirectUri))&state=\(urlQueryPercentEncode(nonce))"
        
        return URI(scheme: "https", host: "auth.getmondo.co.uk", query: query)
    }
    
}

private func urlQueryPercentEncode(_ string: String) throws -> String {
    guard let escaped = string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { throw MonzoClientError.parameterEncodingError }
    return escaped
}
