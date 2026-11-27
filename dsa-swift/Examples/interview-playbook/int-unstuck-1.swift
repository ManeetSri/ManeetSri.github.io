// Generated from src/dsa/content/lessons/interview-playbook/int-unstuck.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func rotatedMinimum(_ values: [Int]) -> Int {
    var low = 0
    var high = values.count - 1
    while low < high {
        let mid = low + (high - low) / 2
        if values[mid] > values[high] {
            low = mid + 1          // the drop is to the right of mid
        } else {
            high = mid             // mid itself might be the minimum
        }
    }
    return values[low]
}

print(rotatedMinimum([15, 18, 22, 3, 7, 9, 11]))
print(rotatedMinimum([3, 7, 9, 11]))
print(rotatedMinimum([9, 4]))
print(rotatedMinimum([5]))
