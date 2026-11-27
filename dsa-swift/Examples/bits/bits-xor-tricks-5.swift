// Generated from src/dsa/content/lessons/bits/bits-xor-tricks.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var a = 5
var b = 9
a ^= b
b ^= a
a ^= b
print(a, b)
