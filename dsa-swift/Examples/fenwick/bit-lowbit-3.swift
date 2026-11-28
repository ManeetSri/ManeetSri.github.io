// Generated from src/dsa/content/lessons/fenwick/bit-lowbit.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Stripping the lowest set bit walks down; adding it walks up
func strip(_ start: Int) -> [Int] {
    var path: [Int] = []
    var i = start
    while i > 0 {
        path.append(i)
        i -= i & -i                               // remove the lowest set bit
    }
    return path
}

func climb(_ start: Int, through limit: Int) -> [Int] {
    var path: [Int] = []
    var i = start
    while i <= limit {
        path.append(i)
        i += i & -i                               // add the lowest set bit: it carries upwards
    }
    return path
}

print(strip(13), strip(16), strip(7))
print(climb(5, through: 16), climb(1, through: 16), climb(9, through: 16))
print(13.nonzeroBitCount, strip(13).count)
