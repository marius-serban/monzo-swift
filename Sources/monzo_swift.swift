import S4

public final class MonzoClient {
    
    let httpClient: Responder
    
    init(httpClient: Responder) {
        self.httpClient = httpClient
    }
}
