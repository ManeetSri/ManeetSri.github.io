// Generated from src/dsa/content/lessons/swift-closures/swift-closure-syntax.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let numbers = [5, 2, 9, 1]

let descending = numbers.sorted(by: { $0 > $1 })
let alsoDescending = numbers.sorted() { $0 > $1 }
let stillDescending = numbers.sorted { $0 > $1 }

print(descending)
print(alsoDescending)
print(stillDescending)
