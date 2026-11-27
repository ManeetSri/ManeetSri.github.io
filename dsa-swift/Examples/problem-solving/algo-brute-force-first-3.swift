// Generated from src/dsa/content/lessons/problem-solving/algo-brute-force-first.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func smallestMissing(_ numbers: [Int]) -> Int {
    var candidate = 1
    while numbers.contains(candidate) {
        candidate += 1
    }
    return candidate
}

func smallestMissingShortcut(_ numbers: [Int]) -> Int {
    if !numbers.contains(1) {
        return 1
    }
    return numbers.max()! + 1
}

// Every array of length 0 to 4 with values from -1 to 4
var inputs: [[Int]] = [[]]
var layer: [[Int]] = [[]]
for _ in 1...4 {
    var next: [[Int]] = []
    for array in layer {
        for value in -1...4 {
            next.append(array + [value])
        }
    }
    inputs += next
    layer = next
}

var mismatches = 0
for input in inputs {
    let expected = smallestMissing(input)
    let actual = smallestMissingShortcut(input)
    if expected != actual {
        if mismatches == 0 {
            print("First mismatch: \(input), expected \(expected), got \(actual)")
        }
        mismatches += 1
    }
}
print("Checked \(inputs.count) inputs, \(mismatches) mismatches")
