// Generated from src/dsa/content/lessons/strings-basic/str-big-number-arithmetic.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func digits(_ number: String) -> [Int] {
    number.utf8.reversed().map { Int($0 - UInt8(ascii: "0")) }
}

func text(_ digits: [Int]) -> String {
    digits.reversed().map { String($0) }.joined()
}

func multiply(_ a: String, _ b: String) -> String {
    let x = digits(a)
    let y = digits(b)
    var product = [Int](repeating: 0, count: x.count + y.count)
    for i in x.indices {
        for j in y.indices {
            product[i + j] += x[i] * y[j]
        }
    }
    var carry = 0
    for place in product.indices {
        let total = product[place] + carry
        product[place] = total % 10
        carry = total / 10
    }
    while product.count > 1 && product.last == 0 {
        product.removeLast()
    }
    return text(product)
}

var factorial = "1"
for k in 2...30 {
    factorial = multiply(factorial, String(k))
}
print(factorial)
print(factorial.count, "digits")
