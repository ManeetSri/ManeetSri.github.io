// Generated from src/dsa/content/lessons/fast-swift/fs-build-settings.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var validations = 0

func isSorted(_ items: [Int]) -> Bool {
    validations += 1
    return zip(items, items.dropFirst()).allSatisfy { $0 <= $1 }
}

func binarySearch(_ items: [Int], for target: Int) -> Int? {
    assert(isSorted(items), "binarySearch needs sorted input")   // O(n), debug builds only
    var low = 0
    var high = items.count - 1
    while low <= high {
        let mid = low + (high - low) / 2
        if items[mid] == target { return mid }
        if items[mid] < target { low = mid + 1 } else { high = mid - 1 }
    }
    return nil
}

let primes = [2, 3, 5, 7, 11, 13]
print(binarySearch(primes, for: 7) ?? -1)
print(binarySearch(primes, for: 4) ?? -1)
print("validations:", validations)
