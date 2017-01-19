typealias JsonObject = [String: Any]

protocol JsonInitializable {
    init(jsonObject: JsonObject) throws
}

extension Dictionary {
    func value<T>(forKey key: Key) throws -> T {
        guard let value = self[key] as? T else { throw ClientError.parsingError }
        return value
    }
}

extension UserCredentials : JsonInitializable {
    init(jsonObject: [String: Any]) throws {
        accessToken = try jsonObject.value(forKey: "access_token")
        clientId = try jsonObject.value(forKey: "client_id")
        expiresIn = UInt(try jsonObject.value(forKey: "expires_in") as Int)
        refreshToken = try jsonObject.value(forKey: "refresh_token")
        tokenType = try jsonObject.value(forKey: "token_type")
        userId = try jsonObject.value(forKey: "user_id")
    }
}
