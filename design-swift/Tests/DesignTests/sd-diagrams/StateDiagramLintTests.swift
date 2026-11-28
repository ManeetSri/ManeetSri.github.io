import DesignKit
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct StateDiagramLintTests {
    private typealias Diagram = StateDiagramLint.Diagram
    private typealias Transition = StateDiagramLint.Transition

    /// The voice recorder from the lesson: every state reachable, no dead ends, guards that differ
    private let recorder = Diagram(
        states: ["idle", "asking", "denied", "recording", "interrupted", "paused", "saving", "saved"],
        initial: "idle",
        finals: ["saved"],
        transitions: [
            Transition("idle", on: "tapRecord", to: "asking"),
            Transition("asking", on: "granted", to: "recording"),
            Transition("asking", on: "refused", to: "denied"),
            Transition("denied", on: "dismiss", to: "idle"),
            Transition("recording", on: "pause", to: "paused"),
            Transition("paused", on: "resume", to: "recording"),
            Transition("recording", on: "began", to: "interrupted"),
            Transition("interrupted", on: "ended", to: "recording", when: "shouldResume"),
            Transition("interrupted", on: "ended", to: "paused", when: "else"),
            Transition("recording", on: "stop", to: "saving"),
            Transition("paused", on: "stop", to: "saving"),
            Transition("saving", on: "saveFailed", to: "paused"),
            Transition("saving", on: "didSave", to: "saved"),
        ]
    )

    @Test("A well-formed diagram has no problems, and renders as Mermaid")
    func wellFormed() {
        #expect(StateDiagramLint.problems(in: recorder).isEmpty)
        #expect(StateDiagramLint.mermaid(recorder) == """
        stateDiagram-v2
            [*] --> idle
            idle --> asking : tapRecord
            asking --> recording : granted
            asking --> denied : refused
            denied --> idle : dismiss
            recording --> paused : pause
            paused --> recording : resume
            recording --> interrupted : began
            interrupted --> recording : ended [shouldResume]
            interrupted --> paused : ended [else]
            recording --> saving : stop
            paused --> saving : stop
            saving --> paused : saveFailed
            saving --> saved : didSave
            saved --> [*]
        """)
    }

    @Test("Names that aren't declared states are reported, each once")
    func unknownStates() {
        let diagram = Diagram(
            states: ["idle", "loading"],
            initial: "start",
            finals: ["done"],
            transitions: [
                Transition("idle", on: "load", to: "loading"),
                Transition("loading", on: "fail", to: "failed"),
                Transition("failed", on: "retry", to: "loading"),
            ]
        )
        let problems = StateDiagramLint.problems(in: diagram)
        #expect(problems.isSuperset(of: [.unknownState("start"), .unknownState("done"), .unknownState("failed")]))
        #expect(!problems.contains(.unknownState("idle")))
        #expect(!problems.contains(.unknownState("loading")))
    }

    @Test("States that no path from the initial state reaches are unreachable")
    func unreachable() {
        let diagram = Diagram(
            states: ["draft", "published", "trash", "archived"],
            initial: "draft",
            finals: ["published", "archived"],
            transitions: [
                Transition("draft", on: "publish", to: "published"),
                Transition("trash", on: "archive", to: "archived"),
            ]
        )
        #expect(StateDiagramLint.problems(in: diagram) == [.unreachable("trash"), .unreachable("archived")])
    }

    @Test("A state with no way out, or only a loop to itself, is a dead end unless it's final")
    func deadEnds() {
        let download = Diagram(
            states: ["queued", "downloading", "failed", "done"],
            initial: "queued",
            finals: ["done"],
            transitions: [
                Transition("queued", on: "start", to: "downloading"),
                Transition("downloading", on: "progress", to: "downloading"),
                Transition("downloading", on: "error", to: "failed"),
                Transition("downloading", on: "finish", to: "done"),
            ]
        )
        #expect(StateDiagramLint.problems(in: download) == [.deadEnd("failed")])

        let looping = Diagram(states: ["playing"], initial: "playing", transitions: [Transition("playing", on: "tick", to: "playing")])
        #expect(StateDiagramLint.problems(in: looping) == [.deadEnd("playing")])

        let finished = Diagram(states: ["done"], initial: "done", finals: ["done"], transitions: [])
        #expect(StateDiagramLint.problems(in: finished).isEmpty)
    }

    @Test("Transitions on the same event from the same state need different guards")
    func ambiguity() {
        let diagram = Diagram(
            states: ["idle", "queued", "failed"],
            initial: "idle",
            transitions: [
                Transition("failed", on: "retry", to: "queued", when: "attempts < 3"),
                Transition("failed", on: "retry", to: "idle", when: "attempts = 3"),
                Transition("queued", on: "cancel", to: "idle"),
                Transition("queued", on: "cancel", to: "failed", when: "offline"),
                Transition("idle", on: "start", to: "queued", when: "wifi"),
                Transition("idle", on: "start", to: "failed", when: "wifi"),
            ]
        )
        #expect(StateDiagramLint.problems(in: diagram) == [
            .ambiguous(state: "queued", event: "cancel"),
            .ambiguous(state: "idle", event: "start"),
        ])
    }

    @Test("A final state has no transitions out of it")
    func leavingFinal() {
        let diagram = Diagram(
            states: ["editing", "saved"],
            initial: "editing",
            finals: ["saved"],
            transitions: [
                Transition("editing", on: "save", to: "saved"),
                Transition("saved", on: "edit", to: "editing"),
            ]
        )
        #expect(StateDiagramLint.problems(in: diagram) == [.leavesFinal("saved")])
    }

    @Test("Mermaid lists the start, each transition in order with its guard, then the final states in order")
    func mermaidOrder() {
        let diagram = Diagram(
            states: ["idle", "loading", "loaded", "failed"],
            initial: "idle",
            finals: ["loaded", "failed"],
            transitions: [
                Transition("idle", on: "load", to: "loading"),
                Transition("loading", on: "done", to: "loaded", when: "ok"),
                Transition("loading", on: "done", to: "failed", when: "error"),
            ]
        )
        #expect(StateDiagramLint.mermaid(diagram) == """
        stateDiagram-v2
            [*] --> idle
            idle --> loading : load
            loading --> loaded : done [ok]
            loading --> failed : done [error]
            loaded --> [*]
            failed --> [*]
        """)
        let bare = Diagram(states: ["idle"], initial: "idle", transitions: [])
        #expect(StateDiagramLint.mermaid(bare) == "stateDiagram-v2\n    [*] --> idle")
    }
}
