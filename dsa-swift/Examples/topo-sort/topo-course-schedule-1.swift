// Generated from src/dsa/content/lessons/topo-sort/topo-course-schedule.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Another common format: [course, prerequisite], meaning "to take course, first take prerequisite"
let given = [[1, 0], [2, 1], [2, 0]]
let pairs = given.map { [$0[1], $0[0]] }          // flipped into [before, after]
print(pairs)
