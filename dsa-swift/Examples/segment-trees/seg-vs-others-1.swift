// Generated from src/dsa/content/lessons/segment-trees/seg-vs-others.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Two overlapping blocks cover items 2...6: fine for a minimum, wrong for a sum
let items = [5, 3, 7, 9, 6, 4, 1, 2]
let first = items[2...5]                          // the block of 4 that starts at 2
let second = items[3...6]                         // the block of 4 that ends at 6
print("min:", min(first.min()!, second.min()!), "true:", items[2...6].min()!)
print("sum:", first.reduce(0, +) + second.reduce(0, +), "true:", items[2...6].reduce(0, +))
