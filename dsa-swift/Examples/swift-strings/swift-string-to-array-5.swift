// Generated from src/dsa/content/lessons/swift-strings/swift-string-to-array.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

print(UInt8(ascii: "a"), UInt8(ascii: "A"), UInt8(ascii: " "))

var bytes = Array("hello world".utf8)
for i in bytes.indices where bytes[i] == UInt8(ascii: "o") {
    bytes[i] = UInt8(ascii: "0")
}
print(String(decoding: bytes, as: UTF8.self))
