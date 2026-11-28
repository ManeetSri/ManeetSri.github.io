// Generated from src/dsa/content/lessons/linear-sorts/sort-cyclic.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func cyclicSort(_ numbers: inout [Int]) {
    var i = 0
    while i < numbers.count {
        let home = numbers[i] - 1                 // where numbers[i] belongs
        if numbers[i] != numbers[home] {
            numbers.swapAt(i, home)
            print("send \(numbers[home]) to index \(home):", numbers)
        } else {
            i += 1                                // index i is settled: move on
        }
    }
}

var seats = [3, 5, 2, 1, 4]
cyclicSort(&seats)
