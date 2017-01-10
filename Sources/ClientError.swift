import S4

public enum ClientError : Error {
    case parameterEncodingError
    case accessTokenExpired
    case responseError(Status)
    case parsingError
}

extension ClientError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .parameterEncodingError:
            return "Error encoding HTTP request parameters"
        case .accessTokenExpired:
            return "The provided access token has expired, please use the refresh token to obtain a new credentials"
        case .responseError(let status):
            return "Invalid response status code: \(status)"
        case .parsingError:
            return "Error parsing the response body"
        }
    }
}
