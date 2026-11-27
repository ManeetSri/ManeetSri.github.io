// Generated from src/dsa/content/lessons/bits/bits-subsets.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func binary(_ mask: Int, width: Int) -> String {
    let digits = String(mask, radix: 2)
    return String(repeating: "0", count: width - digits.count) + digits
}

let items = ["tea", "toast", "jam"]
let n = items.count
for mask in 0..<(1 << n) {
    var chosen: [String] = []
    for i in 0..<n where mask & (1 << i) != 0 {
        chosen.append(items[i])
    }
    print(binary(mask, width: n), chosen)
}
