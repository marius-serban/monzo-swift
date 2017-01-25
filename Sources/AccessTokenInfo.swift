public enum AccessTokenInfo {
    case notAuthenticated
    case authenticated(clientId: String, userId: String)
}
