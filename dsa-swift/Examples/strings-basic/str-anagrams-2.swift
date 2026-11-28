// Generated from src/dsa/content/lessons/strings-basic/str-anagrams.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let words = ["stone", "night", "notes", "thing", "onset", "tab", "bat"]
let groups = Dictionary(grouping: words) { String($0.sorted()) }

for key in groups.keys.sorted() {
    print(key, groups[key]!)
}
