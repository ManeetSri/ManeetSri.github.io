import DesignKit
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct PolymorphicRideTypesTests {
    typealias Rides = PolymorphicRideTypes

    /// A ride type the app has never seen, to prove the picker works through the protocol
    private struct Flat: PolymorphicRideTypes.RideType {
        let name: String
        let seats: Int
        let fare: Int

        func price(for trip: PolymorphicRideTypes.Trip) -> Int { fare }
    }

    private let crossTown = Rides.Trip(metres: 5400, minutes: 18)
    private let shortHopWithBags = Rides.Trip(metres: 800, minutes: 3, passengers: 3, hasLuggage: true)
    private let all: [any PolymorphicRideTypes.RideType] = [Rides.Lux(), Rides.XL(), Rides.Standard(), Rides.Pool()]

    @Test("Each ride prices a trip by its own rules")
    func prices() {
        #expect(Rides.Standard().price(for: crossTown) == 1150)
        #expect(Rides.XL().price(for: crossTown) == 1660)
        #expect(Rides.Pool().price(for: crossTown) == 690)
        #expect(Rides.Lux().price(for: crossTown) == 2840)
    }

    @Test("Lux has a minimum fare of £15")
    func minimumFare() {
        #expect(Rides.Lux().price(for: shortHopWithBags) == 1500)
        #expect(Rides.Standard().price(for: shortHopWithBags) == 390)
        #expect(Rides.XL().price(for: shortHopWithBags) == 595)
    }

    @Test("Fares round down to whole pence")
    func rounding() {
        let trip = Rides.Trip(metres: 1234, minutes: 0)
        #expect(Rides.Standard().price(for: trip) == 373)
        #expect(Rides.XL().price(for: trip) == 585)
        #expect(Rides.Pool().price(for: trip) == 223)
    }

    @Test("Rides need a seat for everyone, and Pool takes no luggage")
    func availability() {
        let trip = { (passengers: Int, luggage: Bool) in Rides.Trip(metres: 1000, minutes: 5, passengers: passengers, hasLuggage: luggage) }
        #expect(Rides.Standard().isAvailable(for: trip(4, true)))
        #expect(!Rides.Standard().isAvailable(for: trip(5, false)))
        #expect(Rides.XL().isAvailable(for: trip(6, true)))
        #expect(!Rides.XL().isAvailable(for: trip(7, false)))
        #expect(Rides.Pool().isAvailable(for: trip(2, false)))
        #expect(!Rides.Pool().isAvailable(for: trip(3, false)))
        #expect(!Rides.Pool().isAvailable(for: trip(1, true)))
    }

    @Test("Availability is decided by each type, even through `any RideType`")
    func dispatch() {
        let pool: any PolymorphicRideTypes.RideType = Rides.Pool()
        #expect(pool.isAvailable(for: Rides.Trip(metres: 1000, minutes: 5)))
        #expect(!pool.isAvailable(for: Rides.Trip(metres: 1000, minutes: 5, hasLuggage: true)))
    }

    @Test("The picker lists the rides that can take the trip, cheapest first")
    func picker() {
        #expect(Rides.quotes(for: crossTown, from: all) == [
            Rides.Quote(name: "Pool", price: 690),
            Rides.Quote(name: "Standard", price: 1150),
            Rides.Quote(name: "XL", price: 1660),
            Rides.Quote(name: "Lux", price: 2840),
        ])
        #expect(Rides.quotes(for: shortHopWithBags, from: all) == [
            Rides.Quote(name: "Standard", price: 390),
            Rides.Quote(name: "XL", price: 595),
            Rides.Quote(name: "Lux", price: 1500),
        ])
        #expect(Rides.quotes(for: Rides.Trip(metres: 1000, minutes: 5, passengers: 5), from: all).map(\.name) == ["XL"])
        #expect(Rides.quotes(for: Rides.Trip(metres: 1000, minutes: 5, passengers: 7), from: all).isEmpty)
    }

    @Test("A new ride type works without changing the picker, using the default seat rule")
    func newRideType() {
        let bike = Flat(name: "Bike", seats: 1, fare: 300)
        let solo = Rides.Trip(metres: 1000, minutes: 5)
        let pair = Rides.Trip(metres: 1000, minutes: 5, passengers: 2)
        #expect(Rides.quotes(for: solo, from: [Rides.Standard(), bike]).map(\.name) == ["Bike", "Standard"])
        #expect(Rides.quotes(for: pair, from: [Rides.Standard(), bike]).map(\.name) == ["Standard"])
    }

    @Test("Equal fares are listed in name order")
    func ties() {
        let rides: [any PolymorphicRideTypes.RideType] = [Flat(name: "Tuk-tuk", seats: 3, fare: 500), Flat(name: "Boat", seats: 8, fare: 500), Flat(name: "Scooter", seats: 1, fare: 200)]
        #expect(Rides.quotes(for: Rides.Trip(metres: 1000, minutes: 5), from: rides).map(\.name) == ["Scooter", "Boat", "Tuk-tuk"])
    }

    @Test("Server codes become ride types at the boundary", arguments: [("standard", "Standard"), ("xl", "XL"), ("pool", "Pool"), ("lux", "Lux")])
    func codes(code: String, name: String) {
        #expect(Rides.ride(code: code)?.name == name)
    }

    @Test("Codes the app doesn't know give no ride", arguments: ["bike", "", "XL"])
    func unknownCodes(code: String) {
        #expect(Rides.ride(code: code) == nil)
        #expect(Rides.ride(code: "standard") != nil)
    }
}
