// Generated from src/dsa/design/content/lessons/sd-functional/sd-functional-environment.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

struct Reminder: Equatable, Sendable {
    let id: String
    let title: String
    let fireDate: Date
}

/// Everything the feature needs from notifications, as values
struct NotificationsClient: Sendable {
    var requestAuthorization: @Sendable () async -> Bool
    var schedule: @Sendable (Reminder) async -> Void
}

/// The feature's whole view of the outside world
struct ReminderEnvironment: Sendable {
    var now: @Sendable () -> Date
    var calendar: Calendar
    var newID: @Sendable () -> String
    var notifications: NotificationsClient
}

enum ReminderOutcome: Equatable {
    case scheduled(Date)
    case notAllowed
}

/// "Remind me tomorrow": 9am the next day, in the environment's calendar
func remindTomorrow(_ title: String, in environment: ReminderEnvironment) async -> ReminderOutcome {
    guard await environment.notifications.requestAuthorization() else { return .notAllowed }
    let calendar = environment.calendar
    let tomorrow = calendar.date(byAdding: .day, value: 1, to: environment.now())!
    let fireDate = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: tomorrow)!
    await environment.notifications.schedule(Reminder(id: environment.newID(), title: title, fireDate: fireDate))
    return .scheduled(fireDate)
}

// A test's world: a fixed time, a fixed id, and notifications that are recorded instead of shown
actor Scheduled {
    private(set) var reminders: [Reminder] = []
    func add(_ reminder: Reminder) { reminders.append(reminder) }
}

let scheduled = Scheduled()
var utc = Calendar(identifier: .gregorian)
utc.timeZone = TimeZone(identifier: "UTC")!

let testWorld = ReminderEnvironment(
    now: { Date(timeIntervalSince1970: 1_767_225_600) },   // 1 January 2026, 00:00 UTC
    calendar: utc,
    newID: { "reminder-1" },
    notifications: NotificationsClient(
        requestAuthorization: { true },
        schedule: { await scheduled.add($0) }
    )
)

print(await remindTomorrow("Call the bank", in: testWorld))
for reminder in await scheduled.reminders {
    print(reminder.id, reminder.title, reminder.fireDate.formatted(.iso8601))
}

// Override one endpoint, keep the rest
var deniedWorld = testWorld
deniedWorld.notifications.requestAuthorization = { false }
print(await remindTomorrow("Call the bank", in: deniedWorld))
print(await scheduled.reminders.count)
