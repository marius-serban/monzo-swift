extension Client {
    public func createWebhook(accessToken: String, accountId: String, url: String) throws -> Webhook {
        let createWebhookRequest = ApiRequest(method: .post, path: "webhooks", accessToken: accessToken, parameters: [
            ("account_id", accountId),
            ("url", url)
            ])
        
        return try retrieve(createWebhookRequest)
    }
    
    public func webhooks(accessToken: String, accountId: String) throws -> [Webhook] {
        let webhooksRequest = ApiRequest(path: "webhooks", accessToken: accessToken, parameters: [("account_id", accountId)])
        
        return try retrieve(webhooksRequest)
    }
    
    public func deleteWebhook(accessToken: String, id: String) throws {
        let deleteWebhookRequest = ApiRequest(method: .delete, path: "webhooks/\(id)", accessToken: accessToken)
        
        try deliver(deleteWebhookRequest)
    }
}

public struct Webhook {
    public let id: String
    public let accountId: String
    public let url: String
}

extension Webhook : JsonInitializable {
    static var nestedObjectKey: String? { return "webhook" }
    
    init(jsonObject: JsonObject) throws {
        id = try jsonObject.value(forKey: "id")
        accountId = try jsonObject.value(forKey: "account_id")
        url = try jsonObject.value(forKey: "url")
    }
}

extension Webhook : JsonArrayInitializable {
    static var arrayKey: String { return "webhooks" }
}
