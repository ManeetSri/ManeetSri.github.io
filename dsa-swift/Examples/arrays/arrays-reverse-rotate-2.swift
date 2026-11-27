// Generated from src/dsa/content/lessons/arrays/arrays-reverse-rotate.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let n = 5
for k in [3, 5, 12, -2, -7] {
    print(k, k % n, ((k % n) + n) % n)
}
