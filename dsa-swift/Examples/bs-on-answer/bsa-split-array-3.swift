// Generated from src/dsa/content/lessons/bs-on-answer/bsa-split-array.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func partsNeeded(_ values: [Int], limit: Int) -> Int {
    var parts = 1
    var current = 0
    for value in values {
        if current + value > limit {
            parts += 1
            current = 0
        }
        current += value
    }
    return parts
}

func smallestLargestPart(_ values: [Int], parts k: Int) -> Int {
    var low = values.max()!
    var high = values.reduce(0, +)
    while low < high {
        let mid = low + (high - low) / 2
        if partsNeeded(values, limit: mid) <= k { high = mid } else { low = mid + 1 }
    }
    return low
}

func allocateBooks(_ pages: [Int], students: Int) -> Int {
    guard students <= pages.count else { return -1 }     // someone would get no book
    return smallestLargestPart(pages, parts: students)
}

func paintingTime(_ boards: [Int], painters: Int, minutesPerUnit: Int) -> Int {
    minutesPerUnit * smallestLargestPart(boards, parts: painters)   // idle painters are fine
}

print(allocateBooks([120, 45, 300, 80, 95], students: 2))
print(allocateBooks([120, 45, 300, 80, 95], students: 6))
print(paintingTime([10, 20, 30, 40], painters: 2, minutesPerUnit: 5))
print(paintingTime([10, 20, 30, 40], painters: 6, minutesPerUnit: 5))
