// Generated from src/dsa/content/lessons/strings-basic/str-palindromes.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let chars = Array("abaab")

func grow(_ low: Int, _ high: Int) -> String {
    var low = low
    var high = high
    while low >= 0 && high < chars.count && chars[low] == chars[high] {
        low -= 1
        high += 1
    }
    return String(chars[(low + 1)..<high])      // the last pair that matched
}

for i in chars.indices {
    print("on \(i): \"\(grow(i, i))\"", terminator: "   ")
    if i + 1 < chars.count {
        print("after \(i): \"\(grow(i, i + 1))\"")
    } else {
        print()
    }
}
