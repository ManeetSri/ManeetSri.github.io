// Generated from src/dsa/design/content/lessons/sd-structural/sd-structural-decorator.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

func logged<Input, Output>(_ name: String, _ operation: @escaping (Input) -> Output) -> (Input) -> Output {
    { input in
        let output = operation(input)
        print("\(name)(\(input)) = \(output)")
        return output
    }
}

let priceWithVAT = logged("priceWithVAT") { (pence: Int) in pence * 6 / 5 }
let total = priceWithVAT(1000) + priceWithVAT(250)
print("Total: \(total)")
