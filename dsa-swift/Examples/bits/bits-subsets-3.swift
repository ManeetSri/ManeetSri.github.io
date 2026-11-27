// Generated from src/dsa/content/lessons/bits/bits-subsets.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

func dayNames(_ mask: Int) -> [String] {
    var names: [String] = []
    for i in 0..<days.count where mask & (1 << i) != 0 {
        names.append(days[i])
    }
    return names
}

let alice = 0b011_0101
let bob = 0b101_0100
let everyDay = (1 << 7) - 1

print(dayNames(alice & bob))
print(dayNames(alice | bob))
print(dayNames(alice & ~bob))
print(dayNames(alice ^ everyDay))
print((alice & bob).nonzeroBitCount)
