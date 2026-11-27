// Generated from src/dsa/content/lessons/bits/bits-counting.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let a = 0b1011_0110
let b = 0b1001_1100
print((a ^ b).nonzeroBitCount)
print(0b1011.nonzeroBitCount & 1, 0b1001.nonzeroBitCount & 1)
