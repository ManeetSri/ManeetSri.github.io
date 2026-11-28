// Reference solution: Profile editor model. Every rule is a stored property or a computed one derived
// from them, so SwiftUI tracks the derived flags through what they read. `save()` remembers the draft it
// sent: the model stays on the main actor while the request is in flight, so the user can keep typing,
// and only a draft that hasn't changed since is replaced by the server's copy.
import Foundation
import Observation

public enum ObservableProfileEditor {
    public struct Profile: Equatable, Sendable {
        public var name: String
        public var bio: String
        public var isPublic: Bool

        public init(name: String, bio: String = "", isPublic: Bool = false) {
            self.name = name
            self.bio = bio
            self.isPublic = isPublic
        }
    }

    public protocol ProfileSaving: Sendable {
        func save(_ profile: Profile) async throws -> Profile
    }

    public static let maximumNameLength = 30
    public static let blankNameMessage = "Enter a name"
    public static let longNameMessage = "Use 30 characters or fewer"
    public static let saveFailedMessage = "Couldn't save your profile. Try again."

    @MainActor
    @Observable
    public final class Model {
        public private(set) var saved: Profile
        public var draft: Profile
        public private(set) var isSaving = false
        public var errorMessage: String?

        private let saver: any ProfileSaving

        public init(profile: Profile, saver: any ProfileSaving) {
            saved = profile
            draft = profile
            self.saver = saver
        }

        private var trimmedName: String {
            draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        public var nameError: String? {
            if trimmedName.isEmpty { return ObservableProfileEditor.blankNameMessage }
            if trimmedName.count > ObservableProfileEditor.maximumNameLength { return ObservableProfileEditor.longNameMessage }
            return nil
        }

        public var hasUnsavedChanges: Bool {
            draft != saved
        }

        public var canSave: Bool {
            hasUnsavedChanges && nameError == nil && !isSaving
        }

        public func save() async {
            guard canSave else { return }
            var sending = draft
            sending.name = trimmedName
            let draftWhenSent = draft
            isSaving = true
            errorMessage = nil
            defer { isSaving = false }

            do {
                let stored = try await saver.save(sending)
                saved = stored
                if draft == draftWhenSent {
                    draft = stored
                }
            } catch is CancellationError {
                // Cancelled, not failed: nothing to tell the user
            } catch let error as URLError where error.code == .cancelled {
                // URLSession's way of saying the same
            } catch {
                if !Task.isCancelled {
                    errorMessage = ObservableProfileEditor.saveFailedMessage
                }
            }
        }

        public func discardChanges() {
            draft = saved
            errorMessage = nil
        }
    }
}
