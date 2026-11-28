// Generated from src/dsa/content/lessons/interview-playbook/int-clarifying.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let word = "caf\u{E9}"                  // café, with é as one scalar
print(word.count, word.utf8.count)
let thumbs = "\u{1F44D}\u{1F3FD}"       // a thumbs-up with a skin tone
print(thumbs.count, thumbs.unicodeScalars.count, thumbs.utf8.count)
print(word == "cafe\u{301}")            // e followed by a combining accent
