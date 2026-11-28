// Generated from src/dsa/content/lessons/swift-collections/swift-array-mutation.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var letters = ["a", "c", "d"]
letters.insert("b", at: 1)
print(letters)
letters.insert("z", at: 0)
print(letters)
letters.insert("e", at: letters.count)
print(letters)
