// Generated from src/dsa/content/lessons/string-algorithms/sa-manacher.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Manacher's algorithm. rad[i] is the palindrome radius at position i of the string with separators.
func manacher(_ s: [UInt8]) -> [Int] {
    var t = [Int](repeating: -1, count: 2 * s.count + 1)    // -1 separators around every character
    for (k, c) in s.enumerated() {
        t[2 * k + 1] = Int(c)
    }
    let n = t.count
    var rad = [Int](repeating: 0, count: n)
    var centre = 0, right = 0               // the palindrome reaching furthest right ends at right
    for i in 0..<n {
        if i < right {
            rad[i] = min(rad[2 * centre - i], right - i)    // the mirror trick
        }
        while i - rad[i] - 1 >= 0 && i + rad[i] + 1 < n && t[i - rad[i] - 1] == t[i + rad[i] + 1] {
            rad[i] += 1                     // expand beyond what the mirror guarantees
        }
        if i + rad[i] > right {
            centre = i
            right = i + rad[i]
        }
    }
    return rad
}

let s = Array("abaaba".utf8)
let rad = manacher(s)
print(rad)
let best = rad.indices.max { rad[$0] < rad[$1] }!       // the first centre with the largest radius
let start = (best - rad[best]) / 2
print("longest:", String(decoding: s[start..<(start + rad[best])], as: UTF8.self))
print("count:", rad.reduce(0) { $0 + ($1 + 1) / 2 })
