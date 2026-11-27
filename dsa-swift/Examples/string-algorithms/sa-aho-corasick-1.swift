// Generated from src/dsa/content/lessons/string-algorithms/sa-aho-corasick.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Aho–Corasick for lowercase patterns: a trie, failure links by BFS, and a complete transition table
struct Automaton {
    var next: [[Int]] = [[Int](repeating: -1, count: 26)]   // next[node][letter]
    var link: [Int] = []                                     // failure links
    var ends: [[Int]] = [[]]                                 // patterns that end exactly at each node
    var name: [String] = [""]                                // the string each node spells (for printing)
    var order: [Int] = []                                    // nodes in BFS order, root excluded

    init(_ patterns: [String]) {
        for (index, word) in patterns.enumerated() {         // 1. an ordinary trie of the patterns
            var node = 0
            for byte in word.utf8 {
                let c = Int(byte - 97)
                if next[node][c] == -1 {
                    next[node][c] = next.count
                    next.append([Int](repeating: -1, count: 26))
                    ends.append([])
                    name.append(name[node] + String(UnicodeScalar(byte)))
                }
                node = next[node][c]
            }
            ends[node].append(index)
        }
        link = [Int](repeating: 0, count: next.count)
        for c in 0..<26 {                                    // 2. BFS, starting from the root's children
            if next[0][c] == -1 {
                next[0][c] = 0                               // a missing letter at the root stays at the root
            } else {
                order.append(next[0][c])                     // depth-1 nodes link to the root
            }
        }
        var head = 0
        while head < order.count {
            let v = order[head]
            head += 1
            for c in 0..<26 {
                let child = next[v][c]
                if child != -1 {
                    link[child] = next[link[v]][c]           // v's longest suffix in the trie, plus c
                    order.append(child)
                } else {
                    next[v][c] = next[link[v]][c]            // no child: go where the failure link goes
                }
            }
        }
    }
}

let patterns = ["he", "she", "his", "hers"]
let automaton = Automaton(patterns)
for v in automaton.order {
    let target = automaton.link[v]
    print(automaton.name[v], "->", target == 0 ? "(root)" : automaton.name[target])
}

// Output links: the nearest node down the failure chain where some pattern ends
var outputLink = [Int](repeating: 0, count: automaton.next.count)
for v in automaton.order {
    let target = automaton.link[v]
    outputLink[v] = automaton.ends[target].isEmpty ? outputLink[target] : target
}

let text = Array("ahishers".utf8)
var node = 0
for (i, byte) in text.enumerated() {
    node = automaton.next[node][Int(byte - 97)]          // one table lookup per character
    var v = automaton.ends[node].isEmpty ? outputLink[node] : node
    while v != 0 {                                       // every pattern ending here
        for index in automaton.ends[v] {
            print("\(patterns[index]) at \(i - patterns[index].count + 1)")
        }
        v = outputLink[v]
    }
}

// Counting each pattern without walking output links: count visits, then push counts up the links
func counts(in text: String) -> [Int] {
    var visits = [Int](repeating: 0, count: automaton.next.count)
    var node = 0
    for byte in text.utf8 {
        node = automaton.next[node][Int(byte - 97)]
        visits[node] += 1
    }
    for v in automaton.order.reversed() {                // deepest first, so each total is complete
        visits[automaton.link[v]] += visits[v]           // reaching v also means reaching its suffix
    }
    var result = [Int](repeating: 0, count: patterns.count)
    for v in automaton.order {
        for index in automaton.ends[v] { result[index] = visits[v] }
    }
    return result
}
print(patterns, counts(in: "ahishers"), counts(in: "shehershishe"))
