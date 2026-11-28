// Generated from src/dsa/content/lessons/binary-search/bs-single-element.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func single(in numbers: [Int]) -> Int {
    var low = 0
    var high = numbers.count - 1               // both even: the single value is in [low, high]
    while low < high {
        var mid = low + (high - low) / 2
        if mid % 2 == 1 {
            mid -= 1                           // check the pair that should start at an even index
        }
        let intact = numbers[mid] == numbers[mid + 1]
        print("  [\(low), \(high)], mid \(mid): \(numbers[mid]) and \(numbers[mid + 1])", intact ? "match" : "differ")
        if intact {
            low = mid + 2                      // whole pairs up to here: look right
        } else {
            high = mid                         // broken already: the single value is mid or earlier
        }
    }
    return numbers[low]
}

print(single(in: [1, 1, 2, 3, 3, 4, 4, 8, 8]))
print(single(in: [3, 3, 7, 7, 10, 11, 11]))
print(single(in: [42]))
