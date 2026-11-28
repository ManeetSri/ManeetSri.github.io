import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct MenuBillTests {
    let menu = ["tea": 250, "toast": 300, "soup": 550, "water": 0]

    @Test("Adds up items on the menu")
    func onMenu() {
        #expect(MenuBill.total(for: ["tea", "toast"], prices: menu, specialPrice: 900) == 550)
        #expect(MenuBill.total(for: ["soup"], prices: menu, specialPrice: 900) == 550)
    }

    @Test("Charges the special price for items not on the menu")
    func offMenu() {
        #expect(MenuBill.total(for: ["tea", "pancakes"], prices: menu, specialPrice: 900) == 1_150)
        #expect(MenuBill.total(for: ["curry", "pie"], prices: menu, specialPrice: 700) == 1_400)
    }

    @Test("Repeated items are charged each time")
    func repeats() {
        #expect(MenuBill.total(for: ["tea", "tea", "tea"], prices: menu, specialPrice: 900) == 750)
        #expect(MenuBill.total(for: ["cake", "cake"], prices: menu, specialPrice: 400) == 800)
    }

    @Test("A free item on the menu costs 0, not the special price")
    func freeItem() {
        #expect(MenuBill.total(for: ["water", "water"], prices: menu, specialPrice: 900) == 0)
    }

    @Test("Names must match exactly")
    func exactNames() {
        #expect(MenuBill.total(for: ["Tea"], prices: menu, specialPrice: 900) == 900)
    }

    @Test("An empty order costs nothing")
    func emptyOrder() {
        #expect(MenuBill.total(for: [], prices: menu, specialPrice: 900) == 0)
    }

    @Test("With an empty menu, everything is special")
    func emptyMenu() {
        #expect(MenuBill.total(for: ["tea", "toast"], prices: [:], specialPrice: 500) == 1_000)
    }
}
