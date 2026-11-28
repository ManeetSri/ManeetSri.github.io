// Generated from src/dsa/content/lessons/dp-states/dpsm-paint-flip.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func traceFlips(_ bits: String) {
    var zeros = 0, ones = 0
    print("start: zeros \(zeros), ones \(ones)")
    for bit in bits {
        let (oldZeros, oldOnes) = (zeros, ones)
        zeros = oldZeros + (bit == "1" ? 1 : 0)
        ones = min(oldZeros, oldOnes) + (bit == "0" ? 1 : 0)
        print("\(bit): zeros \(zeros), ones \(ones)")
    }
}

traceFlips("010110")
