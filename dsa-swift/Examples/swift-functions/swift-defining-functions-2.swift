// Generated from src/dsa/content/lessons/swift-functions/swift-defining-functions.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func greet(name: String) {
    print("Hello, \(name)!")
}

func describe(name: String, age: Int) {
    print("\(name) is \(age) years old.")
}

greet(name: "Maneet")
greet(name: "Ada")
describe(name: "Grace", age: 85)
