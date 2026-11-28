// Generated from src/dsa/content/lessons/swift-types/swift-mutating.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Temperature {
    var celsius: Double

    init(fahrenheit: Double) {
        celsius = (fahrenheit - 32) * 5 / 9
    }
}

let boiling = Temperature(fahrenheit: 212)
print(boiling.celsius)
