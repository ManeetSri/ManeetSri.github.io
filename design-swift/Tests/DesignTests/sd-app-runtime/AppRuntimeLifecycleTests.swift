import DesignKit
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct AppRuntimeLifecycleTests {
    typealias Machine = AppRuntimeLifecycle.Machine
    typealias Event = AppRuntimeLifecycle.Event
    typealias Effect = AppRuntimeLifecycle.Effect

    /// Sends each event at its time (in seconds) and returns the effects of each
    private func run(_ machine: inout Machine, _ events: [(Event, Int)]) -> [[Effect]] {
        events.map { event, seconds in machine.handle(event, at: .seconds(seconds)) }
    }

    @Test("A user launch configures services; the first activation starts updates and refreshes")
    func coldLaunch() {
        var machine = Machine()
        #expect(machine.handle(.launch, at: .zero) == [.configureServices])
        #expect(machine.phase == .inactive)
        #expect(machine.handle(.didBecomeActive, at: .seconds(1)) == [.startLiveUpdates, .refreshContent])
        #expect(machine.phase == .active)
    }

    @Test("Going home stops updates, then saves inside a background task before suspending")
    func goingHome() {
        var machine = Machine()
        _ = run(&machine, [(.launch, 0), (.didBecomeActive, 1)])
        #expect(machine.handle(.willResignActive, at: .seconds(60)) == [.stopLiveUpdates])
        #expect(machine.phase == .inactive)
        #expect(machine.handle(.didEnterBackground, at: .seconds(60)) == [.beginBackgroundTask, .saveState, .releaseCaches])
        #expect(machine.phase == .background)
        #expect(machine.handle(.saveFinished, at: .seconds(61)) == [.endBackgroundTask])
        #expect(machine.handle(.suspend, at: .seconds(62)).isEmpty)
        #expect(machine.phase == .suspended)
    }

    @Test("Coming back refreshes only content older than the refresh interval")
    func refreshWhenStale() {
        var machine = Machine()
        _ = run(&machine, [(.launch, 0), (.didBecomeActive, 0)])
        // A two-minute phone call: inactive, then active again with fresh-enough content
        #expect(run(&machine, [(.willResignActive, 60), (.didBecomeActive, 180)]) == [[.stopLiveUpdates], [.startLiveUpdates]])
        // Twenty minutes in the background: stale by the time the user returns
        _ = run(&machine, [(.willResignActive, 200), (.didEnterBackground, 200), (.saveFinished, 201), (.suspend, 202)])
        #expect(machine.handle(.willEnterForeground, at: .seconds(1400)).isEmpty)
        #expect(machine.phase == .inactive)
        #expect(machine.handle(.didBecomeActive, at: .seconds(1400)) == [.startLiveUpdates, .refreshContent])
    }

    @Test("Content exactly one interval old counts as stale")
    func refreshBoundary() {
        var machine = Machine(refreshInterval: .seconds(300))
        _ = run(&machine, [(.launch, 0), (.didBecomeActive, 10), (.willResignActive, 20)])
        #expect(machine.handle(.didBecomeActive, at: .seconds(309)) == [.startLiveUpdates])
        _ = machine.handle(.willResignActive, at: .seconds(309))
        #expect(machine.handle(.didBecomeActive, at: .seconds(310)) == [.startLiveUpdates, .refreshContent])
    }

    @Test("Events that make no sense in the current phase are ignored")
    func ignoresImpossibleEvents() {
        var machine = Machine()
        #expect(machine.handle(.didBecomeActive, at: .zero).isEmpty)
        #expect(machine.phase == .notRunning)
        #expect(machine.handle(.launch, at: .zero) == [.configureServices])
        // Launching twice, suspending while on screen, resigning while not active
        #expect(run(&machine, [(.launch, 1), (.suspend, 1), (.willResignActive, 1), (.saveFinished, 1)]) == [[], [], [], []])
        #expect(machine.phase == .inactive)
        _ = machine.handle(.didBecomeActive, at: .seconds(2))
        // Active never jumps straight to the background: it passes through inactive first
        #expect(machine.handle(.didEnterBackground, at: .seconds(3)).isEmpty)
        #expect(machine.phase == .active)
    }

    @Test("A background task ends exactly once, whichever comes first")
    func backgroundTaskEndsOnce() {
        var machine = Machine()
        _ = run(&machine, [(.launch, 0), (.didBecomeActive, 0), (.willResignActive, 5), (.didEnterBackground, 5)])
        #expect(machine.handle(.backgroundTimeExpired, at: .seconds(35)) == [.endBackgroundTask])
        #expect(machine.handle(.saveFinished, at: .seconds(36)).isEmpty)
        #expect(machine.handle(.backgroundTimeExpired, at: .seconds(37)).isEmpty)
    }

    @Test("Never holds two background tasks, even when the user bounces back mid-save")
    func oneTaskAtATime() {
        var machine = Machine()
        _ = run(&machine, [(.launch, 0), (.didBecomeActive, 0), (.willResignActive, 5), (.didEnterBackground, 5)])
        // Back in the foreground before the save finished, then out again
        #expect(run(&machine, [(.willEnterForeground, 6), (.didBecomeActive, 6), (.willResignActive, 7)]) == [[], [.startLiveUpdates], [.stopLiveUpdates]])
        #expect(machine.handle(.didEnterBackground, at: .seconds(7)) == [.saveState, .releaseCaches])
        #expect(machine.handle(.saveFinished, at: .seconds(8)) == [.endBackgroundTask])
        #expect(machine.handle(.saveFinished, at: .seconds(9)).isEmpty)
    }

    @Test("iOS doesn't suspend an app while it holds a background task")
    func noSuspensionDuringTask() {
        var machine = Machine()
        _ = run(&machine, [(.launch, 0), (.didBecomeActive, 0), (.willResignActive, 5), (.didEnterBackground, 5)])
        #expect(machine.handle(.suspend, at: .seconds(6)).isEmpty)
        #expect(machine.phase == .background)
        _ = machine.handle(.saveFinished, at: .seconds(7))
        _ = machine.handle(.suspend, at: .seconds(8))
        #expect(machine.phase == .suspended)
    }

    @Test("Termination runs no code, and the next launch starts from nothing")
    func termination() {
        var machine = Machine()
        _ = run(&machine, [(.launch, 0), (.didBecomeActive, 0), (.willResignActive, 5), (.didEnterBackground, 5)])
        // Killed with the task still open: no effects, and the task is gone with the process
        #expect(machine.handle(.terminate, at: .seconds(6)).isEmpty)
        #expect(machine.phase == .notRunning)
        #expect(machine.handle(.saveFinished, at: .seconds(7)).isEmpty)
        // Relaunched a minute later: the old refresh time died with the process, so it refreshes again
        #expect(run(&machine, [(.launch, 60), (.didBecomeActive, 61)]) == [[.configureServices], [.startLiveUpdates, .refreshContent]])
        #expect(machine.handle(.terminate, at: .seconds(62)).isEmpty)
        #expect(machine.handle(.terminate, at: .seconds(63)).isEmpty)
        #expect(machine.phase == .notRunning)
    }

    @Test("A background launch has no UI until the user opens the app")
    func backgroundLaunch() {
        var machine = Machine()
        #expect(machine.handle(.launchInBackground, at: .zero) == [.configureServices])
        #expect(machine.phase == .background)
        #expect(machine.handle(.didBecomeActive, at: .seconds(1)).isEmpty)
        #expect(machine.handle(.suspend, at: .seconds(20)).isEmpty)
        #expect(machine.phase == .suspended)
        #expect(run(&machine, [(.willEnterForeground, 600), (.didBecomeActive, 600)]) == [[], [.startLiveUpdates, .refreshContent]])
        #expect(machine.phase == .active)
    }
}
