// Generated from src/dsa/content/lessons/binary-search/bs-median-two-arrays.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func median(of first: [Int], and second: [Int]) -> Double {
    if first.count > second.count {
        return median(of: second, and: first)          // binary search the shorter array
    }
    let m = first.count
    let n = second.count
    let half = (m + n + 1) / 2                         // the left half's size
    var low = 0
    var high = m
    while low <= high {
        let i = low + (high - low) / 2                 // take i values from first…
        let j = half - i                               // …and j from second
        let firstLeft = i > 0 ? first[i - 1] : Int.min
        let firstRight = i < m ? first[i] : Int.max
        let secondLeft = j > 0 ? second[j - 1] : Int.min
        let secondRight = j < n ? second[j] : Int.max

        if firstLeft > secondRight {
            print("  i \(i), j \(j): first[\(i - 1)] = \(firstLeft) > second[\(j)] = \(secondRight): fewer from first")
            high = i - 1
        } else if secondLeft > firstRight {
            print("  i \(i), j \(j): second[\(j - 1)] = \(secondLeft) > first[\(i)] = \(firstRight): more from first")
            low = i + 1
        } else {
            print("  i \(i), j \(j): the cut is right")
            let leftMax = max(firstLeft, secondLeft)
            if (m + n) % 2 == 1 {
                return Double(leftMax)
            }
            let rightMin = min(firstRight, secondRight)
            return Double(leftMax + rightMin) / 2
        }
    }
    fatalError("unreachable when both arrays are sorted")
}

print(median(of: [4, 10, 25, 30, 40, 50, 60], and: [1, 2, 3, 5, 6, 8, 12, 15]))
print(median(of: [10, 20, 30, 40, 50, 60, 70], and: [1, 2, 3, 4, 5, 6, 7, 8]))
print(median(of: [1, 4, 9], and: [2, 3, 10]))
