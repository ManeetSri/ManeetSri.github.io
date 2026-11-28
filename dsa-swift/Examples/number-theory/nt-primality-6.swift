// Generated from src/dsa/content/lessons/number-theory/nt-primality.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func mulMod(_ a: UInt64, _ b: UInt64, _ m: UInt64) -> UInt64 {
    m.dividingFullWidth(a.multipliedFullWidth(by: b)).remainder
}

func powMod(_ base: UInt64, _ exponent: UInt64, _ m: UInt64) -> UInt64 {
    var result: UInt64 = 1
    var square = base % m
    var e = exponent
    while e > 0 {
        if e & 1 == 1 { result = mulMod(result, square, m) }
        square = mulMod(square, square, m)
        e >>= 1
    }
    return result
}

func isPrime(_ n: UInt64) -> Bool {
    let bases: [UInt64] = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37]
    if n < 2 { return false }
    for p in bases where n % p == 0 { return n == p }
    var d = n - 1
    var s = 0
    while d & 1 == 0 { d >>= 1; s += 1 }
    witnessLoop: for a in bases {
        var x = powMod(a, d, n)
        if x == 1 || x == n - 1 { continue }
        for _ in 1..<s {
            x = mulMod(x, x, n)
            if x == n - 1 { continue witnessLoop }
        }
        return false
    }
    return true
}

func gcd(_ a: UInt64, _ b: UInt64) -> UInt64 { b == 0 ? a : gcd(b, a % b) }

// Pollard's rho: a nontrivial factor of an odd composite n
func rho(_ n: UInt64) -> UInt64 {
    var c: UInt64 = 1
    while true {
        func f(_ x: UInt64) -> UInt64 { (mulMod(x, x, n) + c) % n }
        var tortoise: UInt64 = 2
        var hare: UInt64 = 2
        var d: UInt64 = 1
        while d == 1 {
            tortoise = f(tortoise)
            hare = f(f(hare))
            d = gcd(tortoise > hare ? tortoise - hare : hare - tortoise, n)
        }
        if d != n { return d }       // found a factor
        c += 1                       // the cycle closed without one: try another polynomial
    }
}

// Every prime factor of n, smallest first
func factorise(_ n: UInt64) -> [UInt64] {
    if n == 1 { return [] }
    if n % 2 == 0 { return [2] + factorise(n / 2) }
    if isPrime(n) { return [n] }
    let d = rho(n)
    return (factorise(d) + factorise(n / d)).sorted()
}

print(factorise(8051))
print(factorise(600_851_475_143))
print(factorise(1_000_000_016_000_000_063))
print(factorise(UInt64.max))
print(factorise(18_446_744_030_759_878_681))
