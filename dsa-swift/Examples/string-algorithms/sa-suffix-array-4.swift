// Generated from src/dsa/content/lessons/string-algorithms/sa-suffix-array.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Every suffix that starts with the pattern sits in one block of the suffix array
let text = Array("mississippi".utf8)
let sa = text.indices.sorted { text[$0...].lexicographicallyPrecedes(text[$1...]) }

// The first position in sa whose suffix, cut to the pattern's length, is not below the pattern
// (or, with strict, is above it)
func boundary(_ pattern: [UInt8], strict: Bool) -> Int {
    var low = 0, high = sa.count
    while low < high {
        let mid = (low + high) / 2
        let start = sa[mid]
        let prefix = text[start..<min(start + pattern.count, text.count)]
        let goRight = strict ? !pattern.lexicographicallyPrecedes(prefix)
                             : prefix.lexicographicallyPrecedes(pattern)
        if goRight { low = mid + 1 } else { high = mid }
    }
    return low
}

for word in ["ssi", "i", "issip", "pp", "x"] {
    let p = Array(word.utf8)
    let first = boundary(p, strict: false), end = boundary(p, strict: true)
    print(word, "found at", sa[first..<end].sorted())
}
