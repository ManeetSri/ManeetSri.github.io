// Generated from src/dsa/content/lessons/math-basics/math-floor-ceil-overflow.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func pages(_ items: Int, _ perPage: Int) -> Int {
    items / perPage + (items % perPage == 0 ? 0 : 1)
}

print(pages(10, 3), pages(9, 3), pages(0, 3))
print(pages(Int.max - 1, 3))
print((Int.max - 1).addingReportingOverflow(3 - 1).overflow)
