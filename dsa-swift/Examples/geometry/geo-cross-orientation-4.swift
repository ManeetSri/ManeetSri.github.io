// Generated from src/dsa/content/lessons/geometry/geo-cross-orientation.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// The sign of ax * by - ay * bx for any Int inputs. The two products are compared at full width
/// (128 bits), so nothing overflows.
func crossSign(_ ax: Int, _ ay: Int, _ bx: Int, _ by: Int) -> Int {
    let left = ax.multipliedFullWidth(by: by)
    let right = ay.multipliedFullWidth(by: bx)
    if (left.high, left.low) > (right.high, right.low) { return 1 }
    if (left.high, left.low) < (right.high, right.low) { return -1 }
    return 0
}

let big = 4_000_000_000
print(crossSign(big, big - 1, big + 1, big))      // each product is about 1.6 × 10¹⁹
print(crossSign(big, big, big + 1, big + 1))      // parallel
print(crossSign(3, 0, 1, 2))
