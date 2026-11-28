// Generated from src/dsa/content/lessons/dp-advanced/dpa-sos.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// For every mask, add up value[sub] over all its submasks: the slow way and the SOS way
func slowSubmaskSums(_ value: [Int], bits n: Int) -> (sums: [Int], steps: Int) {
    var sums = [Int](repeating: 0, count: 1 << n)
    var steps = 0
    for mask in 0..<(1 << n) {
        var sub = mask
        while true {
            sums[mask] += value[sub]
            steps += 1
            if sub == 0 { break }
            sub = (sub - 1) & mask
        }
    }
    return (sums, steps)
}

func sosSums(_ value: [Int], bits n: Int) -> (sums: [Int], steps: Int) {
    var f = value
    var steps = 0
    for bit in 0..<n {                                 // let submasks differ in this bit too
        for mask in 0..<(1 << n) where mask & (1 << bit) != 0 {
            f[mask] += f[mask ^ (1 << bit)]            // add the same mask with this bit turned off
            steps += 1
        }
    }
    return (f, steps)
}

let small = [1, 2, 3, 4, 5, 6, 7, 8]                  // value[mask] for the 8 masks of 3 bits
print(slowSubmaskSums(small, bits: 3).sums)
print(sosSums(small, bits: 3).sums)

let n = 14
let value = (0..<(1 << n)).map { ($0 * 37 + 11) % 100 }
let slow = slowSubmaskSums(value, bits: n)
let fast = sosSums(value, bits: n)
print("same answers:", slow.sums == fast.sums)
print("steps:", slow.steps, "vs", fast.steps)
