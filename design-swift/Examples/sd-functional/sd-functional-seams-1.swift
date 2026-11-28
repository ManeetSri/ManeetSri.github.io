// Generated from src/dsa/design/content/lessons/sd-functional/sd-functional-seams.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

struct Offline: Error {}

typealias Fetch = (String) throws -> String

/// Prints each call and its outcome, then passes everything through unchanged
func logged(_ name: String, _ fetch: @escaping Fetch) -> Fetch {
    { path in
        print("→ \(name) \(path)")
        do {
            let body = try fetch(path)
            print("← \(name) ok")
            return body
        } catch {
            print("← \(name) failed: \(error)")
            throw error
        }
    }
}

/// Tries up to `attempts` times, rethrowing the last error
func retrying(_ attempts: Int, _ fetch: @escaping Fetch) -> Fetch {
    { path in
        var lastError: any Error = Offline()
        for _ in 0..<attempts {
            do { return try fetch(path) } catch { lastError = error }
        }
        throw lastError
    }
}

/// Remembers each successful answer, so a second request for the same path never reaches `fetch`
func cached(_ fetch: @escaping Fetch) -> Fetch {
    var answers: [String: String] = [:]
    return { path in
        if let answer = answers[path] { return answer }
        let answer = try fetch(path)
        answers[path] = answer
        return answer
    }
}

/// A server that drops the first request, as a phone does when the radio is waking up
final class FlakyServer {
    private var requests = 0

    func get(_ path: String) throws -> String {
        requests += 1
        if requests == 1 { throw Offline() }
        return "profile for \(path)"
    }
}

let server = FlakyServer()
let fetch = cached(retrying(3, logged("network", server.get)))

print(try fetch("/me"))
print(try fetch("/me"))
