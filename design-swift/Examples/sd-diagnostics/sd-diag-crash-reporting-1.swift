// Generated from src/dsa/design/content/lessons/sd-diagnostics/sd-diag-crash-reporting.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

// One frame from a crash report: "Shop  0x0000000104c3d2a4 0x104c34000 + 37540"
let loadAddress: UInt64 = 0x1_04c3_4000      // where ASLR put the app's binary in this launch
let frameAddress: UInt64 = 0x1_04c3_d2a4     // the instruction that was running

// In the binary as linked, an arm64 iOS app's code starts at 0x100000000. ASLR slides the whole image
// by a random amount per launch, so only the offset from the load address is meaningful.
let linkedTextStart: UInt64 = 0x1_0000_0000

// A dSYM is matched to the build by UUID, then maps linked addresses to functions, files and lines.
// Here, a tiny symbol table sorted by start address stands in for it.
struct Symbol {
    let start: UInt64
    let name: String
    let file: String
}

let symbols = [
    Symbol(start: 0x1_0000_4000, name: "AppDelegate.application(_:didFinishLaunchingWithOptions:)", file: "AppDelegate.swift"),
    Symbol(start: 0x1_0000_8a10, name: "CheckoutModel.applyDiscount(_:)", file: "CheckoutModel.swift"),
    Symbol(start: 0x1_0000_9c40, name: "CheckoutModel.total.getter", file: "CheckoutModel.swift"),
    Symbol(start: 0x1_0000_b200, name: "OrdersRepository.orders()", file: "OrdersRepository.swift"),
]

let offset = frameAddress - loadAddress
let linkedAddress = linkedTextStart + offset
print("offset: \(offset) bytes into the binary")
print("linked address: 0x\(String(linkedAddress, radix: 16))")

// The function containing an address is the last one that starts at or before it
if let symbol = symbols.last(where: { $0.start <= linkedAddress }) {
    print("\(symbol.name) + \(linkedAddress - symbol.start) (\(symbol.file))")
}
