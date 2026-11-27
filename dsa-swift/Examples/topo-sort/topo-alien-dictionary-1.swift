// Generated from src/dsa/content/lessons/topo-sort/topo-alien-dictionary.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let glossary = ["rat", "rate", "re", "tar", "tea", "ear"]
for (earlier, later) in zip(glossary, glossary.dropFirst()) {
    if let (a, b) = zip(earlier, later).first(where: { $0.0 != $0.1 }) {
        print("\(earlier), \(later): \(a) before \(b)")
    } else {
        print("\(earlier), \(later): no information about letters")
    }
}
