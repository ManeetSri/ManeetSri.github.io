// Generated from src/dsa/content/lessons/math-basics/math-counting.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let shirts = ["red", "blue", "white"]
let trousers = ["jeans", "chinos", "shorts", "cords"]
var outfits = 0
for _ in shirts {
    for _ in trousers {
        outfits += 1
    }
}
print(outfits)
