import S4

extension Client {
    public static func authorizationUri(clientId: String, redirectUri: String, nonce: String) -> URI {
        let parameters: Parameters = [
            ("client_id", clientId),
            ("redirect_uri", redirectUri),
            ("state", nonce)
        ]
        
        return URI(scheme: "https", host: "auth.getmondo.co.uk", query: parameters.urlQueryEncoded)
    }
}
