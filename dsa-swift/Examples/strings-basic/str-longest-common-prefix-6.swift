// Generated from src/dsa/content/lessons/strings-basic/str-longest-common-prefix.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let a = Array("café".utf8)
let b = Array("cafè".utf8)
var length = 0
while length < min(a.count, b.count) && a[length] == b[length] {
    length += 1
}
print(length)
print(String(decoding: a[0..<length], as: UTF8.self))
