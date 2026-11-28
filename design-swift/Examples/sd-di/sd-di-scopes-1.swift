// Generated from src/dsa/design/content/lessons/sd-di/sd-di-scopes.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

@MainActor final class UserSession {
    let userID: String
    init(userID: String) { self.userID = userID }
}

final class Basket {}

/// App scope: one pipeline for the whole process. It knows nothing about users.
@MainActor final class AnalyticsPipeline {
    private(set) var sent: [String] = []
    func send(_ line: String) { sent.append(line) }
}

/// The bug: an app-wide wrapper that captured whichever session existed when it was first built
@MainActor final class CapturingAnalytics {
    private let pipeline: AnalyticsPipeline
    private let session: UserSession

    init(pipeline: AnalyticsPipeline, session: UserSession) {
        self.pipeline = pipeline
        self.session = session
    }

    func track(_ event: String) {
        pipeline.send("captured: \(event) user=\(session.userID)")
    }
}

/// The fix: a wrapper in the session scope, depending on the longer-lived pipeline
@MainActor final class SessionAnalytics {
    private let pipeline: AnalyticsPipeline
    private let session: UserSession

    init(pipeline: AnalyticsPipeline, session: UserSession) {
        self.pipeline = pipeline
        self.session = session
    }

    func track(_ event: String) {
        pipeline.send("scoped: \(event) user=\(session.userID)")
    }
}

/// Everything that belongs to one signed-in person
@MainActor final class SessionScope {
    let session: UserSession
    let basket = Basket()
    let analytics: SessionAnalytics

    init(userID: String, pipeline: AnalyticsPipeline) {
        session = UserSession(userID: userID)
        analytics = SessionAnalytics(pipeline: pipeline, session: session)
    }
}

@MainActor final class AppRoot {
    let pipeline = AnalyticsPipeline()
    private(set) var signedIn: SessionScope?
    private var capturing: CapturingAnalytics?

    func signIn(_ userID: String) { signedIn = SessionScope(userID: userID, pipeline: pipeline) }
    func signOut() { signedIn = nil }

    // Built once, lazily: the shape of a container singleton whose factory resolves the session
    func capturingAnalytics() -> CapturingAnalytics {
        if let capturing { return capturing }
        let analytics = CapturingAnalytics(pipeline: pipeline, session: signedIn!.session)
        capturing = analytics
        return analytics
    }
}

let root = AppRoot()
root.signIn("ana")
root.capturingAnalytics().track("checkout_started")
root.signedIn?.analytics.track("checkout_started")

weak var anasBasket = root.signedIn?.basket
weak var anasSession = root.signedIn?.session
root.signOut()
print("Ana's basket released:", anasBasket == nil)
print("Ana's session released:", anasSession == nil)

root.signIn("ben")
root.capturingAnalytics().track("checkout_started")
root.signedIn?.analytics.track("checkout_started")
root.pipeline.sent.forEach { print($0) }
