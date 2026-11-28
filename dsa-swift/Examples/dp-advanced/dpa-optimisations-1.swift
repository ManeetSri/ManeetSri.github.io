// Generated from src/dsa/content/lessons/dp-advanced/dpa-optimisations.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Hop along stones from the first to the last, at most k stones per hop, collecting every score you land on
// best[i] = score[i] + the largest best[j] among the k stones before i
func bestScoreSlow(_ score: [Int], k: Int) -> Int {
    var best = [Int](repeating: 0, count: score.count)
    best[0] = score[0]
    for i in 1..<score.count {
        var top = Int.min
        for j in max(0, i - k)..<i {                  // scan the whole window: O(k) per stone
            top = max(top, best[j])
        }
        best[i] = score[i] + top
    }
    return best[score.count - 1]
}

func bestScore(_ score: [Int], k: Int) -> Int {
    var best = [Int](repeating: 0, count: score.count)
    best[0] = score[0]
    var window = [0]                                  // indexes, their best values decreasing front to back
    var head = 0                                      // window[head...] is the live part
    for i in 1..<score.count {
        while window[head] < i - k { head += 1 }      // the front fell out of reach
        best[i] = score[i] + best[window[head]]       // the front is the window's maximum
        while window.count > head && best[window[window.count - 1]] <= best[i] {
            window.removeLast()                       // never better than i again: i is at least as good and newer
        }
        window.append(i)
    }
    return best[score.count - 1]
}

let score = [3, -5, -2, 4, -10, -1, 6, -7, -3, 2]
print(bestScoreSlow(score, k: 3), bestScore(score, k: 3))
let long = (0..<200_000).map { ($0 * 7_919 + 17) % 201 - 100 }
print(bestScoreSlow(Array(long.prefix(3_000)), k: 500), bestScore(Array(long.prefix(3_000)), k: 500))
print(bestScore(long, k: 50_000))
