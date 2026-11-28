// Generated from src/dsa/content/lessons/swift-closures/swift-closure-syntax.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let double = { (number: Int) -> Int in
    return number * 2
}

let greet = { (name: String) in
    print("Hello, \(name)!")
}

print(double(21))
greet("Maneet")
