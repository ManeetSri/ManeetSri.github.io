// Generated from src/dsa/content/lessons/swift-functions/swift-defining-functions.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func double(number: Int) -> Int {
    number * 2
}

func isEven(number: Int) -> Bool {
    number % 2 == 0
}

print(double(number: 21))
print(isEven(number: 7))
