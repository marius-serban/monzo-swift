import S4
	
public enum ClientError : Error {
    case accessTokenInvalid
    case responseError(Status)
    case parsingError
}

extension ClientError : CustomStringConvertible {
    public var description: String {
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
