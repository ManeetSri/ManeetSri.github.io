// Generated from src/dsa/content/lessons/arrays/arrays-insert-delete-cost.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var readings = [3, -1, 4, -1, 5, -9, 2, -6]
readings.removeAll { $0 < 0 }
print(readings)
