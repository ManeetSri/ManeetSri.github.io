// Generated from src/dsa/content/lessons/bs-on-answer/bsa-idea.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// A display of n rows needs 1 + 2 + … + n cans
func cansNeeded(rows: Int) -> Int {
    rows * (rows + 1) / 2
}

for rows in [10, 30, 43, 44, 45, 46, 60] {
    let cans = cansNeeded(rows: rows)
    print("\(rows) rows: \(cans) cans, enough? \(cans >= 1_000)")
}
