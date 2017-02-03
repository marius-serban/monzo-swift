extension Client {
    public func balance(accessToken: String, accountId: String) throws -> Balance {
        let balanceRequest = ApiRequest(path: "balance", accessToken: accessToken, parameters: [("account_id", accountId)])
        
        return try retrieve(balanceRequest)
    }
}

public struct Balance {
    // FIXME: balance and spendToday should be stored and parsed as an 64 bit integers but Foundation doesn't parse Int64 on linux
    public let balance: Int
    public let currency: String
    public let spendToday: Int
}

extension Balance : JsonInitializable {
    init(jsonObject: JsonObject) throws {
        balance = try jsonObject.value(forKey: "balance")
        currency = try jsonObject.value(forKey: "currency")
        spendToday = try jsonObject.value(forKey: "spend_today")
    }
}
