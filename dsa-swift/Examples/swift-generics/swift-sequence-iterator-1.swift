// Generated from src/dsa/content/lessons/swift-generics/swift-sequence-iterator.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let numbers = [10, 20, 30]

for number in numbers {
    print(number)
}

var iterator = numbers.makeIterator()
while let number = iterator.next() {
    print(number)
}
