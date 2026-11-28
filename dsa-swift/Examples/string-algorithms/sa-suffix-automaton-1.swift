// Generated from src/dsa/content/lessons/string-algorithms/sa-suffix-automaton.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// A suffix automaton, built one character at a time
struct SuffixAutomaton {
    var len = [0]                       // the length of the longest string in each state
    var link = [-1]                     // suffix links; the start state has none
    var next: [[UInt8: Int]] = [[:]]    // transitions
    var end = [-1]                      // an end position of the state's strings (for printing)
    var last = 0                        // the state holding the whole text read so far

    mutating func extend(_ c: UInt8) {
        let cur = len.count
        len.append(len[last] + 1)
        link.append(0)
        next.append([:])
        end.append(len[cur] - 1)
        var p = last
        while p != -1 && next[p][c] == nil {    // every suffix with no c-transition gets one, to cur
            next[p][c] = cur
            p = link[p]
        }
        if p != -1 {
            let q = next[p][c]!
            if len[p] + 1 == len[q] {
                link[cur] = q                   // q holds exactly the right strings
            } else {
                let clone = len.count           // q holds too much: split off the shorter strings
                len.append(len[p] + 1)
                link.append(link[q])
                next.append(next[q])
                end.append(end[q])
                while p != -1 && next[p][c] == q {
                    next[p][c] = clone
                    p = link[p]
                }
                link[q] = clone
                link[cur] = clone
            }
        }
        last = cur
    }
}

let text = Array("abb".utf8)
var automaton = SuffixAutomaton()
for c in text { automaton.extend(c) }
for v in automaton.len.indices.dropFirst() {
    let longest = automaton.len[v], shortest = automaton.len[automaton.link[v]] + 1
    let strings = (shortest...longest).map { String(decoding: text[(automaton.end[v] - $0 + 1)...automaton.end[v]], as: UTF8.self) }
    let moves = automaton.next[v].keys.sorted().map { "\(Character(UnicodeScalar($0)))→\(automaton.next[v][$0]!)" }
    print("state \(v): len \(longest), link \(automaton.link[v]), holds \(strings), moves \(moves)")
}
print("start moves:", automaton.next[0].keys.sorted().map { "\(Character(UnicodeScalar($0)))→\(automaton.next[0][$0]!)" })
