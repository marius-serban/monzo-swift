extension Client {
    public func ping(accessToken: String? = nil) throws {
        let pingRequest = ApiRequest(path: "ping", accessToken: accessToken)
        
        let json = try retrieve(pingRequest) as JsonObject
        
        guard try json.value(forKey: "ping") == "pong" else { throw ClientError.parsingError }
    }
}
