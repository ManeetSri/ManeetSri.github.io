import DesignKit
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

private typealias Point = CouplingDeliveryTracker.Point
private typealias Vehicle = CouplingDeliveryTracker.Vehicle
private typealias Courier = CouplingDeliveryTracker.Courier
private typealias Order = CouplingDeliveryTracker.Order
private typealias ETA = CouplingDeliveryTracker.ETA

private let home = Point(x: 0, y: 0)

@Suite struct CouplingDeliveryTrackerTests {
    @Test("Each vehicle turns metres into whole minutes, rounded up")
    func vehicleMinutes() {
        #expect(Vehicle(kind: .bicycle).minutes(toTravel: 1_000) == 4)
        #expect(Vehicle(kind: .bicycle).minutes(toTravel: 1_001) == 5)
        #expect(Vehicle(kind: .scooter).minutes(toTravel: 1_000) == 3)
        #expect(Vehicle(kind: .car).minutes(toTravel: 1_000) == 2)
        #expect(Vehicle(kind: .car).minutes(toTravel: 0) == 0)
    }

    @Test("A courier works out minutes from their own position and vehicle")
    func courierMinutes() {
        let sam = Courier(name: "Sam", vehicle: Vehicle(kind: .scooter), location: Point(x: 3_000, y: 4_000))
        #expect(sam.minutes(to: home) == 13)  // 5,000 m at 400 m a minute is 12.5
        let ana = Courier(name: "Ana", vehicle: Vehicle(kind: .bicycle), location: Point(x: 3_000, y: 4_000))
        #expect(ana.minutes(to: home) == 20)
        #expect(ana.minutes(to: Point(x: 3_000, y: 4_000)) == 0)
    }

    @Test("An order describes its ETA at every stage")
    func orderETA() {
        let far = Courier(name: "Sam", vehicle: Vehicle(kind: .scooter), location: Point(x: 3_000, y: 4_000))
        let near = Courier(name: "Sam", vehicle: Vehicle(kind: .bicycle), location: Point(x: 150, y: 200))
        #expect(Order(stage: .preparing(readyInMinutes: 12), destination: home).eta() == .preparing(readyInMinutes: 12))
        #expect(Order(stage: .onTheWay(far), destination: home).eta() == .arriving(courierName: "Sam", minutes: 13))
        #expect(Order(stage: .onTheWay(near), destination: home).eta() == .arrivingNow(courierName: "Sam"))
        #expect(Order(stage: .delivered, destination: home).eta() == .delivered)
    }

    @Test("Two minutes away is still arriving, not arriving now")
    func arrivingBoundary() {
        let courier = Courier(name: "Ana", vehicle: Vehicle(kind: .car), location: Point(x: 600, y: 0))
        #expect(Order(stage: .onTheWay(courier), destination: home).eta() == .arriving(courierName: "Ana", minutes: 2))
        let closer = Courier(name: "Ana", vehicle: Vehicle(kind: .car), location: Point(x: 500, y: 0))
        #expect(Order(stage: .onTheWay(closer), destination: home).eta() == .arrivingNow(courierName: "Ana"))
    }

    @Test("The tracking card's text for each stage")
    func cardText() {
        let far = Courier(name: "Sam", vehicle: Vehicle(kind: .scooter), location: Point(x: 3_000, y: 4_000))
        let here = Courier(name: "Sam", vehicle: Vehicle(kind: .car), location: home)
        let text = CouplingDeliveryTracker.TrackingCard.text(for:)
        #expect(text(Order(stage: .preparing(readyInMinutes: 12), destination: home)) == "Being prepared, ready in 12 min")
        #expect(text(Order(stage: .preparing(readyInMinutes: 0), destination: home)) == "Almost ready")
        #expect(text(Order(stage: .onTheWay(far), destination: home)) == "Sam is 13 min away")
        #expect(text(Order(stage: .onTheWay(here), destination: home)) == "Sam is arriving now")
        #expect(text(Order(stage: .delivered, destination: home)) == "Delivered")
    }
}
