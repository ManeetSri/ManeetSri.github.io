// Generated from src/dsa/content/lessons/swift-functions/swift-defining-functions.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func square(number: Int) -> Int {
    let result = number * number
    return result
}

let nine = square(number: 3)
print(nine)
print(square(number: 4) + square(number: 5))
print("Twelve squared is \(square(number: 12))")
