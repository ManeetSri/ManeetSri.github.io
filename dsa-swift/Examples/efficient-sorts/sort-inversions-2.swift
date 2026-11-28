// Generated from src/dsa/content/lessons/efficient-sorts/sort-inversions.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Insertion sort shifts each element left past every bigger element before it.
// Each shift fixes exactly one inversion, so shifts = inversions.
func insertionSortShifts(_ numbers: [Int]) -> Int {
    var items = numbers
    var shifts = 0
    for next in 1..<items.count {
        let value = items[next]
        var slot = next
        while slot > 0 && items[slot - 1] > value {
            items[slot] = items[slot - 1]
            slot -= 1
            shifts += 1
        }
        items[slot] = value
    }
    return shifts
}

func bruteForceInversions(_ numbers: [Int]) -> Int {
    var count = 0
    for i in numbers.indices {
        for j in (i + 1)..<numbers.count where numbers[i] > numbers[j] {
            count += 1
        }
    }
    return count
}

for numbers in [[2, 4, 1, 3, 5], [5, 4, 3, 2, 1], [1, 2, 3, 5, 4], [3, 1, 3, 2]] {
    print(numbers, "shifts \(insertionSortShifts(numbers)), inversions \(bruteForceInversions(numbers))")
}
