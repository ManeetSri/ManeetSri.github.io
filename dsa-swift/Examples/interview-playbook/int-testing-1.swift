// Generated from src/dsa/content/lessons/interview-playbook/int-testing.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func longestRun(_ values: [Int]) -> Int {
    guard !values.isEmpty else { return 0 }
    var best = 1
    var current = 1
    for i in values.indices.dropFirst() {
        current = values[i] == values[i - 1] ? current + 1 : 1
        best = max(best, current)
    }
    return best
}

let checks = [
    (longestRun([1, 1, 2, 2, 2]), 3, "longest run at the end"),
    (longestRun([]), 0, "empty"),
    (longestRun([7]), 1, "one element"),
    (longestRun([4, 4, 4]), 3, "all equal"),
    (longestRun([1, 2, 3]), 1, "all different"),
    (longestRun([-1, -1, 0]), 2, "negatives"),
]
var failures = 0
for (got, expected, label) in checks where got != expected {
    print("FAIL \(label): got \(got), expected \(expected)")
    failures += 1
}
print(failures == 0 ? "All \(checks.count) checks passed" : "\(failures) failed")
