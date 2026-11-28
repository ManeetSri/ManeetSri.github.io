// Generated from src/dsa/content/lessons/math-basics/math-modular-arithmetic.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let mod = 1_000_000_007
let check = (mod - 1).multipliedReportingOverflow(by: mod - 1)
print(check.overflow, check.partialValue)

let big = 999_999_999_999
print(big.multipliedReportingOverflow(by: big).overflow)
