// Generated from src/dsa/content/lessons/bits/bits-subsets.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func binary(_ mask: Int, width: Int) -> String {
    let digits = String(mask, radix: 2)
    return String(repeating: "0", count: width - digits.count) + digits
}

let m = 0b1011
var sub = m
while true {
    print(binary(sub, width: 4))
    if sub == 0 {
        break
    }
    sub = (sub - 1) & m
}
