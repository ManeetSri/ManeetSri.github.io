// Generated from src/dsa/content/lessons/topo-sort/topo-parallel-courses.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let names = ["Swift", "Maths", "Collections", "Recursion", "Trees", "Graphs", "Capstone"]
let prerequisites = [[0, 2], [0, 3], [1, 3], [2, 4], [3, 4], [4, 5], [1, 5], [5, 6], [2, 6]]
var unlocks = Array(repeating: [Int](), count: names.count)
for pair in prerequisites {
    unlocks[pair[0]].append(pair[1])
}

// Every pair goes from a lower label to a higher one, so 0, 1, 2, … is a topological order here.
// In general, get one from Kahn's algorithm first.
var semester = Array(repeating: 1, count: names.count)
for course in names.indices {
    for after in unlocks[course] {
        semester[after] = max(semester[after], semester[course] + 1)
    }
}
for course in names.indices {
    print(names[course], semester[course])
}
print("fewest semesters:", semester.max()!)
