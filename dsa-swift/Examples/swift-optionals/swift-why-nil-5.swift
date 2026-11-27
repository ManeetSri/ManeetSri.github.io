// Generated from src/dsa/content/lessons/swift-optionals/swift-why-nil.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let reply: Int? = Int("17")

switch reply {
case .some(let value):
    print("Got the number \(value)")
case .none:
    print("That wasn't a number")
}
