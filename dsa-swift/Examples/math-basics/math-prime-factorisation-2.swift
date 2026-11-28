// Generated from src/dsa/content/lessons/math-basics/math-prime-factorisation.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let exponents = [3, 2, 1]
let choices = exponents.map { $0 + 1 }
print(choices, choices.reduce(1, *))
