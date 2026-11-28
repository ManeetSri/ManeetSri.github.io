// Reference solution: Temperature converter. Each direction is one formula on Double values.
// O(1) time and space.

public enum TemperatureConverter {
    public static func fahrenheit(fromCelsius celsius: Double) -> Double {
        celsius * 9 / 5 + 32
    }

    public static func celsius(fromFahrenheit fahrenheit: Double) -> Double {
        (fahrenheit - 32) * 5 / 9
    }
}
