// Generated from src/dsa/content/lessons/divide-conquer/dc-strassen.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Strassen's seven products for one 2 × 2 multiplication
let (a11, a12, a21, a22) = (1, 2, 3, 4)
let (b11, b12, b21, b22) = (5, 6, 7, 8)

let m1 = (a11 + a22) * (b11 + b22)
let m2 = (a21 + a22) * b11
let m3 = a11 * (b12 - b22)
let m4 = a22 * (b21 - b11)
let m5 = (a11 + a12) * b22
let m6 = (a21 - a11) * (b11 + b12)
let m7 = (a12 - a22) * (b21 + b22)
print("M1...M7:", m1, m2, m3, m4, m5, m6, m7)

let strassen = [[m1 + m4 - m5 + m7, m3 + m5], [m2 + m4, m1 - m2 + m3 + m6]]
let standard = [[a11 * b11 + a12 * b21, a11 * b12 + a12 * b22], [a21 * b11 + a22 * b21, a21 * b12 + a22 * b22]]
print("Strassen:", strassen)
print("standard:", standard)
