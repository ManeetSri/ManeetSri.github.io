// Generated from src/dsa/content/lessons/dp-lis/lis-envelopes.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func lisLength(_ items: [Int]) -> Int {
    var tails: [Int] = []
    for x in items {
        var low = 0
        var high = tails.count
        while low < high {
            let mid = low + (high - low) / 2
            if tails[mid] >= x {
                high = mid
            } else {
                low = mid + 1
            }
        }
        if low == tails.count {
            tails.append(x)
        } else {
            tails[low] = x
        }
    }
    return tails.count
}

let envelopes = [(width: 5, height: 4), (width: 6, height: 4), (width: 6, height: 7), (width: 2, height: 3), (width: 6, height: 5)]

// Ties broken by height ascending: equal widths can sneak into the same chain
let ascending = envelopes.sorted { ($0.width, $0.height) < ($1.width, $1.height) }.map(\.height)
print("ties ascending:", ascending, "LIS", lisLength(ascending))

// Ties broken by height descending: at most one envelope of each width can be chosen
let descending = envelopes.sorted { ($0.width, -$0.height) < ($1.width, -$1.height) }.map(\.height)
print("ties descending:", descending, "LIS", lisLength(descending))
