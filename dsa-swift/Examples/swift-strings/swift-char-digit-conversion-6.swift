// Generated from src/dsa/content/lessons/swift-strings/swift-char-digit-conversion.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

print(String(42))
print(String(-7) + "!")
print("\(3 + 4)")

print(String(10, radix: 2))
print(String(255, radix: 16))
print(Int("1010", radix: 2) ?? -1)
print(Int("ff", radix: 16) ?? -1)
