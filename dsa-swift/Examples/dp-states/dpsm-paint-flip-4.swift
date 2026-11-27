// Generated from src/dsa/content/lessons/dp-states/dpsm-paint-flip.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Try every split: 0s before position `split`, 1s from there on
func minimumFlipsBySplit(_ bits: String) -> Int {
    let digits = Array(bits)
    var onesBefore = 0                                   // 1s left of the split must become 0
    var zerosAfter = digits.filter { $0 == "0" }.count   // 0s right of the split must become 1
    var best = zerosAfter                                // split at 0: everything becomes 1
    for digit in digits {
        if digit == "1" {
            onesBefore += 1
        } else {
            zerosAfter -= 1
        }
        best = min(best, onesBefore + zerosAfter)
    }
    return best
}

for bits in ["00110", "010110", "11100", "0000", ""] {
    print("\"\(bits)\"", minimumFlipsBySplit(bits))
}
