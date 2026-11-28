// Generated from src/dsa/content/lessons/geometry/geo-epsilon.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func isClose(_ a: Double, _ b: Double, relative: Double = 1e-9, absolute: Double = 1e-12) -> Bool {
    abs(a - b) <= max(absolute, relative * max(abs(a), abs(b)))
}

print(isClose(0.1 + 0.2, 0.3))                       // everyday sizes
print(isClose(1e9 + 0.1, 1e9), abs((1e9 + 0.1) - 1e9) <= 1e-9)   // relative copes; absolute doesn't
print(isClose(1e-15, 0), isClose(1e-6, 0))           // near zero, the absolute part decides
print(isClose(2.0, 2.000001))                        // a real difference stays a difference
