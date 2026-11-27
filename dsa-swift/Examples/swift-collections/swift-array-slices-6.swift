// Generated from src/dsa/content/lessons/swift-collections/swift-array-slices.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func total(_ numbers: ArraySlice<Int>) -> Int {
    guard let first = numbers.first else { return 0 }
    return first + total(numbers.dropFirst())
}

let numbers = [10, 20, 30, 40]
print(total(numbers[...]))
print(total(numbers[2...]))
