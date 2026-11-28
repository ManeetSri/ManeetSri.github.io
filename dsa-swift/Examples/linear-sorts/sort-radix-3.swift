// Generated from src/dsa/content/lessons/linear-sorts/sort-radix.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func msdSort(_ words: [[UInt8]], position: Int = 0) -> [[UInt8]] {
    guard words.count > 1 else { return words }
    var finished: [[UInt8]] = []                 // words with no character at this position
    var buckets = [[[UInt8]]](repeating: [], count: 256)
    for word in words {
        if position < word.count {
            buckets[Int(word[position])].append(word)
        } else {
            finished.append(word)
        }
    }
    var result = finished
    for bucket in buckets where !bucket.isEmpty {
        result += msdSort(bucket, position: position + 1)
    }
    return result
}

let words = ["cab", "ca", "bad", "cabin", "a", "bat"]
let sorted = msdSort(words.map { Array($0.utf8) })
print(sorted.map { String(decoding: $0, as: UTF8.self) })
