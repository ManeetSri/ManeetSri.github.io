// Kata: Profile editor model (D18 · @Observable and @Bindable; Composition and view models)
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

    /// Saves a profile and returns it as the server stored it
    public protocol ProfileSaving: Sendable {
        func save(_ profile: Profile) async throws -> Profile
    }

    public static let maximumNameLength = 30
    public static let blankNameMessage = "Enter a name"
    public static let longNameMessage = "Use 30 characters or fewer"
    public static let saveFailedMessage = "Couldn't save your profile. Try again."

    /// The model behind an edit-profile form. Views bind their fields to `$model.draft.name` and friends,
    /// enable Save with `canSave`, and show `errorMessage` in an alert. No SwiftUI needed to test it.
    @MainActor
    @Observable
    public final class Model {
        /// The profile as it was last saved
        public private(set) var saved: Profile
        /// What the form edits
        public var draft: Profile
        /// A save is in flight
        public private(set) var isSaving = false
        /// Why the last save failed, for an alert. Setting it to nil dismisses the alert.
        public var errorMessage: String?

        private let saver: any ProfileSaving

        public init(profile: Profile, saver: any ProfileSaving) {
            saved = profile
            draft = profile
            self.saver = saver
        }

        /// `blankNameMessage` when the draft's name is blank once trimmed, `longNameMessage` when the trimmed
        /// name is longer than `maximumNameLength` characters, otherwise nil
        public var nameError: String? {
            // Write your solution here, then run:
            // swift test --filter ObservableProfileEditorTests
            nil
        }

        /// The draft differs from the saved profile
        public var hasUnsavedChanges: Bool {
            false
        }

        /// Save is enabled: there are unsaved changes, the name is valid and no save is in flight
        public var canSave: Bool {
            false
        }

        /// Saves the draft, with its name trimmed. Does nothing unless `canSave`. Keeps edits the user made
        /// while the save was in flight; shows `saveFailedMessage` on failure, and nothing on cancellation.
        public func save() async {}

        /// Puts the draft back to the saved profile and clears any error
        public func discardChanges() {}
    }
}
