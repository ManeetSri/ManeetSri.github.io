// Generated from src/dsa/content/lessons/randomised/rand-reservoir.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The probability that item i (counting from 1) is the one kept at the end of a stream of n
func gcd(_ a: Int, _ b: Int) -> Int { b == 0 ? a : gcd(b, a % b) }

let n = 5
for i in 1...n {
    var top = 1                              // kept when it arrives: 1/i
    var bottom = i
    for later in stride(from: i + 1, through: n, by: 1) {
        top *= later - 1                     // not replaced by item `later`: (later − 1)/later
        bottom *= later
    }
    let g = gcd(top, bottom)
    print("item \(i): \(top / g)/\(bottom / g)")
}
