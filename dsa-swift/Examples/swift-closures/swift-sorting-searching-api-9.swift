// Generated from src/dsa/content/lessons/swift-closures/swift-sorting-searching-api.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let numbers = [4, 9, 15, 2, 30]

let hasBig = numbers.contains { number in
    print("checking \(number)")
    return number > 10
}
print(hasBig)
