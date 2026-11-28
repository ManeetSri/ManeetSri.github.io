// Generated from src/dsa/content/lessons/interview-playbook/int-swift-gotchas.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let big = 3_000_000_000
print(big * big)                                   // 9 × 10¹⁸ just fits below Int.max
let (_, overflowed) = big.multipliedReportingOverflow(by: big * big)
print(overflowed)                                  // a third factor wouldn't fit
let low = Int.max - 5
let high = Int.max - 1
print(low + (high - low) / 2)                      // (low + high) / 2 would trap
print(Int.max &+ 1 == Int.min)                     // &+ wraps on purpose, for hashing
