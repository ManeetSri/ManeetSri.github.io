// Generated from src/dsa/content/lessons/greedy/greedy-huffman.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let careless: [Character: String] = ["a": "0", "b": "01", "c": "1"]
func encode(_ text: String) -> String {
    text.map { careless[$0]! }.joined()
}
print(encode("ac"), encode("b"))
