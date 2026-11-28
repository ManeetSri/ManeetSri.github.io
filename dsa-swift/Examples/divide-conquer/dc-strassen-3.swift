// Generated from src/dsa/content/lessons/divide-conquer/dc-strassen.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// One entry of a 2 × 2 product, with Doubles: C22 = A21 · B12 + A22 · B22
let (a11, a21, a22) = (1e16, 0.0, 1.0)      // A12 and B21 aren't needed for C22
let (b11, b12, b22) = (0.0, 0.0, 1.0)

let standard = a21 * b12 + a22 * b22

let m1 = (a11 + a22) * (b11 + b22)        // 1e16 + 1 rounds to 1e16: the 1 is lost here
let m2 = (a21 + a22) * b11
let m3 = a11 * (b12 - b22)
let m6 = (a21 - a11) * (b11 + b12)
let strassen = m1 - m2 + m3 + m6

print("standard:", standard)
print("Strassen:", strassen)
