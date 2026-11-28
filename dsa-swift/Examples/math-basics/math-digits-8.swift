// Generated from src/dsa/content/lessons/math-basics/math-digits.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let digits = [4, 7, 2, 1]
var value = 0
for digit in digits {
    value = value * 10 + digit
}
print(value)
