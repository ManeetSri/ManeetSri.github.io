// Generated from src/dsa/design/content/lessons/sd-styles/sd-styles-model-view.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

// The model: the rule all three versions share
func isPlausibleEmail(_ text: String) -> Bool {
    let parts = text.split(separator: "@")
    return parts.count == 2 && parts[1].contains(".")
}

// MVP: the presenter decides, then pushes the result into a passive view through a protocol
protocol SignInView: AnyObject {
    func setSignInEnabled(_ enabled: Bool)
}

final class SignInPresenter {
    weak var view: (any SignInView)?

    func emailChanged(to email: String) {
        view?.setSignInEnabled(isPlausibleEmail(email))
    }
}

final class RecordingView: SignInView {
    var enabled = false
    func setSignInEnabled(_ enabled: Bool) { self.enabled = enabled }
}

// MVVM: the view model exposes state; the view reads (binds to) it and the view model never sees the view
final class SignInViewModel {
    var email = ""
    var isSignInEnabled: Bool { isPlausibleEmail(email) }
}

// Unidirectional: every change is an action, and one pure function makes the next state
struct SignInState: Equatable {
    var email = ""
    var isSignInEnabled = false
}

enum SignInAction {
    case emailChanged(String)
}

func reduce(_ state: SignInState, _ action: SignInAction) -> SignInState {
    var next = state
    switch action {
    case .emailChanged(let email):
        next.email = email
        next.isSignInEnabled = isPlausibleEmail(email)
    }
    return next
}

let typed = "maneet@example.com"

let view = RecordingView()
let presenter = SignInPresenter()
presenter.view = view
presenter.emailChanged(to: typed)
print("MVP: the presenter set enabled =", view.enabled)

let viewModel = SignInViewModel()
viewModel.email = typed
print("MVVM: the view model exposes isSignInEnabled =", viewModel.isSignInEnabled)

let state = reduce(SignInState(), .emailChanged(typed))
print("Unidirectional: the reducer returned isSignInEnabled =", state.isSignInEnabled)
