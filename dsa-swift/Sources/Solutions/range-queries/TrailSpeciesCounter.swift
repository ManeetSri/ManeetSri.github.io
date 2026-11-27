// Reference solution: Species on trail segments. Mo's algorithm: compress the species ids to 0..<k so
// they can index a count array, sort the segment numbers by (block of left, right), and slide one
// window through them, keeping a count per species and the number of species with a count above
// zero. Each answer goes to its segment's original position.
// O((n + q)√n + q log q) time, O(n + q) space.

public enum TrailSpeciesCounter {
    public static func distinctSpecies(sightings: [Int], segments: [[Int]]) -> [Int] {
        // Compress species ids to 0..<k
        let distinctIds = Array(Set(sightings)).sorted()
        var rankOf: [Int: Int] = [:]
        for (rank, id) in distinctIds.enumerated() { rankOf[id] = rank }
        let species = sightings.map { rankOf[$0]! }

        var blockSize = 1
        while blockSize * blockSize < species.count { blockSize += 1 }
        let order = segments.indices.sorted { a, b in
            let blockA = segments[a][0] / blockSize, blockB = segments[b][0] / blockSize
            return blockA != blockB ? blockA < blockB : segments[a][1] < segments[b][1]
        }

        var count = [Int](repeating: 0, count: distinctIds.count)
        var distinct = 0
        var answers = [Int](repeating: 0, count: segments.count)
        var currentLeft = 0
        var currentRight = -1                                 // the window starts empty
        for q in order {
            let left = segments[q][0], right = segments[q][1]
            // Grow both ends first, then shrink, so the window never turns inside out
            while currentLeft > left {
                currentLeft -= 1
                count[species[currentLeft]] += 1
                if count[species[currentLeft]] == 1 { distinct += 1 }
            }
            while currentRight < right {
                currentRight += 1
                count[species[currentRight]] += 1
                if count[species[currentRight]] == 1 { distinct += 1 }
            }
            while currentLeft < left {
                count[species[currentLeft]] -= 1
                if count[species[currentLeft]] == 0 { distinct -= 1 }
                currentLeft += 1
            }
            while currentRight > right {
                count[species[currentRight]] -= 1
                if count[species[currentRight]] == 0 { distinct -= 1 }
                currentRight -= 1
            }
            answers[q] = distinct
        }
        return answers
    }
}
