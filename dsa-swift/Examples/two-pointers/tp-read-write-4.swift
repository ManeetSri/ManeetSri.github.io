// Generated from src/dsa/content/lessons/two-pointers/tp-read-write.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var items = [3, 1, 3, 2, 3, 4]
items.removeAll { $0 == 3 }
print(items)
