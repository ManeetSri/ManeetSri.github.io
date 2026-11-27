// Generated from src/dsa/content/lessons/swift-functions/swift-argument-labels.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func area(width: Int, height: Int) -> Int {
    width * height
}

func area(side: Int) -> Int {
    side * side
}

print(area(width: 3, height: 4))
print(area(side: 5))
