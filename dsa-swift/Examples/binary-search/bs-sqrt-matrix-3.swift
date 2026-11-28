// Generated from src/dsa/content/lessons/binary-search/bs-sqrt-matrix.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let x = 999_999_999_999_999_999
let viaDouble = Int(Double(x).squareRoot())
print(viaDouble, viaDouble * viaDouble <= x)
