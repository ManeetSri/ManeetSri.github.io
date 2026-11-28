// Generated from src/dsa/content/lessons/sliding-window/sw-fixed.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let items = [2, 1, 5, 1, 3, 2]
let k = 3
for start in 0...(items.count - k) {
    let window = Array(items[start..<start + k])
    print(start, window, window.reduce(0, +))
}
