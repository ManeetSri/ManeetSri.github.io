// Generated from src/dsa/content/lessons/swift-types/swift-mutating.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Percentage {
    let value: Int

    init?(_ value: Int) {
        guard value >= 0 && value <= 100 else {
            return nil
        }
        self.value = value
    }
}

if let score = Percentage(85) {
    print("Valid:", score.value)
}
if Percentage(140) == nil {
    print("140 is not a percentage")
}
