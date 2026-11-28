// Generated from src/dsa/content/lessons/string-algorithms/sa-suffix-array.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The suffix array the obvious way: sort the starting positions by the suffixes they start
let text = Array("banana".utf8)
let sa = text.indices.sorted { text[$0...].lexicographicallyPrecedes(text[$1...]) }
print(sa)
for start in sa {
    print(start, String(decoding: text[start...], as: UTF8.self))
}
