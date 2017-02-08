extension Client {
    public func authenticate(withCode authorizationCode: String, clientId: String, clientSecret: String) throws -> Credentials {
        let authenticationRequest = ApiRequest(method: .post, path: "oauth2/token", parameters: [
            ("grant_type", "authorization_code"),
            ("client_id", clientId),
            ("client_secret", clientSecret),
            ("redirect_uri", ""),
            ("code", authorizationCode)
            ]
        )
        
        return try retrieve(authenticationRequest)
    }
    
    public func refreshAccessToken(refreshToken: String, clientId: String, clientSecret: String) throws -> Credentials {
        let refreshAccessTokenRequest = ApiRequest(method: .post, path: "oauth2/token", parameters: [
            ("grant_type", "refresh_token"),
            ("client_id", clientId),
            ("client_secret", clientSecret),
            ("refresh_token", refreshToken)
            ]
        )
        
        return try retrieve(refreshAccessTokenRequest)
    }
}

public struct Credentials {
    public let accessToken: String
    public let clientId: String
    public let expiresIn: UInt
    public let refreshToken: String
    public let tokenType: String
    public let userId: String
}

extension Credentials : JsonInitializable {
    init(jsonObject: JsonObject) throws {
        accessToken = try jsonObject.value(forKey: "access_token")
        clientId = try jsonObject.value(forKey: "client_id")
        expiresIn = UInt(try jsonObject.value(forKey: "expires_in") as Int)
        refreshToken = try jsonObject.value(forKey: "refresh_token")
        tokenType = try jsonObject.value(forKey: "token_type")
        userId = try jsonObject.value(forKey: "user_id")
    }
}
