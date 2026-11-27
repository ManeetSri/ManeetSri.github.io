// Generated from src/dsa/content/lessons/swift-control-flow/swift-guard.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func describe(age: Int) -> String {
    guard age >= 0 else {
        return "That isn't a valid age"
    }

    if age < 13 {
        return "Child"
    } else if age < 20 {
        return "Teenager"
    } else {
        return "Adult"
    }
}

print(describe(age: 8))
print(describe(age: -5))
print(describe(age: 42))
