// Generated from src/dsa/content/lessons/binary-search/bs-invariants.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func correct(_ items: [Int], _ target: Int) -> Int? {
    var low = 0
    var high = items.count - 1
    while low <= high {
        let mid = low + (high - low) / 2
        if items[mid] == target { return mid }
        if items[mid] < target { low = mid + 1 } else { high = mid - 1 }
    }
    return nil
}

func stopsEarly(_ items: [Int], _ target: Int) -> Int? {
    var low = 0
    var high = items.count - 1
    while low < high {                         // bug: closed range, half-open condition
        let mid = low + (high - low) / 2
        if items[mid] == target { return mid }
        if items[mid] < target { low = mid + 1 } else { high = mid - 1 }
    }
    return nil
}

func firstFailure(_ search: ([Int], Int) -> Int?) -> String {
    for count in 0...6 {
        let items = (0..<count).map { $0 * 2 }           // 0, 2, 4, …
        for target in -1...(2 * count) {                 // every value and every gap
            if search(items, target) != items.firstIndex(of: target) {
                return "fails for \(target) in \(items)"
            }
        }
    }
    return "passes every case"
}

print("correct:", firstFailure(correct))
print("stopsEarly:", firstFailure(stopsEarly))
