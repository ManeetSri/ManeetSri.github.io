// Generated from src/dsa/content/lessons/swift-control-flow/swift-stride.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let letters = ["a", "b", "c", "d"]

var backwards = ""
for i in stride(from: letters.count - 1, through: 0, by: -1) {
    backwards += letters[i]
}
print(backwards)

var everyOther = ""
for i in stride(from: 0, to: letters.count, by: 2) {
    everyOther += letters[i]
}
print(everyOther)

for i in letters.indices.reversed() {
    print(i, letters[i])
}
