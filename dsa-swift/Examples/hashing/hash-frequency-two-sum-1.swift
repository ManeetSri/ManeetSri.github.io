// Generated from src/dsa/content/lessons/hashing/hash-frequency-two-sum.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func canWrite(_ note: String, from magazine: String) -> Bool {
    var available: [Character: Int] = [:]
    for letter in magazine {
        available[letter, default: 0] += 1         // count what the magazine offers
    }
    for letter in note {
        available[letter, default: 0] -= 1         // spend one
        if available[letter]! < 0 {
            return false                           // spent more than there were
        }
    }
    return true
}

print(canWrite("meet at ten", from: "the tame cat sat on a mat at ten"))
print(canWrite("see you", from: "yes, you can"))
