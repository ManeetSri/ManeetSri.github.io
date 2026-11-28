// Generated from src/dsa/content/lessons/stacks/stack-asteroids-k-digits.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func survivors(_ asteroids: [Int]) -> [Int] {
    var stack: [Int] = []
    for asteroid in asteroids {
        var alive = true
        while alive, asteroid < 0, let top = stack.last, top > 0 {
            if top < -asteroid {
                stack.removeLast()          // the right-mover explodes; keep checking
            } else if top == -asteroid {
                stack.removeLast()          // both explode
                alive = false
            } else {
                alive = false               // the left-mover explodes
            }
        }
        if alive {
            stack.append(asteroid)
        }
    }
    return stack
}

for asteroids in [[5, 10, -5], [8, -8], [10, 2, -5], [-2, -1, 1, 2], [1, -2, -2, 3], [3, 4, -10, 6]] {
    print(asteroids, "->", survivors(asteroids))
}
