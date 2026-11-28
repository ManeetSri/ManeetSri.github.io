// Generated from src/dsa/content/lessons/swift-types/swift-observers-static.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Thermostat {
    var target: Int {
        willSet {
            print("About to change from \(target) to \(newValue)")
        }
        didSet {
            print("Changed from \(oldValue) to \(target)")
        }
    }
}

var home = Thermostat(target: 20)
home.target = 22
home.target += 1
