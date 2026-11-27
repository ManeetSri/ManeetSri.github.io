// Generated from src/dsa/content/lessons/swift-types-operators/swift-overflow.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let big = Int.max
let result = big.addingReportingOverflow(1)
print(result.overflow)
print(result.partialValue == Int.min)
let safe = 40.addingReportingOverflow(2)
print(safe.overflow, safe.partialValue)
