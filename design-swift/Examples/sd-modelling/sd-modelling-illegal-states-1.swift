// Generated from src/dsa/design/content/lessons/sd-modelling/sd-modelling-illegal-states.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

enum UploadError: Error {
    case offline
    case tooLarge
    case rejected(status: Int)
}

enum UploadState {
    case queued
    case uploading(progress: Double)
    case paused(resumeData: Data)
    case failed(UploadError, attempts: Int)
    case done(URL)

    var label: String {
        switch self {
        case .queued: "Waiting to upload"
        case .uploading(let progress): "Uploading \(Int(progress * 100))%"
        case .paused: "Paused"
        case .failed(.offline, _): "Waiting for a connection"
        case .failed(.tooLarge, _): "This photo is too large to upload"
        case .failed(_, let attempts) where attempts >= 3: "Upload failed. Tap to try again"
        case .failed: "Retrying…"
        case .done: "Uploaded"
        }
    }

    var canCancel: Bool {
        switch self {
        case .queued, .uploading, .paused, .failed: true
        case .done: false
        }
    }
}

let states: [UploadState] = [
    .queued,
    .uploading(progress: 0.5),
    .paused(resumeData: Data()),
    .failed(.offline, attempts: 1),
    .failed(.rejected(status: 503), attempts: 1),
    .failed(.rejected(status: 503), attempts: 3),
    .done(URL(string: "https://cdn.example.com/p/91.jpg")!),
]
for state in states {
    print(state.label, state.canCancel ? "· can cancel" : "")
}
