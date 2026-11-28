import DesignKit
import Foundation
import Observation
import Synchronization
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A saver that holds each save until the test finishes or fails it, so a test can look at the model
/// while a save is in flight
private actor GatedSaver: ObservableProfileEditor.ProfileSaving {
    typealias Profile = ObservableProfileEditor.Profile

    private(set) var sent: [Profile] = []
    private var waiting: [(profile: Profile, continuation: CheckedContinuation<Profile, any Error>)] = []

    func save(_ profile: Profile) async throws -> Profile {
        sent.append(profile)
        return try await withCheckedThrowingContinuation { continuation in
            waiting.append((profile, continuation))
        }
    }

    /// Answers the oldest waiting save with the profile it was sent, or with `stored`. Does nothing if
    /// no save is waiting, so a stub that never calls the saver fails its expectations instead of hanging.
    func succeed(storing stored: Profile? = nil) {
        guard !waiting.isEmpty else { return }
        let (profile, continuation) = waiting.removeFirst()
        continuation.resume(returning: stored ?? profile)
    }

    /// Fails the oldest waiting save; does nothing if none is waiting
    func fail(with error: any Error) {
        guard !waiting.isEmpty else { return }
        waiting.removeFirst().continuation.resume(throwing: error)
    }
}

@Suite(.timeLimit(.minutes(1))) @MainActor struct ObservableProfileEditorTests {
    typealias Editor = ObservableProfileEditor
    typealias Profile = ObservableProfileEditor.Profile

    let original = Profile(name: "Ada", bio: "Mathematician", isPublic: false)

    private func makeModel() -> (Editor.Model, GatedSaver) {
        let saver = GatedSaver()
        return (Editor.Model(profile: original, saver: saver), saver)
    }

    /// Starts a save the way a Save button would, and lets it reach the saver
    private func startSave(_ model: Editor.Model) async -> Task<Void, Never> {
        let task = Task { await model.save() }
        await settle()
        return task
    }

    @Test("A fresh model can't save; editing the draft enables Save")
    func editingEnablesSave() {
        let (model, _) = makeModel()
        #expect(!model.hasUnsavedChanges)
        #expect(!model.canSave)

        model.draft.bio = "Mathematician and writer"

        #expect(model.hasUnsavedChanges)
        #expect(model.canSave)
    }

    @Test("Blank and overlong names can't be saved", arguments: [
        ("", Optional(ObservableProfileEditor.blankNameMessage)),
        ("   \n", Optional(ObservableProfileEditor.blankNameMessage)),
        (String(repeating: "a", count: 31), Optional(ObservableProfileEditor.longNameMessage)),
        ("  " + String(repeating: "b", count: 30) + "  ", nil),
        ("  Ada Lovelace  ", nil),
    ])
    func nameValidation(name: String, expectedError: String?) {
        let (model, _) = makeModel()
        model.draft.name = name

        #expect(model.nameError == expectedError)
        #expect(model.canSave == (expectedError == nil))
    }

    @Test("Saving sends the trimmed draft, shows progress, then adopts the stored profile")
    func successfulSave() async {
        let (model, saver) = makeModel()
        model.draft.name = "  Ada Lovelace "

        let task = await startSave(model)
        #expect(model.isSaving)
        #expect(!model.canSave)
        #expect(await saver.sent == [Profile(name: "Ada Lovelace", bio: "Mathematician")])

        await saver.succeed()
        await task.value

        #expect(!model.isSaving)
        #expect(model.saved == Profile(name: "Ada Lovelace", bio: "Mathematician"))
        #expect(model.draft == model.saved)
        #expect(!model.hasUnsavedChanges)
    }

    @Test("A second tap on Save while saving sends nothing")
    func noDoubleSave() async {
        let (model, saver) = makeModel()
        model.draft.isPublic = true

        let task = await startSave(model)
        await model.save()
        #expect(await saver.sent.count == 1)

        await saver.succeed()
        await task.value
        #expect(await saver.sent.count == 1)
    }

    @Test("Edits made while a save is in flight are kept")
    func editsDuringSave() async {
        let (model, saver) = makeModel()
        model.draft.bio = "Analyst"

        let task = await startSave(model)
        model.draft.bio = "Analyst and poet"
        await saver.succeed()
        await task.value

        #expect(model.saved.bio == "Analyst")
        #expect(model.draft.bio == "Analyst and poet")
        #expect(model.hasUnsavedChanges)
        #expect(model.canSave)
    }

    @Test("The server's copy replaces an untouched draft")
    func serverCopyWins() async {
        let (model, saver) = makeModel()
        model.draft.bio = "analyst"

        let task = await startSave(model)
        await saver.succeed(storing: Profile(name: "Ada", bio: "Analyst"))     // the server capitalised it
        await task.value

        #expect(model.saved.bio == "Analyst")
        #expect(model.draft.bio == "Analyst")
        #expect(!model.hasUnsavedChanges)
    }

    @Test("A failed save keeps the draft, shows an error, and a retry clears it")
    func failedSave() async {
        let (model, saver) = makeModel()
        model.draft.bio = "Analyst"

        let first = await startSave(model)
        await saver.fail(with: URLError(.notConnectedToInternet))
        await first.value

        #expect(model.errorMessage == ObservableProfileEditor.saveFailedMessage)
        #expect(model.draft.bio == "Analyst")
        #expect(model.saved == original)
        #expect(!model.isSaving)
        #expect(model.canSave)

        let retry = await startSave(model)
        #expect(model.errorMessage == nil)
        await saver.succeed()
        await retry.value
        #expect(model.saved.bio == "Analyst")
        #expect(await saver.sent.count == 2)
    }

    @Test("A cancelled save shows no error", arguments: [
        CancellationError() as any Error,
        URLError(.cancelled) as any Error,
    ])
    func cancelledSave(error: any Error) async {
        let (model, saver) = makeModel()
        model.draft.bio = "Analyst"

        let task = await startSave(model)
        await saver.fail(with: error)
        await task.value

        #expect(await saver.sent.count == 1)
        #expect(model.errorMessage == nil)
        #expect(!model.isSaving)
        #expect(model.draft.bio == "Analyst")
    }

    @Test("Discarding puts the draft back and clears the error")
    func discard() {
        let (model, _) = makeModel()
        model.draft.name = "Countess"
        model.errorMessage = "Something went wrong"

        model.discardChanges()

        #expect(model.draft == original)
        #expect(model.errorMessage == nil)
        #expect(!model.hasUnsavedChanges)
    }

    @Test("canSave is observable: a view reading it updates when the draft changes")
    func canSaveIsTracked() {
        let (model, _) = makeModel()
        let invalidated = Mutex(false)
        withObservationTracking {
            _ = model.canSave
        } onChange: {
            invalidated.withLock { $0 = true }
        }

        model.draft.name = "Ada L."

        #expect(invalidated.withLock { $0 })
        #expect(model.canSave)
    }
}
