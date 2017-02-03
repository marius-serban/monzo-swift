extension Client {
    public func whoami(accessToken: String? = nil) throws -> AccessTokenInfo {
        let whoamiRequest = ApiRequest(path: "ping/whoami", accessToken: accessToken)
        
        return try retrieve(whoamiRequest)
    }
}

public enum AccessTokenInfo {
    case notAuthenticated
    case authenticated(clientId: String, userId: String)
}

extension AccessTokenInfo : JsonInitializable {
    init(jsonObject: JsonObject) throws {
        let authenticated: Bool = try jsonObject.value(forKey: "authenticated")
        if authenticated {
            let clientId: String = try jsonObject.value(forKey: "client_id")
            let userId: String = try jsonObject.value(forKey: "user_id")
            self = .authenticated(clientId: clientId, userId: userId)
        } else {
            self = .notAuthenticated
        }
    }
}
