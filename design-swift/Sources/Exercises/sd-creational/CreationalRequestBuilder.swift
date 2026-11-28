// Kata: Request builder (D10 · Builder, fluent APIs and result builders)
import Foundation

public enum CreationalRequestBuilder {
    public enum Method: String, Sendable {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case patch = "PATCH"
        case delete = "DELETE"
    }

    /// Why `build()` refused to make a request
    public enum BuildError: Error, Equatable, Sendable {
        /// The path doesn't start with "/"
        case invalidPath(String)
        /// A GET request was given a body
        case bodyNotAllowed(Method)
    }

    /// A fluent, value-type builder: every method returns a changed copy and leaves the original alone
    public struct Builder: Sendable {
        private let baseURL: URL

        public init(baseURL: URL) {
            self.baseURL = baseURL
        }

        /// The HTTP method; GET until set
        public func method(_ method: Method) -> Builder {
            // Write your solution here, then run:
            // swift test --filter CreationalRequestBuilderTests
            self
        }

        /// The path after the base URL, starting with "/"; "/" until set
        public func path(_ path: String) -> Builder {
            self
        }

        /// Appends a query item; a nil value adds nothing
        public func query(_ name: String, _ value: String?) -> Builder {
            self
        }

        /// Sets a header, replacing any earlier value for the same name in any letter case
        public func header(_ name: String, _ value: String) -> Builder {
            self
        }

        /// Encodes `value` as JSON with sorted keys, and sets Content-Type to application/json
        public func jsonBody(_ value: some Encodable) throws -> Builder {
            self
        }

        /// The request's timeout in seconds; 60 until set
        public func timeout(_ seconds: TimeInterval) -> Builder {
            self
        }

        /// Checks the parts, then makes the request
        public func build() throws(BuildError) -> URLRequest {
            URLRequest(url: baseURL)
        }
    }
}
