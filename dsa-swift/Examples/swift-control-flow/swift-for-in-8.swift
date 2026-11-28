// Generated from src/dsa/content/lessons/swift-control-flow/swift-for-in.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var vowels = 0
for character in "programming" {
    if "aeiou".contains(character) {
        vowels += 1
    }
}
print("Vowels: \(vowels)")
