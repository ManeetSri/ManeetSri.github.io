// Generated from src/dsa/content/lessons/geometry/geo-epsilon.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

import Foundation

for value in [1e-12, 1.0, 1_000.0, 1e9] {
    print(String(format: "%-6g gap to the next Double: %.2e", value, value.ulp))
}
