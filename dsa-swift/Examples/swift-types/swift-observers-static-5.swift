// Generated from src/dsa/content/lessons/swift-types/swift-observers-static.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Temperature {
    var celsius: Double

    static func fromFahrenheit(_ degrees: Double) -> Temperature {
        Temperature(celsius: (degrees - 32) * 5 / 9)
    }

    static func warmest(_ readings: [Temperature]) -> Temperature? {
        readings.max { $0.celsius < $1.celsius }
    }
}

let readings = [Temperature(celsius: 18), Temperature.fromFahrenheit(77), Temperature(celsius: 21)]
if let hottest = Temperature.warmest(readings) {
    print(hottest.celsius)
}
