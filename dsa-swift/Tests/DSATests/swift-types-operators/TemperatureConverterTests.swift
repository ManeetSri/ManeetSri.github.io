import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct TemperatureConverterTests {
    /// Floating-point answers can be off in the last digit, so compare with a tolerance
    private func isClose(_ actual: Double, _ expected: Double) -> Bool {
        abs(actual - expected) < 1e-9
    }

    @Test("Celsius to Fahrenheit", arguments: [
        (0.0, 32.0),
        (100.0, 212.0),
        (-40.0, -40.0),
        (37.0, 98.6),
        (-273.15, -459.67),
        (21.5, 70.7),
    ])
    func toFahrenheit(celsius: Double, expected: Double) {
        #expect(isClose(TemperatureConverter.fahrenheit(fromCelsius: celsius), expected))
    }

    @Test("Fahrenheit to Celsius", arguments: [
        (32.0, 0.0),
        (212.0, 100.0),
        (-40.0, -40.0),
        (98.6, 37.0),
        (0.0, -160.0 / 9.0),
        (451.0, 2095.0 / 9.0),
    ])
    func toCelsius(fahrenheit: Double, expected: Double) {
        #expect(isClose(TemperatureConverter.celsius(fromFahrenheit: fahrenheit), expected))
    }

    @Test("Converting there and back returns the starting value", arguments: [-50.0, 0.0, 12.34, 1_000.0])
    func roundTrip(celsius: Double) {
        let there = TemperatureConverter.fahrenheit(fromCelsius: celsius)
        #expect(isClose(TemperatureConverter.celsius(fromFahrenheit: there), celsius))
    }

    @Test("Keeps the fraction: 1 °C is 33.8 °F, not 33 °F")
    func keepsFraction() {
        #expect(isClose(TemperatureConverter.fahrenheit(fromCelsius: 1), 33.8))
    }
}
