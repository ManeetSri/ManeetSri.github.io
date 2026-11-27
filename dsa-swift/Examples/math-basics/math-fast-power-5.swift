// Generated from src/dsa/content/lessons/math-basics/math-fast-power.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func mulMod(_ a: Int, _ b: Int, _ m: Int) -> Int {
    var result = 0
    var doubled = a % m
    var times = b
    while times > 0 {
        if times % 2 == 1 {
            result = (result + doubled) % m
        }
        doubled = (doubled + doubled) % m
        times /= 2
    }
    return result
}

print(mulMod(999_999_999_999, 999_999_999_999, 1_000_000_000_007))
