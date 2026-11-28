// Generated from src/dsa/design/content/lessons/sd-behavioural-1/sd-behavioural-kvo-combine-observation.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Observation

@Observable
final class Profile {
    var name = "Ada"
    var bio = "Engineer"
}

@MainActor
func render(_ profile: Profile) {
    withObservationTracking {
        print("render: \(profile.name)")
    } onChange: {
        print("onChange: name is about to change")
    }
}

let profile = Profile()
render(profile)
profile.bio = "Mathematician"
profile.name = "Grace"
profile.name = "Hopper"
print("name is now \(profile.name)")
