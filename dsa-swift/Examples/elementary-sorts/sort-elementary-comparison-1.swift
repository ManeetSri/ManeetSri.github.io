// Generated from src/dsa/content/lessons/elementary-sorts/sort-elementary-comparison.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Counts {
    var comparisons = 0
    var writes = 0
}

func bubble(_ input: [Int]) -> Counts {
    var items = input
    var counts = Counts()
    guard items.count > 1 else { return counts }
    for pass in 0..<(items.count - 1) {
        var swapped = false
        for j in 0..<(items.count - 1 - pass) {
            counts.comparisons += 1
            if items[j] > items[j + 1] {
                items.swapAt(j, j + 1)
                counts.writes += 2
                swapped = true
            }
        }
        if !swapped { break }
    }
    return counts
}

func selection(_ input: [Int]) -> Counts {
    var items = input
    var counts = Counts()
    guard items.count > 1 else { return counts }
    for i in 0..<(items.count - 1) {
        var smallest = i
        for j in (i + 1)..<items.count {
            counts.comparisons += 1
            if items[j] < items[smallest] { smallest = j }
        }
        if smallest != i {
            items.swapAt(i, smallest)
            counts.writes += 2
        }
    }
    return counts
}

func insertion(_ input: [Int]) -> Counts {
    var items = input
    var counts = Counts()
    guard items.count > 1 else { return counts }
    for i in 1..<items.count {
        let key = items[i]
        var gap = i
        while gap > 0 {
            counts.comparisons += 1
            guard items[gap - 1] > key else { break }
            items[gap] = items[gap - 1]
            counts.writes += 1
            gap -= 1
        }
        if gap != i {
            items[gap] = key
            counts.writes += 1
        }
    }
    return counts
}

let n = 100
let inputs = [
    ("sorted", Array(0..<n)),
    ("reversed", Array((0..<n).reversed())),
    ("shuffled", (0..<n).map { ($0 * 37) % n }),
]
let sorts = [("bubble", bubble), ("selection", selection), ("insertion", insertion)]
for (inputName, input) in inputs {
    for (sortName, sort) in sorts {
        let counts = sort(input)
        print("\(inputName), \(sortName): \(counts.comparisons) comparisons, \(counts.writes) writes")
    }
}
