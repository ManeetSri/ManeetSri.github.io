// Generated from src/dsa/content/lessons/intervals/iv-merge-insert.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var merged = [[1, 3]]
var last = merged[merged.count - 1]
last[1] = 6
print(merged, last)
merged[merged.count - 1][1] = 6
print(merged)
