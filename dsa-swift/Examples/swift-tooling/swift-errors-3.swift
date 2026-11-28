// Generated from src/dsa/content/lessons/swift-tooling/swift-errors.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

enum AgeError: Error {
    case notANumber(String)
}

func parseAge(_ text: String) throws -> Int {
    guard let age = Int(text) else { throw AgeError.notANumber(text) }
    return age
}

let a = (try? parseAge("7")) ?? 0
let b = (try? parseAge("seven")) ?? 0
print(a, b)

if let age = try? parseAge("19") {
    print("Got \(age)")
}
