// Generated from src/dsa/design/content/lessons/sd-refactoring/sd-refactoring-extract-protocol.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

enum SearchError: Error {
    case checkOutNotAfterCheckIn
    case noAdults
    case moreRoomsThanGuests
}

// A data clump, two dates that always travel together, now with its rule
struct Stay {
    let checkIn: Date
    let checkOut: Date

    init(checkIn: Date, checkOut: Date) throws(SearchError) {
        guard checkOut > checkIn else { throw .checkOutNotAfterCheckIn }
        self.checkIn = checkIn
        self.checkOut = checkOut
    }

    func nights(in calendar: Calendar) -> Int {
        calendar.dateComponents([.day], from: checkIn, to: checkOut).day ?? 0
    }
}

struct Guests {
    let adults: Int
    let children: Int
    let rooms: Int

    init(adults: Int, children: Int = 0, rooms: Int = 1) throws(SearchError) {
        guard adults >= 1 else { throw .noAdults }
        guard rooms <= adults + children else { throw .moreRoomsThanGuests }
        self.adults = adults
        self.children = children
        self.rooms = rooms
    }

    var total: Int { adults + children }
}

// Was: searchHotels(city:checkIn:checkOut:adults:children:rooms:petFriendly:freeCancellation:)
struct HotelSearch {
    var city: String
    var stay: Stay
    var guests: Guests
    var petFriendly = false
    var freeCancellation = false
}

let calendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!
    return calendar
}()

func june(_ day: Int) -> Date {
    calendar.date(from: DateComponents(year: 2026, month: 6, day: day))!
}

do {
    let search = HotelSearch(city: "Lisbon", stay: try Stay(checkIn: june(12), checkOut: june(15)), guests: try Guests(adults: 2, children: 1))
    print("\(search.city): \(search.stay.nights(in: calendar)) nights, \(search.guests.total) guests")
    _ = try Stay(checkIn: june(15), checkOut: june(12))
} catch {
    print("Rejected: \(error)")
}

do {
    _ = try Guests(adults: 1, rooms: 2)
} catch {
    print("Rejected: \(error)")
}
