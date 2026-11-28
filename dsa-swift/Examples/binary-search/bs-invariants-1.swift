// Generated from src/dsa/content/lessons/binary-search/bs-invariants.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func closedSearch(_ items: [Int], for target: Int) -> Int? {
    var low = 0
    var high = items.count - 1                 // invariant: if present, target is in [low, high]
    while low <= high {
        let mid = low + (high - low) / 2
        print("  closed [\(low), \(high)], mid \(mid)")
        if items[mid] == target {
            return mid
        } else if items[mid] < target {
            low = mid + 1
        } else {
            high = mid - 1
        }
    }
    return nil
}

func halfOpenSearch(_ items: [Int], for target: Int) -> Int? {
    var low = 0
    var high = items.count                     // invariant: if present, target is in [low, high)
    while low < high {
        let mid = low + (high - low) / 2
        print("  half-open [\(low), \(high)), mid \(mid)")
        if items[mid] == target {
            return mid
        } else if items[mid] < target {
            low = mid + 1
        } else {
            high = mid
        }
    }
    return nil
}

let items = [4, 9, 15, 22, 31, 40]
print("closed:", closedSearch(items, for: 9) as Any)
print("half-open:", halfOpenSearch(items, for: 9) as Any)
