// Generated from src/dsa/content/lessons/dp-advanced/dpa-probability.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

import Foundation

// chance[total]: the probability that the dice rolled so far add up to total
func diceSums(dice: Int, faces: Int) -> [Double] {
    var chance = [1.0]                                    // no dice yet: a total of 0 for certain
    for _ in 0..<dice {
        var next = [Double](repeating: 0, count: chance.count + faces)
        for (total, p) in chance.enumerated() where p > 0 {
            for face in 1...faces {
                next[total + face] += p / Double(faces)   // each face is equally likely
            }
        }
        chance = next
    }
    return chance
}

let three = diceSums(dice: 3, faces: 6)
for total in [3, 4, 10, 11, 18] {
    print(total, String(format: "%.4f", three[total]))
}
print("all together:", String(format: "%.4f", three.reduce(0, +)))
let atLeast15 = three[15...].reduce(0, +)
print("15 or more:", String(format: "%.4f", atLeast15))
