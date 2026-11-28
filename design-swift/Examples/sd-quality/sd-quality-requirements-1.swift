// Generated from src/dsa/design/content/lessons/sd-quality/sd-quality-requirements.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

struct QualityScenario {
    let attribute: String
    let source: String
    let stimulus: String
    let environment: String
    let artefact: String
    let response: String
    let measure: String

    var sentence: String {
        "When \(source) \(stimulus) \(environment), the \(artefact) \(response) \(measure)."
    }

    // A crude check, but it catches the most common gap: a measure with no number in it
    var hasNumber: Bool { measure.contains(where: \.isNumber) }
}

let scenarios = [
    QualityScenario(attribute: "Performance", source: "a commuter", stimulus: "opens the app",
                    environment: "on a train with no signal", artefact: "feed screen",
                    response: "shows the last cached posts", measure: "within 1 s at p90 on an iPhone 12"),
    QualityScenario(attribute: "Usability", source: "a new user", stimulus: "signs up",
                    environment: "for the first time", artefact: "onboarding flow",
                    response: "feels quick and easy", measure: "for most people"),
]

for scenario in scenarios {
    print("\(scenario.attribute): \(scenario.sentence)")
    print(scenario.hasNumber ? "  testable" : "  not testable yet: the measure has no number")
}
