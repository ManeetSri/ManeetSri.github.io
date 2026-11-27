// Reference solution: Jump to the nearest matching frame. Search outwards in rings around start:
// distance 0, then the two frames at distance 1, then distance 2, and so on, checking the left side of
// each ring first so ties go to the earlier frame. The first match found is the nearest. O(d) time for
// a match d frames away (O(n) when there's none), O(1) space.

public enum NearestMatchScan {
    public static func nearestIndex(of target: Int, in items: [Int], from start: Int) -> Int? {
        if items[start] == target { return start }
        var distance = 1
        while start - distance >= 0 || start + distance < items.count {
            let left = start - distance
            if left >= 0 && items[left] == target { return left }      // left first: ties go earlier
            let right = start + distance
            if right < items.count && items[right] == target { return right }
            distance += 1
        }
        return nil                                                      // both sides ran off the ends
    }
}
