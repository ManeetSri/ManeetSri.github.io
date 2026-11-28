// Generated from src/dsa/content/lessons/swift-tooling/swift-errors.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

enum AgeError: Error {
    case empty
    case notANumber(String)
}

func parseAge(_ text: String) throws -> Int {
    if text.isEmpty { throw AgeError.empty }
    guard let age = Int(text) else { throw AgeError.notANumber(text) }
    return age
}

func totalAge(of texts: [String]) throws -> Int {
    var total = 0
    for text in texts {
        total += try parseAge(text)    // an error here leaves totalAge immediately
    }
    return total
}

do {
    print(try totalAge(of: ["30", "12"]))
    print(try totalAge(of: ["30", "x", "12"]))
    print("never printed")
} catch {
    print("Failed: \(error)")
}
