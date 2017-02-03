import Foundation

extension Client {
    public func accounts(accessToken: String) throws -> [Account] {
        let accountsRequest = ApiRequest(path: "accounts", accessToken: accessToken)
        
        return try retrieve(accountsRequest)
    }
}

public struct Account {
    public let id: String
    public let created: Date
    public let description: String
}

extension Account : JsonInitializable {
    init(jsonObject: JsonObject) throws {
        id = try jsonObject.value(forKey: "id")
        created = try type(of: self).iso8601Date(jsonObject.value(forKey: "created"))
        description = try jsonObject.value(forKey: "description")
    }
}

extension Account : JsonArrayInitializable {
    static var arrayKey: String { return "accounts" }
}
