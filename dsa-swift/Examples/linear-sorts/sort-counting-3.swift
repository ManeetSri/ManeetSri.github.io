// Generated from src/dsa/content/lessons/linear-sorts/sort-counting.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Parcel {
    let id: String
    let service: Int        // 0 express, 1 standard, 2 economy
}

func sortByService(_ parcels: [Parcel], services: Int) -> [Parcel] {
    // 1. Count each key
    var next = [Int](repeating: 0, count: services)
    for parcel in parcels {
        next[parcel.service] += 1
    }
    print("counts:", next)
    // 2. Turn the counts into starting positions: the total of the counts before each key
    var total = 0
    for key in 0..<services {
        let count = next[key]
        next[key] = total
        total += count
    }
    print("starts:", next)
    // 3. Place each parcel at its key's next free position, in input order
    var result = parcels                         // placeholder values: every slot gets overwritten
    for parcel in parcels {
        result[next[parcel.service]] = parcel
        next[parcel.service] += 1
    }
    return result
}

let parcels = [
    Parcel(id: "A", service: 1), Parcel(id: "B", service: 0), Parcel(id: "C", service: 2),
    Parcel(id: "D", service: 1), Parcel(id: "E", service: 0), Parcel(id: "F", service: 1),
]
let sorted = sortByService(parcels, services: 3)
print(sorted.map { "\($0.id)\($0.service)" })
