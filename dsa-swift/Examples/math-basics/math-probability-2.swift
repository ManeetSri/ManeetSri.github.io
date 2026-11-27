// Generated from src/dsa/content/lessons/math-basics/math-probability.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var atLeastOneSix = 0
var outcomes = 0
for a in 1...6 {
    for b in 1...6 {
        for c in 1...6 {
            for d in 1...6 {
                outcomes += 1
                if a == 6 || b == 6 || c == 6 || d == 6 {
                    atLeastOneSix += 1
                }
            }
        }
    }
}
print(atLeastOneSix, outcomes)
print(outcomes - 5 * 5 * 5 * 5)
