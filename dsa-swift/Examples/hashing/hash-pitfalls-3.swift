// Generated from src/dsa/content/lessons/hashing/hash-pitfalls.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let prices: [Double: String] = [0.3: "thirty pence"]
print(prices[0.1 + 0.2] ?? "not found")
print(0.1 + 0.2)

let pence: [Int: String] = [30: "thirty pence"]
print(pence[10 + 20] ?? "not found")
