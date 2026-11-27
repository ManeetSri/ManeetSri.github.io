// Generated from src/dsa/content/lessons/patterns/pat-mixed-drills.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Gigs that can't overlap: the earliest-end greedy against the DP that weighs the fees
typealias Gig = (start: Int, end: Int, fee: Int)

// Greedy: keep every gig that starts after the last kept one ends. Most gigs, not most money.
func greedyFees(_ gigs: [Gig]) -> Int {
    var total = 0
    var lastEnd = Int.min
    for gig in gigs.sorted(by: { $0.end < $1.end }) where gig.start >= lastEnd {
        total += gig.fee
        lastEnd = gig.end
    }
    return total
}

// DP: best[i] is the most money from the first i gigs by end time.
// Gig i - 1 is either skipped, or taken along with the best of the gigs that end by its start.
func bestFees(_ gigs: [Gig]) -> Int {
    let sorted = gigs.sorted { $0.end < $1.end }
    var best = Array(repeating: 0, count: sorted.count + 1)
    for i in 1...sorted.count {
        let gig = sorted[i - 1]
        var low = 0                               // how many gigs end by gig.start: binary search
        var high = i - 1
        while low < high {
            let mid = (low + high) / 2
            if sorted[mid].end <= gig.start { low = mid + 1 } else { high = mid }
        }
        best[i] = max(best[i - 1], gig.fee + best[low])
    }
    return best[sorted.count]
}

let gigs: [Gig] = [(1, 3, 20), (2, 9, 100), (3, 5, 20), (5, 7, 20), (8, 10, 30)]
print("greedy:", greedyFees(gigs), "DP:", bestFees(gigs))
