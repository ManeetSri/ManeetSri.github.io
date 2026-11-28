// Generated from src/dsa/content/lessons/swift-types/swift-observers-static.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Volume {
    var level = 5 {
        didSet {
            if level > 10 {
                level = 10
            } else if level < 0 {
                level = 0
            }
        }
    }
}

var speaker = Volume()
speaker.level = 14
print(speaker.level)
speaker.level -= 20
print(speaker.level)
