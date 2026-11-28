// Generated from src/dsa/design/content/lessons/sd-diagrams/sd-diagrams-uml-state-activity.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

enum RecorderState {
    case idle, asking, denied, recording, interrupted, paused, saving, saved
}

enum RecorderEvent {
    case tapRecord, granted, refused, dismiss
    case pause, resume, stop
    case began, ended(shouldResume: Bool)
    case didSave, saveFailed
}

/// One line per arrow on the diagram. A pair that isn't listed is an event the state ignores.
func next(_ state: RecorderState, on event: RecorderEvent) -> RecorderState? {
    switch (state, event) {
    case (.idle, .tapRecord): .asking
    case (.asking, .granted): .recording
    case (.asking, .refused): .denied
    case (.denied, .dismiss): .idle
    case (.recording, .pause): .paused
    case (.paused, .resume): .recording
    case (.recording, .began): .interrupted
    case (.interrupted, .ended(let shouldResume)): shouldResume ? .recording : .paused
    case (.recording, .stop), (.paused, .stop): .saving
    case (.saving, .didSave): .saved
    case (.saving, .saveFailed): .paused
    case (.idle, _), (.asking, _), (.denied, _), (.recording, _), (.interrupted, _),
         (.paused, _), (.saving, _), (.saved, _): nil
    }
}

var state = RecorderState.idle
let events: [RecorderEvent] = [
    .tapRecord, .granted, .began, .ended(shouldResume: false), .resume,
    .stop, .saveFailed, .stop, .didSave, .pause,
]
for event in events {
    if let after = next(state, on: event) {
        print("\(state) --\(event)--> \(after)")
        state = after
    } else {
        print("\(state) ignores \(event)")
    }
}
