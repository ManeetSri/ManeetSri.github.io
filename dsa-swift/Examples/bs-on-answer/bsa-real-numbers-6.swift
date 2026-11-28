// Generated from src/dsa/content/lessons/bs-on-answer/bsa-real-numbers.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

import Foundation

for x in [64, 125, 216, 343, 1_000] {
    print(x, Int(pow(Double(x), 1.0 / 3.0)))
}
