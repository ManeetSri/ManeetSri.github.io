// Generated from src/dsa/content/lessons/swift-closures/swift-closure-syntax.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let isLong: (String) -> Bool = { $0.count > 5 }
let isShort = { (word: String) in word.count < 4 }

print(isLong("butterfly"), isShort("butterfly"))
print(["ox", "zebra", "elephant"].filter(isLong))
