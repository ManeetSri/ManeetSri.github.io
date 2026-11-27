// Generated from src/dsa/content/lessons/bits/bits-gray-code-bitsets.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func fromGray(_ gray: Int) -> Int {
    var value = gray
    var shift = gray >> 1
    while shift != 0 {
        value ^= shift
        shift >>= 1
    }
    return value
}

print(fromGray(0b110))
print(fromGray(0b100))

var allMatch = true
for i in 0..<1024 where fromGray(i ^ (i >> 1)) != i {
    allMatch = false
}
print(allMatch)
