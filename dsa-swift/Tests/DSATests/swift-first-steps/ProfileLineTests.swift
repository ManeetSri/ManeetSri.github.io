import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ProfileLineTests {
    @Test("Builds the profile line", arguments: [
        ("Maneet", 29, "Pune", "Maneet is 29 and lives in Pune. Next year: 30."),
        ("Ada", 36, "London", "Ada is 36 and lives in London. Next year: 37."),
        ("Grace", 85, "New York", "Grace is 85 and lives in New York. Next year: 86."),
    ])
    func buildsLine(name: String, age: Int, city: String, expected: String) {
        #expect(ProfileLine.describe(name: name, age: age, city: city) == expected)
    }

    @Test("Works for a newborn")
    func ageZero() {
        #expect(ProfileLine.describe(name: "Sam", age: 0, city: "Oslo") == "Sam is 0 and lives in Oslo. Next year: 1.")
    }

    @Test("Works at the top of the allowed range")
    func oldest() {
        #expect(ProfileLine.describe(name: "Jeanne", age: 150, city: "Arles") == "Jeanne is 150 and lives in Arles. Next year: 151.")
    }
}
