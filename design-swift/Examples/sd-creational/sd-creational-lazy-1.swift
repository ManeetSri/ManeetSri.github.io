// Generated from src/dsa/design/content/lessons/sd-creational/sd-creational-lazy.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

final class ProfileScreen {
    lazy var header: String = {
        print("building header")
        return "Hello, Maneet"
    }()
}

let screen = ProfileScreen()
print("screen created")
print(screen.header)
print(screen.header)
