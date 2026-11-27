// Generated from src/dsa/content/lessons/complexity/bigo-master-theorem.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

import Foundation

for (a, b) in [(2.0, 2.0), (3.0, 2.0), (4.0, 2.0), (7.0, 2.0), (8.0, 2.0), (9.0, 3.0)] {
    let exponent = log(a) / log(b)
    print("a = \(Int(a)), b = \(Int(b)): log_b a = \((exponent * 1_000).rounded() / 1_000)")
}
