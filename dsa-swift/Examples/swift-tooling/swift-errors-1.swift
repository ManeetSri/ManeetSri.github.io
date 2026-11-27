// Generated from src/dsa/content/lessons/swift-tooling/swift-errors.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

enum AgeError: Error {
    case empty
    case notANumber(String)
    case outOfRange(Int)
}

func parseAge(_ text: String) throws -> Int {
    if text.isEmpty {
        throw AgeError.empty
    }
    guard let age = Int(text) else {
        throw AgeError.notANumber(text)
    }
    guard age >= 0 && age <= 150 else {
        throw AgeError.outOfRange(age)
    }
    return age
}

for input in ["42", "", "forty", "200"] {
    do {
        let age = try parseAge(input)
        print("Age: \(age)")
    } catch AgeError.empty {
        print("Please type an age")
    } catch AgeError.notANumber(let text) {
        print("'\(text)' isn't a number")
    } catch {
        print("Something else went wrong: \(error)")
    }
}
