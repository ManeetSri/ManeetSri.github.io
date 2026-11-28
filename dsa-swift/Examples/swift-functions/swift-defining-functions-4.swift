// Generated from src/dsa/content/lessons/swift-functions/swift-defining-functions.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func sign(of number: Int) -> String {
    if number > 0 {
        return "positive"
    }
    if number < 0 {
        return "negative"
    }
    return "zero"
}

print(sign(of: 8))
print(sign(of: -3))
print(sign(of: 0))
