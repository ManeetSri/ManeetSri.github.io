// Generated from src/dsa/content/lessons/geometry/geo-epsilon.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

import Foundation

let angle = Double.pi / 2
let turned = (x: cos(angle), y: sin(angle))        // (1, 0) turned a quarter-turn counterclockwise
print(turned.x == 0, turned.y == 1)
print(String(format: "%.3e", turned.x))

// The crossing point of the lines through (1, 2)–(9, 5) and (2, 8)–(7, 1), computed in Double
let (ax, ay, rx, ry) = (1.0, 2.0, 8.0, 3.0)        // first line: a + t·r
let (cx, cy, sx, sy) = (2.0, 8.0, 5.0, -7.0)       // second line: c + u·s
let t = ((cx - ax) * sy - (cy - ay) * sx) / (rx * sy - ry * sx)
let (px, py) = (ax + t * rx, ay + t * ry)
let onFirstLine = rx * (py - ay) - ry * (px - ax)  // the orientation of p: exactly 0 in real maths
print(onFirstLine == 0, abs(onFirstLine) < 1e-9)
print(String(format: "%.2e", onFirstLine))
