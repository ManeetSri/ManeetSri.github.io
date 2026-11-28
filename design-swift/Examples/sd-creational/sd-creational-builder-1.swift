// Generated from src/dsa/design/content/lessons/sd-creational/sd-creational-builder.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

struct Request: CustomStringConvertible {
    let method: String
    let path: String
    let headers: [String: String]

    var description: String {
        let headerList = headers.keys.sorted().map { "\($0): \(headers[$0]!)" }.joined(separator: ", ")
        return "\(method) \(path) [\(headerList)]"
    }
}

// A reference builder: every call mutates the one object and returns it
final class ClassRequestBuilder {
    private var method = "GET"
    private var path = "/"
    private var headers: [String: String] = [:]

    func path(_ path: String) -> ClassRequestBuilder {
        self.path = path
        return self
    }

    func header(_ name: String, _ value: String) -> ClassRequestBuilder {
        headers[name] = value
        return self
    }

    func build() -> Request { Request(method: method, path: path, headers: headers) }
}

// A value builder: every call returns a changed copy and leaves the original alone
struct RequestBuilder {
    private var method = "GET"
    private var path = "/"
    private var headers: [String: String] = [:]

    func path(_ path: String) -> RequestBuilder {
        var copy = self
        copy.path = path
        return copy
    }

    func header(_ name: String, _ value: String) -> RequestBuilder {
        var copy = self
        copy.headers[name] = value
        return copy
    }

    func build() -> Request { Request(method: method, path: path, headers: headers) }
}

let sharedObject = ClassRequestBuilder().header("Authorization", "Bearer abc")
let ordersFromObject = sharedObject.path("/orders")
let profileFromObject = sharedObject.path("/profile")
print("class:", ordersFromObject.build())
print("class:", profileFromObject.build())

let sharedValue = RequestBuilder().header("Authorization", "Bearer abc")
let orders = sharedValue.path("/orders")
let profile = sharedValue.path("/profile").header("Accept-Language", "en-GB")
print("value:", orders.build())
print("value:", profile.build())
print("value:", sharedValue.build())
