// Generated from src/dsa/content/lessons/math-basics/math-probability.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

import Foundation

var allDifferent = 1.0
for i in 0..<23 {
    allDifferent *= Double(365 - i) / 365
}
print(String(format: "%.3f", 1 - allDifferent))
