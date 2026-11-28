// Generated from src/dsa/content/lessons/dp-states/dpsm-paint-flip.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func minimumFlips(_ bits: String) -> Int {
    var zeros = 0    // fewest flips so far if everything so far becomes 0
    var ones = 0     // fewest flips so far if we've already switched to the 1s part
    for bit in bits {
        if bit == "0" {
            ones = min(zeros, ones) + 1     // a 0 in the 1s part must flip
        } else {
            ones = min(zeros, ones)         // switch here, or stay: this 1 is fine
            zeros += 1                      // a 1 in the 0s part must flip
        }
    }
    return min(zeros, ones)
}

for bits in ["00110", "010110", "11100", "0000", ""] {
    print("\"\(bits)\"", minimumFlips(bits))
}
