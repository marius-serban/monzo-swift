extension Client {
    public func createFeedItem(accessToken: String, accountId: String, title: String, imageUrl: String, url: String? = nil, body: String? = nil, backgroundColor: String? = nil, bodyColor: String? = nil, titleColor: String? = nil) throws {
        
        var parametersArray = [
            ("account_id", accountId),
            ("url", url)
            ].flatMap(Parameter.init)
        parametersArray.append(Parameter("params", [
            "title": title,
            "image_url": imageUrl,
            "body": body,
            "background_color": backgroundColor,
            "body_color": bodyColor,
            "title_color": titleColor
            ]))
        let createFeedItemRequest = ApiRequest(method: .post, path: "feed", accessToken: accessToken, parameters: Parameters(parametersArray))
        
        try deliver(createFeedItemRequest)
    }
}
