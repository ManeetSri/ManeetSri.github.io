// Generated from src/dsa/content/lessons/arrays/arrays-kadane.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func bestSubarray(_ numbers: [Int]) -> (sum: Int, range: ClosedRange<Int>) {
    var current = numbers[0]
    var start = 0
    var best = numbers[0]
    var bestRange = 0...0
    for index in 1..<numbers.count {
        if current < 0 {              // a negative run only drags things down
            current = numbers[index]
            start = index
        } else {
            current += numbers[index]
        }
        if current > best {
            best = current
            bestRange = start...index
        }
    }
    return (best, bestRange)
}

let readings = [-2, 1, -3, 4, -1, 2, 1, -5, 4]
let result = bestSubarray(readings)
print(result.sum, result.range, Array(readings[result.range]))
