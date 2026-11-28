// Generated from src/dsa/content/lessons/binary-search/bs-single-element.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func single(in numbers: [Int]) -> Int {
    var low = 0
    var high = numbers.count - 1
    while low < high {
        let mid = low + (high - low) / 2
        if numbers[mid] == numbers[mid ^ 1] {   // mid's partner, if pairs start at even indexes
            low = mid + 1
        } else {
            high = mid
        }
    }
    return numbers[low]
}

print(single(in: [1, 1, 2, 3, 3, 4, 4, 8, 8]), single(in: [3, 3, 7, 7, 10, 11, 11]), single(in: [5, 6, 6]))
