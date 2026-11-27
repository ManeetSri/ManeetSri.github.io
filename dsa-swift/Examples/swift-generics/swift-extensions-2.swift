// Generated from src/dsa/content/lessons/swift-generics/swift-extensions.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

extension String {
    var isPalindrome: Bool {
        let characters = Array(self)
        return characters == characters.reversed()
    }
}

print("level".isPalindrome)
print("swift".isPalindrome)
