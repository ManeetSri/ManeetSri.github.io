// Generated from src/dsa/content/lessons/swift-tooling/swift-errors.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

enum AgeError: Error {
    case empty
    case notANumber(String)
}

func checkedAge(_ text: String) -> Result<Int, AgeError> {
    if text.isEmpty { return .failure(.empty) }
    guard let age = Int(text) else { return .failure(.notANumber(text)) }
    return .success(age)
}

let results = ["8", "", "x", "21"].map(checkedAge)
for result in results {
    switch result {
    case .success(let age):
        print("ok \(age)")
    case .failure(let error):
        print("failed: \(error)")
    }
}

let ages = results.compactMap { try? $0.get() }
print(ages)
