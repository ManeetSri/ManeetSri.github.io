// Generated from src/dsa/content/lessons/bs-on-answer/bsa-bouquets.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let n = 7
let m = 10_000_000_000
let k = 10_000_000_000
print(m > n / k)                                   // the same as m × k > n, with no multiplication
let (product, overflow) = m.multipliedReportingOverflow(by: k)
print(overflow, product)
