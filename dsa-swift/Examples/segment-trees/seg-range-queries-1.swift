// Generated from src/dsa/content/lessons/segment-trees/seg-range-queries.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Count the array slots each approach touches for the same mix of operations
let n = 1_000
var plain = Array(repeating: 1, count: n)
var prefix = Array(0...n)                  // prefix[i] = sum of the first i items, all 1s for now
var plainWork = 0
var prefixWork = 0

for step in 0..<1_000 {
    if step % 2 == 0 {
        let index = step / 2                // update: set items[index] to 5
        let change = 5 - plain[index]
        plain[index] = 5
        plainWork += 1
        for slot in (index + 1)...n {       // every later prefix includes items[index]
            prefix[slot] += change
            prefixWork += 1
        }
    } else {
        var total = 0                       // query: the sum of every item
        for value in plain {
            total += value
            plainWork += 1
        }
        let fromPrefix = prefix[n] - prefix[0]
        prefixWork += 2
        precondition(total == fromPrefix)
    }
}
print("plain array:", plainWork, "slots")
print("prefix sums:", prefixWork, "slots")
print("final sum:", prefix[n])
