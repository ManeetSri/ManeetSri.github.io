// Generated from src/dsa/content/lessons/swift-functions/swift-default-variadic.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func greet(_ name: String, greeting: String = "Hello") {
    print("\(greeting), \(name)!")
}

greet("Maneet")
greet("Ada", greeting: "Good morning")
