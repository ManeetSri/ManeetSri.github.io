// Generated from src/dsa/content/lessons/strings-basic/str-reverse-words.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let text = "  the sky   is blue "
let words = text.split(separator: " ")
print(words.count)
print(words.reversed().joined(separator: " "))
