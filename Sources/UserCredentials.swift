public struct UserCredentials {
    public let accessToken: String
    public let clientId: String
    public let expiresIn: UInt
    public let refreshToken: String
    public let tokenType: String
    public let userId: String
}

// TODO: test this internal initialiser
extension UserCredentials {
    init(jsonObject: Any) throws {
        guard let dictionary = jsonObject as? [String: Any] else { throw ClientError.parsingError }
        
        accessToken = try dictionary.value(forKey: "access_token")
        clientId = try dictionary.value(forKey: "client_id")
        expiresIn = UInt(try dictionary.value(forKey: "expires_in") as Int)
        refreshToken = try dictionary.value(forKey: "refresh_token")
        tokenType = try dictionary.value(forKey: "token_type")
        userId = try dictionary.value(forKey: "user_id")
    }
}

extension Dictionary {
    fileprivate func value<T>(forKey key: Key) throws -> T {
        guard let value = self[key] as? T else { throw ClientError.parsingError }
        return value
    }
}
