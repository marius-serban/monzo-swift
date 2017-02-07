import S4

public final class Client {
    public let httpClient: Responder
    
    public init(httpClient: Responder) {
        self.httpClient = httpClient
    }
}

public enum ClientError : Error {
    case accessTokenInvalid
    case responseError(Status)
    case parsingError
}

extension ClientError : CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .accessTokenInvalid:
            return "The supplied access token is invalid or has expired"
        case .responseError(let status):
            return "Invalid response status code: \(status)"
        case .parsingError:
            return "Error parsing the response body"
        }
    }
}
