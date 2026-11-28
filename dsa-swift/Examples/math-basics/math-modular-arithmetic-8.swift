// Generated from src/dsa/content/lessons/math-basics/math-modular-arithmetic.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func mulMod(_ a: Int, _ b: Int, _ m: Int) -> Int {
    let product = a.multipliedFullWidth(by: b)
    return m.dividingFullWidth(product).remainder
}

print(mulMod(999_999_999_999, 999_999_999_999, 1_000_000_000_007))
