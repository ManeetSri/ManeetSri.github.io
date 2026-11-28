// Generated from src/dsa/content/lessons/swift-functions/swift-returning-tuples.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func divide(_ dividend: Int, by divisor: Int) -> (quotient: Int, remainder: Int) {
    (dividend / divisor, dividend % divisor)
}

let (hours, minutes) = divide(135, by: 60)
print("\(hours)h \(minutes)m")

let (_, leftover) = divide(20, by: 6)
print(leftover)
