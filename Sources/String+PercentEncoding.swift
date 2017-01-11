import Foundation
import CcURL

extension String {
    
    func urlQueryPercentEncoded() throws -> String {
        guard let escaped = addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { throw ClientError.parameterEncodingError }
        return escaped
    }
    
    func urlFormPercentEncoded() throws -> String {
        let encodedComponents = components(separatedBy: " ").flatMap(cURLEncode)
        return encodedComponents.joined(separator: "+")
    }
}

//FIXME: remove cURL dependency once SR-3216 is fixed
fileprivate func cURLEncode(string: String) -> String? {
    guard !string.isEmpty else { return "" }
    guard let handle = curl_easy_init() else { return nil }
    guard let output = curl_easy_escape(handle, string, Int32(string.utf8.count)) else { return nil }
    
    let result = String(cString: output)
    
    curl_free(output)
    curl_easy_cleanup(handle)
    
    return result
}
