// Generated from src/dsa/content/lessons/strings-basic/str-naive-matching.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let composed = "café"
let decomposed = "cafe\u{301}"
print(Array(composed) == Array(decomposed))
print(Array(composed.utf8) == Array(decomposed.utf8))
