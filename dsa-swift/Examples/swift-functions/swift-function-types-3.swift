// Generated from src/dsa/content/lessons/swift-functions/swift-function-types.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func count(_ numbers: [Int], where test: (Int) -> Bool) -> Int {
    var total = 0
    for number in numbers {
        if test(number) {
            total += 1
        }
    }
    return total
}

func isNegative(_ n: Int) -> Bool { n < 0 }
func isEven(_ n: Int) -> Bool { n % 2 == 0 }

let readings = [4, -2, 7, -9, 0, 12]
print(count(readings, where: isNegative))
print(count(readings, where: isEven))
