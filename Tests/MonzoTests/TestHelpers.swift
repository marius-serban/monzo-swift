import S4

struct StubHttpClient : Responder {
    let response: Response
    
    init(response: Response = fakeResponse) {
        self.response = response
    }
    
    func respond(to request: Request) throws -> Response {
        return response
    }
}

class SpyHttpClient : Responder {
    var lastCapturedRequest: Request!
    
    func respond(to request: Request) throws -> Response {
        lastCapturedRequest = request
        return fakeResponse
    }
}

let fakeResponse = Response(version: Version(major: 0, minor: 0), status: .ok, headers: Headers(), cookieHeaders: [], body: .buffer([]))

extension URI: CustomStringConvertible {
    public var description: String {
        let schemeString = (scheme ?? "") + "://"
        let userString = userInfo != nil ? "\(userInfo!.username):\(userInfo!.password)@" : ""
        let hostString = host ?? ""
        let portString = port != nil ? ":\(port!)" : ""
        let pathString = "/\(path ?? "")"
        let queryString = query != nil ? "?\(query!)" : ""
        let fragmentString = fragment != nil ? "#\(fragment!)" : ""
        
        return [schemeString, userString, hostString, portString, pathString, queryString, fragmentString].joined()
    }
}
