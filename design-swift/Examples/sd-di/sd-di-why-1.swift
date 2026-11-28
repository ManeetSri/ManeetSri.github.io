// Generated from src/dsa/design/content/lessons/sd-di/sd-di-why.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

struct BoardingPass: Sendable {
    let tripID: String
    let departure: Date
}

protocol BoardingPassLoading: Sendable {
    func boardingPass(for tripID: String) async throws -> BoardingPass
}

protocol ReminderScheduling: Sendable {
    func remind(_ message: String, at date: Date) async
}

@MainActor final class BoardingPassModel {
    private let passes: any BoardingPassLoading
    private let reminders: any ReminderScheduling
    private let now: @Sendable () -> Date
    private(set) var pass: BoardingPass?

    // Everything the model touches arrives here, so its signature tells the whole story
    init(passes: any BoardingPassLoading, reminders: any ReminderScheduling, now: @escaping @Sendable () -> Date) {
        self.passes = passes
        self.reminders = reminders
        self.now = now
    }

    func refresh(tripID: String) async throws {
        let pass = try await passes.boardingPass(for: tripID)
        self.pass = pass
        let reminderTime = pass.departure.addingTimeInterval(-3 * 3600)
        if reminderTime > now() {
            await reminders.remind("Check in for \(tripID)", at: reminderTime)
        }
    }
}

// A test's world: a canned pass, reminders that are recorded, and a clock stopped at 09:00
struct CannedPasses: BoardingPassLoading {
    let departure: Date
    func boardingPass(for tripID: String) async throws -> BoardingPass {
        BoardingPass(tripID: tripID, departure: departure)
    }
}

actor RecordedReminders: ReminderScheduling {
    private(set) var scheduled: [String] = []
    func remind(_ message: String, at date: Date) {
        scheduled.append("\(message) at \(date.formatted(.iso8601))")
    }
}

let nineAM = Date(timeIntervalSince1970: 1_767_258_000)   // 1 January 2026, 09:00 UTC
let reminders = RecordedReminders()

let earlyFlight = BoardingPassModel(passes: CannedPasses(departure: nineAM.addingTimeInterval(5 * 3600)), reminders: reminders, now: { nineAM })
try await earlyFlight.refresh(tripID: "LIS-42")
print(await reminders.scheduled)

let soonFlight = BoardingPassModel(passes: CannedPasses(departure: nineAM.addingTimeInterval(3600)), reminders: reminders, now: { nineAM })
try await soonFlight.refresh(tripID: "OPO-7")
print("reminders after a flight in one hour:", await reminders.scheduled.count)
