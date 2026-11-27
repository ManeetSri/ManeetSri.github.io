// Generated from src/dsa/content/lessons/efficient-sorts/sort-merge.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func merge(_ left: [Int], _ right: [Int]) -> [Int] {
    var merged: [Int] = []
    merged.reserveCapacity(left.count + right.count)
    var i = 0
    var j = 0
    while i < left.count && j < right.count {
        if left[i] <= right[j] {         // a tie takes the left element
            merged.append(left[i])
            i += 1
        } else {
            merged.append(right[j])
            j += 1
        }
    }
    merged += left[i...]                 // one side is used up: copy the rest of the other
    merged += right[j...]
    return merged
}

print(merge([3, 27, 38, 43], [9, 10, 82]))
print(merge([1, 5, 5], [2, 5, 6]))
print(merge([], [4, 7]))
