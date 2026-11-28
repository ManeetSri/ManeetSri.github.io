// Generated from src/dsa/content/lessons/interview-playbook/int-swift-gotchas.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var wrong: [Character: Int] = [:]
for c in "banana" {
    wrong[c] = wrong[c] ?? 0 + 1                   // means wrong[c] ?? (0 + 1)
}
var counts: [Character: Int] = [:]
for c in "banana" {
    counts[c, default: 0] += 1
}
print(wrong["a"] ?? 0, counts["a"] ?? 0)
var byLength: [Int: [String]] = [:]
for word in ["hi", "yo", "hey"] {
    byLength[word.count, default: []].append(word)  // appends in place, no copy
}
print(byLength[2] ?? [], byLength[3] ?? [])
