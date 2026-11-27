// Generated from src/dsa/content/lessons/bits/bits-single-bits.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let wanted = 0b0110
print(0b1110 & wanted == wanted)
print(0b1010 & wanted == wanted)
print(0b1010 & wanted != 0)
