// Generated from src/dsa/design/content/lessons/sd-behavioural-2/sd-behavioural-interpreter.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

// The grammar:  pattern = segment ("/" segment)*   segment = literal | ":" name | "*"
enum Segment: Equatable {
    case literal(String)
    case parameter(String)
    case rest          // "*": everything that's left, and only allowed last
}

enum PatternError: Error {
    case empty, emptySegment, duplicate(String), restNotLast
}

struct RoutePattern {
    let segments: [Segment]

    // Parsing: text in, a checked tree (here, a list) out. Done once, at launch or in a test.
    init(_ text: String) throws(PatternError) {
        let parts = text.split(separator: "/", omittingEmptySubsequences: false).dropFirst()
        guard !parts.isEmpty else { throw .empty }
        var names: Set<String> = []
        segments = try parts.map { (part) throws(PatternError) -> Segment in
            if part.isEmpty { throw .emptySegment }
            if part == "*" { return .rest }
            guard part.hasPrefix(":") else { return .literal(String(part)) }
            let name = String(part.dropFirst())
            guard names.insert(name).inserted else { throw .duplicate(name) }
            return .parameter(name)
        }
        if let index = segments.firstIndex(of: .rest), index != segments.count - 1 { throw .restNotLast }
    }

    // Interpreting: walk the segments against a path, collecting parameters
    func match(_ path: [String]) -> [String: String]? {
        var captured: [String: String] = [:]
        for (index, segment) in segments.enumerated() {
            switch segment {
            case .rest:
                captured["*"] = path.dropFirst(index).joined(separator: "/")
                return captured
            case .literal(let word):
                guard index < path.count, path[index] == word else { return nil }
            case .parameter(let name):
                guard index < path.count else { return nil }
                captured[name] = path[index]
            }
        }
        return path.count == segments.count ? captured : nil
    }
}

enum Route {
    case profile(userID: Int)
    case post(userID: Int, postID: Int)
    case settings
    case help(topic: String)
}

struct Router {
    private var table: [(RoutePattern, ([String: String]) -> Route?)] = []

    mutating func add(_ pattern: String, _ build: @escaping ([String: String]) -> Route?) throws(PatternError) {
        table.append((try RoutePattern(pattern), build))
    }

    // First match wins, so order the table from specific to general
    func route(for url: URL) -> Route? {
        let path = Array(url.pathComponents.dropFirst())   // drop the leading "/"
        for (pattern, build) in table {
            if let parameters = pattern.match(path), let route = build(parameters) { return route }
        }
        return nil
    }
}

var router = Router()
try router.add("/settings") { _ in .settings }
try router.add("/users/:id") { p in
    p["id"].flatMap(Int.init).map { .profile(userID: $0) }
}
try router.add("/users/:id/posts/:post") { p in
    guard let user = p["id"].flatMap(Int.init), let post = p["post"].flatMap(Int.init) else { return nil }
    return .post(userID: user, postID: post)
}
try router.add("/help/*") { p in
    p["*"].map { .help(topic: $0) }
}

for path in ["/users/42", "/users/42/posts/7", "/users/alex", "/help/billing/refunds", "/settings/advanced"] {
    let route = URL(string: "https://example.com" + path).flatMap(router.route(for:))
    print(path, "→", route.map { "\($0)" } ?? "no match")
}

for bad in ["/users/:id/friends/:id", "/files/*/edit", "/users//posts"] {
    do throws(PatternError) {
        _ = try RoutePattern(bad)
    } catch {
        print(bad, "is rejected:", error)
    }
}
