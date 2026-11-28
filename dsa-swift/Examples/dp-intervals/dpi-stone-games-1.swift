// Generated from src/dsa/content/lessons/dp-intervals/dpi-stone-games.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func greedyGame(_ coins: [Int]) -> (first: Int, second: Int) {
    var left = 0
    var right = coins.count - 1
    var scores = [0, 0]
    var player = 0
    while left <= right {
        if coins[left] >= coins[right] {          // take the bigger end
            scores[player] += coins[left]
            left += 1
        } else {
            scores[player] += coins[right]
            right -= 1
        }
        player = 1 - player
    }
    return (scores[0], scores[1])
}

print(greedyGame([3, 9, 1, 2]))
