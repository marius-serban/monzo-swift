import S4

public final class Client {
    
    public let httpClient: Responder
    
    public init(httpClient: Responder) {
        self.httpClient = httpClient
    }
    
    public static func authorizationUri(clientId: String, redirectUri: String, nonce: String) -> URI {
        let parameters: Parameters = [
            ("client_id", clientId),
            ("redirect_uri", redirectUri),
            ("state", nonce)
        ]
        
        return URI(scheme: "https", host: "auth.getmondo.co.uk", query: parameters.urlQueryEncoded)
    }
    
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
    
    public func ping(accessToken: String? = nil) throws {
        let pingRequest = ApiRequest(path: "ping", accessToken: accessToken)
        
        let json = try retrieve(pingRequest) as JsonObject

        guard try json.value(forKey: "ping") == "pong" else { throw ClientError.parsingError }
    }
    
    public func whoami(accessToken: String? = nil) throws -> AccessTokenInfo {
        let whoamiRequest = ApiRequest(path: "ping/whoami", accessToken: accessToken)
        
        return try retrieve(whoamiRequest)
    }
    
    public func accounts(accessToken: String) throws -> [Account] {
        let accountsRequest = ApiRequest(path: "accounts", accessToken: accessToken)
        
        return try retrieve(accountsRequest)
    }
    
    public func balance(accessToken: String, accountId: String) throws -> Balance {
        let balanceRequest = ApiRequest(path: "balance", accessToken: accessToken, parameters: [("account_id", accountId)])
        
        return try retrieve(balanceRequest)
    }
}
