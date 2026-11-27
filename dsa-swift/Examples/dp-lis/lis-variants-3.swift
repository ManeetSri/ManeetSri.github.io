// Generated from src/dsa/content/lessons/dp-lis/lis-variants.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func longestWordChain(_ words: [String]) -> Int {
    var best: [String: Int] = [:]                 // the longest chain ending at each word seen so far
    var answer = 0
    for word in words.sorted(by: { $0.count < $1.count }) {
        var chain = 1
        let letters = Array(word)
        for skip in letters.indices {
            var shorter = letters
            shorter.remove(at: skip)              // the word with one letter deleted
            if let before = best[String(shorter)] {
                chain = max(chain, before + 1)
            }
        }
        best[word] = chain
        answer = max(answer, chain)
    }
    print("chart:", best["chart", default: 0], "dog:", best["dog", default: 0])
    return answer
}

print(longestWordChain(["chart", "a", "cat", "dog", "at", "cart", "do", "chat", "art"]))
