// Generated from src/dsa/content/lessons/bits/bits-single-bits.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let colour = 0xFF8800
let red = (colour >> 16) & 0xFF
let green = (colour >> 8) & 0xFF
let blue = colour & 0xFF
print(red, green, blue)

let rebuilt = (red << 16) | (green << 8) | blue
print(rebuilt == colour)
