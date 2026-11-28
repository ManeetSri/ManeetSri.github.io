// Generated from src/dsa/content/lessons/design-structures/ds-file-system.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

for path in ["/", "/notes", "/notes/swift/heaps.txt", "//odd//path/"] {
    print(path.split(separator: "/"))
}
print("/a//b".split(separator: "/", omittingEmptySubsequences: false))
