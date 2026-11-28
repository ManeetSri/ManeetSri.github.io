# Writing content for the System Design course

Everything a lesson, quiz, design exercise, architecture review or kata needs. The course lives at `/design` in the same console as DSA, and shares its MDX pipeline, quiz types and checks. Read `lessons/sd-orientation/` for finished lessons, `designs/sd-design-forecast-screen.mdx` for a design exercise, `critiques/sd-review-orders-view-controller.mdx` for an architecture review and `katas/sd-kata-backoff-schedule.mdx` for a kata: they follow every rule below.

## Who it's for

Maneet: an iOS developer who ships apps and knows Swift and DSA, learning system design and architecture **from the beginning**. Assume Swift fluency; treat every design term (cohesion, idempotency, backpressure…) as new until a lesson has taught it, then use it freely.

- **Voice:** warm, direct and concrete. Second person ("you"). Short sentences, one idea per paragraph. No hype, no emojis, no "simply" or "just".
- **Leaning iOS:** examples are Swift and Apple frameworks (URLSession, SwiftUI, Core Data, BGTaskScheduler…). Mention Android or cross-platform only where the contrast teaches something.
- **Spelling:** British English (organise, behaviour, modelling, optimise).
- **Accuracy:** Swift 6 language mode, iOS 18 and current Apple APIs. Every claim about a framework must be true today. If something changed recently, say which version.
- **Length:** match the lesson's minutes in `src/dsa/design/data/parts/part-NN.js`: about 120–150 words per minute of reading, plus diagrams, code and quiz time.
- **Trade-offs over rules.** System design has few absolute answers. Say what each option costs and when it wins; avoid "always" and "never" unless they're true.

## Files you create

| What | Where |
| --- | --- |
| Lesson | `src/dsa/design/content/lessons/<module-id>/<lesson-id>.mdx`. Ids and titles come from `src/dsa/design/data/parts/part-NN.js`; never change them. Then add the lesson's id to `src/dsa/design/data/ready/<module-id>.js`, which marks it ready. |
| Design exercise or review metadata | `src/dsa/design/data/exercises/<module-id>.js` (already exists; its default export is an array) |
| Kata metadata | `src/dsa/design/data/katas/<module-id>.js` (already exists; its default export is an array) |
| Design exercise | `src/dsa/design/content/designs/<id>.mdx` |
| Architecture review | `src/dsa/design/content/critiques/<id>.mdx` |
| Kata statement | `src/dsa/design/content/katas/<id>.mdx` |
| Kata stub, solution, tests | `design-swift/Sources/Exercises/<module-id>/<Type>.swift`, `design-swift/Sources/Solutions/<module-id>/<Type>.swift`, `design-swift/Tests/DesignTests/<module-id>/<Type>Tests.swift` |
| Runnable examples | Generated into `design-swift/Examples/<module-id>/` by `npm run design:examples`. Never edit them by hand. |

Edit only your module's files. Don't change the outline (`parts/part-NN.js`), `practice.js`, the aggregators (`ready.js`, `exercises.js`, `katas.js`), components, scripts or DesignKit without being asked; if something you need is missing, say so in your report. The page shows the lesson title, so the file doesn't repeat it.

**Every id starts with `sd-`**: modules, lessons, katas (`sd-kata-…`), design exercises (`sd-design-…`) and reviews (`sd-review-…`). That prefix is how the console keeps this course's progress apart from DSA's, and `design:check` enforces it. Ids are permanent once published.

## Lesson structure

Use `##` for sections (they become "On this page") and `###` inside them.

1. `## Why it matters`: two to four sentences. Where this shows up in real apps, and why interviews ask about it.
2. **Concept sections** (`## …`, descriptive titles). Build the idea in small steps: a plain explanation, an analogy callout where it genuinely helps, a diagram where seeing it beats reading it, and Swift showing it in an iOS context.
3. `## Trade-offs`: a table of the options against the criteria that matter here (complexity, testability, performance, offline, battery, team size…), with a sentence on when each wins.
4. `<Callout kind="interview">`: what to say, what to ask, and the red flags interviewers listen for. Skip it only where interviews never go.
5. **iOS gotchas and common mistakes**: `<Callout kind="gotcha" title="iOS gotcha: …">` or a short section.
6. `## Practice` (when the lesson has practice items): what to try and why. The page lists the items under the lesson.
7. A ` ```cards ` block: 2–4 key takeaways.
8. A ` ```quiz ` block: 3–6 questions, ending the lesson.

## MDX rules (the build fails otherwise)

- In prose, `{`, `}`, `<` and `>` must be inside inline code or replaced with words; write sets as `\{A, B\}`. `design:check` flags any unescaped brace.
- Components need a blank line before and after their content. Callout kinds: `note`, `tip`, `gotcha` (title it "iOS gotcha: …" or "Swift gotcha: …"), `warning`, `analogy`, `interview`.
- Link to a lesson with `[its title](/design/learn/<lesson-id>)`, and to DSA with `/dsa/learn/<id>` when a DSA idea helps. Don't link ahead; say "you'll meet this in D38".

## Code blocks

| Meta | Use it for | Checked by |
| --- | --- | --- |
| ` ```swift run ` + ` ```output ` | Complete programs using Foundation and Swift Concurrency: they run on a Mac | `design:examples --verify` runs them in Swift 6 mode and compares the output |
| ` ```swift check ` | Fragments that aren't programs (a protocol, a type, a function) and use only macOS-available frameworks | type-checked on macOS |
| ` ```swift check ios ` | Anything using UIKit, SwiftUI-for-iOS, WidgetKit, ActivityKit, CoreLocation-on-iOS…: iOS-only APIs | type-checked against the iOS simulator SDK |
| `group=<name>` (with `check`) | Several blocks in one file that only compile together, in order | checked as one file |
| ` ```swift ` (no meta) | Deliberately partial or pseudo code. Use sparingly. | not checked |
| ` ```json `, ` ```http `, ` ```graphql `, ` ```yaml `, ` ```sql `, ` ```bash ` | Payloads, requests, schemas, commands | not checked |

Rules for `run` blocks: deterministic output (no dates, randomness, timing or unordered collections), no crashes, no input, quick. Swift 6 mode means top-level code runs on the main actor; concurrency examples must be data-race free or they won't compile, which is exactly the lesson. Show code that's *meant* to fail (a data race, a retain cycle) without `run`/`check`, and show the compiler's message in a ` ```text title="What you'll see" ` block. `check` blocks are compiled as far as SIL, so data-race (region isolation) errors, missing returns and use-before-initialisation fail the check just as they would in Xcode: a fragment with an elided body (`// …`) must still return something.

## Diagrams and simulators (` ```visual <name> `)

Use one where watching an idea unfold beats reading about it: at most two per lesson. The YAML body is checked when the site builds. The full reference for each kind is below: the four scripted diagrams (`flow`, `sequence`, `states`, `timeline`) and the five simulators (`cacheSim`, `retry`, `rateLimiter`, `hashRing`, `estimator`). DSA's visualisers (`graph`, `hashTable`, `stackQueue`…) work here too.

### Scripted diagrams (` ```visual flow | sequence | states | timeline `)

You describe the picture and its steps in YAML, and the learner steps through it in the usual player (play, pause, speed, a step slider). The build checks every block and fails with a sentence naming the problem: an unknown id, a duplicate, two nodes on top of each other, an event the state machine can't take, a timeline step that goes back in time.

**What all four share**

- **Ids** are single words: letters, digits, `_`, `.` and `-` (`api`, `auth-server`, `v2`). Quote anything YAML would read as a number.
- **`say`** is the sentence under the picture for that step. It takes inline markdown: `` `code` ``, `**bold**` and `*italic*`. One idea per step, and say *why*, not only what moves.
- **`title`** (optional) is the caption above the diagram. **`caption`** (flow and timeline) is the sentence shown under a diagram that has no steps.
- **Tones** for states and spans: `neutral`, `active` (amber), `ok` (green), `error` (red), `wait` (blue).
- **Without steps**, a diagram is a still picture: no controls and no step count.
- **`code`** (optional, Swift) shows under the diagram, and a step's `line` lights that line, as in the DSA tracers.
- Diagrams wider than the lesson column scroll sideways inside their own box. Keep them to about 5 columns (flow, states) or 5 participants (sequence) so they stay readable on a phone.
- In YAML flow lists, quote text that contains `:`, `,`, `[`, `]`, `{`, `}` or `#`, or starts with `*`, `&`, `!` or a quote: `"GET /items?page=2"`, `'edit: "Groceries"'`.

#### `flow`: components and the messages between them

```yaml
title: Refreshing an expired access token
layers:                                    # optional horizontal bands behind the nodes
  - { label: Device, rows: [0, 0] }
  - { label: Backend, rows: 2 }            # one row, or [from, to]
nodes:                                     # at: [column, row] on a grid of ~140 × 84 px cells
  - { id: app, label: App, kind: client, at: [0, 0] }
  - { id: client, label: API client, kind: service, at: [2, 0] }
  - { id: keychain, label: Keychain, kind: store, at: [4, 0] }
  - { id: api, label: Profile API, kind: service, at: [1, 2] }
  - { id: auth, label: Auth server, kind: external, at: [3, 2], w: 1 }
groups:                                    # optional dashed boundary around nodes
  - { id: phone, label: iPhone, nodes: [app, client, keychain] }
edges:                                     # [from, to, label?, { style }?]
  - [app, client, GET /me]
  - [client, keychain, token, { style: data }]
  - [client, api, request]
  - [api, client, response]
  - [client, auth, refresh, { style: async }]
  - [auth, client, new tokens]
steps:
  - say: The app asks its **API client** for the profile.
    show: [app, client]
    send: app->client
  - say: The token has expired, so the API answers `401`.
    show: [keychain, api]
    send: api->client
    state: { api: error }
    label: { api->client: "401" }
  - say: The client starts **one** refresh; other requests wait behind it.
    show: [auth]
    send: client->auth
    state: { client: wait }
    label: { client: refreshing }
  - say: The new tokens arrive and the retried request succeeds.
    send: auth->client
    state: { client: null, api: ok }
    label: { client: null }
```

- **`kind`** (default `service`) sets a node's accent, a small shape change and its tag: `client`, `view`, `service`, `store` (on-device: Keychain, files, Core Data), `db`, `cache`, `queue`, `cdn`, `external` (dashed: someone else's system) and `actor` (a person).
- **`w`** makes a node span several columns. Positions can be fractions (`at: [1.5, 0]`) to centre a node under two others.
- **Edge styles:** `sync` (solid, the default), `async` (dashed), `data` (dotted: reads and writes rather than calls). An edge in each direction between the same two nodes is drawn as two parallel lines.
- **A step** lists only what changes:
  - `show` / `hide`: node ids, group ids (all their nodes) or edge keys like `client->api`. Shown things stay shown. An edge appears once both its ends are shown, unless some step names it in `show` or `hide`. Before a step shows them, parts are drawn faintly so the layout never jumps. If no step uses `show`, `hide` or `reset`, everything is visible throughout.
  - `send: a->b` (or a list): a token travels along that edge, which also shows it and its ends. Writing it backwards (`api->client` on an edge declared `client->api`) sends it the other way. Under reduced motion the edge lights up and a dot marks the receiving end instead.
  - `active`: highlights nodes, groups or edges for this step only.
  - `state: { id: tone }` and `label: { id: text }` stay until changed; `null` (or `neutral`) clears them. A node's label shows as a badge on its bottom edge; an edge's label replaces the edge's own text.
  - `reset: true` starts again from nothing: no visibility, states or labels.
- **Tips:** keep edge labels to a word or two. Leave an empty column between nodes joined by a labelled edge; between neighbouring cells the label moves off the line into the gap below. Lay the main path out left to right or top to bottom, and keep edges from crossing nodes. Use `layers` for tiers (device, edge, backend) and `groups` for ownership or process boundaries.

#### `sequence`: who calls whom, in order

```yaml
title: Sign in with OAuth and PKCE
participants:
  - { id: app, label: App }
  - { id: session, label: Auth session }
  - { id: auth, label: Auth server }
messages:                                  # numbered from 0, notes included
  - [app, app, make verifier + challenge]                       # 0: a self-call
  - { note: The verifier never leaves the device., over: app }  # 1
  - [app, session, "open /authorize?challenge"]                 # 2
  - [session, app, "callback ?code", { reply: true, say: "The redirect hands the app a one-time **code**." }]
  - [app, auth, "POST /token (code, verifier)"]                 # 4
  - [auth, app, access + refresh tokens, { reply: true }]       # 5
  - [auth, app, invalid_grant, { reply: true }]                 # 6
fragments:
  - { kind: alt, label: verifier matches, from: 5, to: 6, else: 6, elseLabel: mismatch }
```

- **A message** is `[from, to, text, { reply?, async?, say?, line? }]`. Calls are solid with a filled arrowhead; `async: true` gives an open arrowhead; `reply: true` is dashed with an open arrowhead. `from` equal to `to` draws a self-call as a loop.
- **A note** is `{ note, over }`, where `over` is one participant or a list (the note spans them).
- **Fragments** box a run of entries: `kind` is `loop`, `alt`, `opt` or `par`; `from` and `to` are entry indexes (inclusive). `else` (an index after `from`) adds a dashed divider where the second branch starts, labelled `elseLabel`. Fragments nest, but can't cross.
- **Frames:** one per entry, with the entry's `say` or a default like "App → Auth server: POST /token". Later entries stay faint. For fewer, bigger steps, add `steps: [{ say, upTo }]`: each step reveals entries up to index `upTo` (never going back) and highlights the new ones; `upTo: -1` is a step before the first message.
- **Tips:** short message text (it sets the gap between lifelines); put explanations in `say`, not in the arrow. Three to five participants fit a phone.

#### `states`: a state machine, walked event by event

```yaml
title: A background download
states:                                    # at: [column, row]
  - { id: idle, label: Idle, at: [0, 0] }
  - { id: queued, label: Queued, at: [1, 0] }
  - { id: downloading, label: Downloading, at: [2, 0] }
  - { id: paused, label: Paused, at: [2, 1] }
  - { id: failed, label: Failed, at: [1, 1] }
  - { id: done, label: Done, at: [3, 0] }
initial: idle
final: [done]
transitions:                               # [from, to, event, guard?]
  - [idle, queued, enqueue]
  - [queued, downloading, start]
  - [downloading, downloading, progress]
  - [downloading, paused, pause]
  - [paused, downloading, resume]
  - [downloading, failed, error]
  - [failed, queued, retry, attempts < 3]
  - [failed, idle, retry, attempts = 3]
  - [downloading, done, finish]
events: [enqueue, start, progress, pause, resume, error, "retry [attempts < 3]", start, finish]
```

- **Frames:** the first shows the initial state (`intro` replaces its sentence); then one per event, lighting the current state and the transition taken, with a default sentence like "`pause`: **Downloading** → **Paused**." An event can be a mapping, `{ event, guard?, say?, line? }`, to write your own sentence.
- **The build walks `events`** from `initial`. An event the current state has no transition for fails the build, naming the state and what it does handle. When two transitions leave a state on the same event, name the guard: `"retry [attempts < 3]"`.
- **Drawing:** a transition in each direction between two states is drawn as two arcs; transitions from a state to itself are loops on a free side; several transitions on one arrow stack their labels; guards go on a second line. Final states have a double border, and a dot marks the start.
- **Tips:** leave the initial state's left side free for the start dot. Event names are verbs in code font (`start`, `didFail`); guards are short conditions. Walk the interesting path, including a failure and its recovery, rather than every transition.

#### `timeline`: what happens when, across devices or services

```yaml
title: Two devices edit one note
unit: s                                    # ms (default), s or min
lanes:
  - { id: phone, label: iPhone }
  - { id: server, label: Server }
  - { id: mac, label: Mac }
spans:                                     # tone: neutral (default), active, ok, error, wait
  - { lane: phone, from: 0, to: 4, label: 'offline edit: "Groceries"', tone: wait }
  - { lane: mac, from: 1, to: 2, label: 'edit: "Shopping"', tone: active }
  - { lane: server, from: 2, to: 2.5, label: v2, tone: ok }
  - { lane: phone, from: 4, to: 5, label: upload (based on v1) }
  - { lane: server, from: 5, to: 5.6, label: conflict, tone: error }
markers:
  - { at: 4, label: back online }
steps:                                     # the time cursor, never going back
  - { at: 0, say: The iPhone goes offline and keeps editing. }
  - { at: 2.5, say: "Meanwhile the Mac's edit reaches the server as **v2**." }
  - { at: 5.3, say: "The iPhone uploads an edit of v1: a **conflict**." }
```

- **Spans** need `to` later than `from` (use a marker for an instant) and can't overlap within a lane; give overlapping work its own lane. **Markers** are dashed vertical lines with a label at the top.
- **Steps** move a time cursor forward (two steps may share a time). A span or marker appears once the cursor reaches its start; a running span is outlined and fills up to the cursor. Without steps, everything shows at once.
- **The axis** starts at 0 (or the earliest time, if negative) and ends at the latest; set `start` and `end` to zoom in.
- **Tips:** great for sync conflicts across devices, an actor hopping between threads, a request's lifecycle (DNS, TLS, TTFB, download), retries with backoff, and main-thread hitches. Keep labels short: one that doesn't fit its span goes after it, or is shortened with an ellipsis.

### Simulators (` ```visual cacheSim | retry | rateLimiter | hashRing | estimator `)

Small programs you configure in YAML. The first four are stepped through in the Player, one event per step with a sentence explaining it; `estimator` is a panel of sliders. The build checks every block: a missing field, a typo in a field name, an unknown policy or algorithm, times out of order or a formula that doesn't parse fails the build with a message naming the field. Every simulator also takes an optional `title`, which replaces the default caption.

| name | props | shows |
| --- | --- | --- |
| `cacheSim` | `layers` (fastest first, each `{ name, capacity }`), `origin`, `policy`, `ttl`, `requests` | each layer's contents in eviction order, hit/miss per layer, promotion, evictions and why, TTL expiry, running hit rates, and a request timeline coloured by where each request was served |
| `retry` | `base`, `factor`, `cap`, `attempts`, `jitter`, `seed`, `failUntil`, `breaker` | attempts, waits and jitter ranges on a timeline, breaker states (closed/open/half-open), short-circuited calls, a table of attempts, and the no-jitter schedule to compare against |
| `rateLimiter` | `algorithm` plus its settings, `requests` | each request allowed or rejected and why, the bucket level, queue or window counts, and a summary of the busiest span |
| `hashRing` | `nodes`, `vnodes`, `keys`, `steps`, `hash` | the ring with each node's points and arcs, keys coloured by owner, keys that move on each add/remove, and the count `hash % N` would have moved |
| `estimator` | `inputs` (sliders), `outputs` (formulas) | live results with their formulas, accessible sliders (log or linear) and a reset button |

#### `cacheSim`

```yaml
layers:                       # 1–4 layers, fastest first; capacity 1–24 entries
  - { name: Memory, capacity: 3 }
  - { name: Disk, capacity: 6 }
origin: Network               # default Origin
policy: lru                   # lru (default) | lfu | fifo
ttl: 10                       # optional, seconds from when the origin returned the entry
requests: [a, b, a, c, { key: d, at: 12 }, a]   # up to 80
```

- A plain key arrives one second after the request before it (the first at 0). `{ key, at }` sets the time; times must not go backwards.
- A lookup tries layers top-down. A hit lower down is copied into every layer above it (promotion); a miss everywhere fetches from the origin and stores the key in every layer. A full layer evicts by policy: LRU the least recently used, LFU the least used (ties go to the least recent), FIFO the first stored, ignoring hits. Counts and recency are per layer.
- With `ttl`, an entry expires `ttl` seconds after the origin returned it, in every layer at once; promotion keeps the original expiry, as an HTTP cache keeps a response's age.
- **Choosing inputs:** with capacity 3, the sequence `[a, b, c, a, d]` evicts `b` under LRU but `a` under FIFO; show the same requests under both policies. For LFU, make one key hot (`a` three times) and then stream new keys past it. For TTL, add one `{ key, at }` after a gap longer than the TTL, so the learner sees a "hot" key miss.

#### `retry`

```yaml
base: 0.5                     # seconds, > 0
factor: 2                     # ≥ 1, default 2
cap: 8                        # ≥ base
attempts: 6                   # total attempts including the first, 1–20
jitter: full                  # none (default) | full | equal | decorrelated
seed: 1                       # whole number ≥ 0, default 1
failUntil: 4                  # the first attempt that succeeds; 0 (default) = none do
breaker: { threshold: 3, cooldown: 5 }   # optional
```

- Attempts take no time. Retry n (from 0) waits `min(cap, base × factorⁿ)`. `full` jitter picks uniformly from 0 to that; `equal` keeps half and randomises the other half; `decorrelated` (AWS's formula) picks from `base` to 3 × the previous wait, capped, and ignores `factor`.
- Random numbers come from SplitMix64, the same generator as DesignKit's `SeededGenerator`, so a seed always gives the same schedule. The delays aren't guaranteed to equal Swift's `Double.random(in:using:)` output.
- The breaker opens after `threshold` failures in a row. While it's open, calls fail at once without reaching the server. `cooldown` seconds after opening it's half-open, and the next call is a trial: success closes it, failure opens it again.
- **Choosing inputs:** for jitter, show `jitter: none` and `jitter: full` with the same base and cap; the summary lists the no-jitter times, which every client that failed together would share. For a breaker, set `failUntil` to an attempt that lands while the breaker is open, and make the cooldown shorter than the later waits. The learner sees a recovered server turned away until the half-open trial. Keep `cap` small enough (about 8) that the timeline stays readable.

#### `rateLimiter`

```yaml
algorithm: token-bucket       # token-bucket | leaky-bucket | fixed-window | sliding-log | sliding-counter
capacity: 5                   # token-bucket and leaky-bucket: whole number 1–100
refillPerSecond: 2            # token-bucket only
# leakPerSecond: 2            # leaky-bucket only
# window: 1                   # fixed-window, sliding-log, sliding-counter: seconds
# limit: 5                    # fixed-window, sliding-log, sliding-counter: whole number 1–100
requests: [0, 0.1, { at: 0.9, count: 5 }, 1.05, 2]   # seconds, in order; { at, count } is a burst; 200 at most
```

- Each algorithm accepts only its own settings, so `limit` on a token bucket fails the build.
- **Token bucket:** starts full, and each request takes a token. Lets a burst of `capacity` through, then the refill rate. Drawn with the token level over time.
- **Leaky bucket:** a queue of `capacity`. Each accepted request leaves `1/leakPerSecond` after the one before it, so output is smooth and bursts wait (or are dropped when the queue is full). Drawn with each request's departure.
- **Fixed window:** windows are `[k·window, (k+1)·window)`; counts reset at each boundary.
- **Sliding log:** keeps the times of allowed requests from the last `window`. Exact.
- **Sliding counter:** the previous window's count × (the share of it still inside the last `window`) + this window's count must be under `limit`.
- Rejected requests never count. The last step reports the busiest span: the most allowed in any `window` for the window algorithms, in any second for the token bucket, and the most that left in any second for the leaky bucket.
- **Choosing inputs:** to show the fixed-window boundary burst, put `{ at: 0.9, count: 5 }` and `{ at: 1.05, count: 5 }` with `window: 1, limit: 5`. The summary reports 10 allowed within one second. Use the same requests with `sliding-log` and `sliding-counter` to show the fix. For a token bucket, open with a burst bigger than `capacity`, then a steady trickle.

#### `hashRing`

```yaml
nodes: [A, B, C]              # 1–8 distinct names across nodes and steps
vnodes: 3                     # points per node, 1–8, default 1
keys: [user:1, user:2, user:3, photo:9]   # distinct, up to 60
steps: [{ add: D }, { remove: B }]        # optional, applied in order
hash: mixed                   # mixed (default) | fnv1a
```

- Node points sit at `hash("A#0")`, `hash("A#1")`, … on a 2³² ring, drawn clockwise from the top. A key belongs to the first point clockwise from `hash(key)`.
- Hashes are FNV-1a 32-bit over UTF-8. FNV-1a barely changes its high bits when only the last character changes, so `user:1`, `user:2`, … land in a clump. The default `mixed` runs MurmurHash3's 32-bit finalizer over the FNV-1a value to spread them. `hash: fnv1a` shows the raw clumping, which is a lesson in itself.
- The steps report how many keys moved and how many `hash % N` (nodes in list order, additions appended) would have moved.
- **Choosing inputs:** use 15–30 keys. With `vnodes: 1` the arcs are visibly uneven; repeat with `vnodes: 4` to show virtual nodes evening out the load. One `add` and one `remove` make the K/N point; the moved-key chips show that only the new node's neighbours give keys up.

#### `estimator`

```yaml
title: Photo uploads, back of the envelope
inputs:                       # up to 12 sliders
  - { id: dau, label: Daily active users, min: 10000, max: 1000000000, value: 5000000, scale: log, unit: users }
  - { id: uploads, label: Photos per user per day, min: 0, max: 20, step: 0.5, value: 2 }
  - { id: photoKB, label: Average photo size, min: 50, max: 5000, step: 50, value: 400, unit: KB }
outputs:                      # up to 16 results, worked out top to bottom
  - { id: perDay, label: Uploads per day, formula: dau * uploads, format: si }
  - { id: qps, label: Average uploads per second, formula: perDay / 86400, format: si, unit: /s }
  - { id: storage, label: New storage per day, formula: perDay * photoKB * 1000, format: bytes, unit: /day }
  - { id: fill, label: Time to fill a 10 TB disk, formula: 10e12 / storage * 86400, format: duration }
```

- `id`s are letters, digits and `_` (not starting with a digit), unique across inputs and outputs, and never a function name.
- **Inputs:** `min < max` and `min ≤ value ≤ max`. With `step` on a linear slider, `value` must be a whole number of steps from `min`. `scale: log` needs `min > 0`. It moves in steps of about 10%, with values rounded to two significant figures, and suits counts that span orders of magnitude.
- **Formulas:** numbers (`12`, `0.5`, `1e6`), `+ - * / % ^` (`^` is power and binds tightest, so `-2^2` is −4), parentheses, and `min max ceil floor round log10 log2 sqrt abs`. A formula may use input ids and the ids of outputs **above** it. The build rejects unknown names, unknown functions, forward references, and a formula that gives ∞ or NaN at the starting values. There's no `eval`, so nothing else is allowed.
- **Formats:** `number` (default; `1,234,567.89`), `si` (`1.23k`, `3.4M`, `5B`, `7T`; billions are B, not G), `bytes` (`512 B`, `1.5 KB` … `PB`, base 1000), `duration` (input in seconds; `250 ms`, `42 s`, `1.5 h`, `3 days`, `2 years`). `unit` is appended after a space, or directly when it starts with `/` (`4 TB/day`).
- **Choosing inputs:** have the formulas build on each other the way you'd do it on a whiteboard (per day → per second → peak → servers), so each card shows one step of the reasoning. Pick ranges where moving a slider crosses an interesting threshold, such as a disk filling in hours rather than years.

## Takeaways and quizzes

Exactly as in the DSA course (`src/dsa/content/AUTHORING.md`, sections "Takeaways" and "Quizzes"), with two extra quiz types that suit design:

```yaml
- id: peak-qps
  type: estimate
  prompt: 10 million daily users each open the app 5 times a day. Roughly how many requests a second at an average moment, if each open makes 4 requests?
  answer: 2300
  unit: requests a second
  within: { factor: 2 }          # or { percent: 20 }; default factor 2
  explain: 10M × 5 × 4 = 200M requests a day; ÷ 86,400 s ≈ 2,300 a second (peak is often 2–3× that).
- id: layers
  type: sort
  prompt: Which layer does each belong to?
  buckets: [Presentation, Domain, Data]
  items:
    - [Feed view model, 0]
    - [Like a post use case, 1]
    - [Posts repository, 2]
    - [URLSession API client, 2]
  explain: View models present, use cases hold the rules, repositories and clients fetch and store.
```

The `bug` type works as "spot the smell", and `order` as "put the steps in order". Prefer questions that make the learner *decide*: which option fits these constraints, what breaks first, what would you ask.

## Practice

Each lesson has practice where it makes sense: a design exercise, an architecture review, a kata, or a mix. Registry entries share these fields: `id`, `kind`, `title`, `difficulty` (warmup · easy · medium · hard · challenge), `patterns` (topic keys from `TOPICS` in `src/dsa/design/data/practice.js`), `lessons` (lessons **of this module**), `minutes`, `lists` (leave empty unless asked).

### Design exercises (`kind: 'design'`)

Registry: also `template` (`feature` for an app or feature, `system` for a backend service, `component`, `migration`; see `src/dsa/design/data/templates.js`), `mock` (true if it makes a good timed mock interview) and a one-sentence `summary`.

The MDX, in this order:

1. `<Brief>`: the scenario, the product's priorities, the scale (numbers!) and constraints. End by saying how long to spend.
2. A ` ```workspace ` block: `template: feature`, optional `omit: [estimates]` to drop sections that don't fit, optional `minutes`.
3. One `<ModelAnswer section="<id>">` per workspace section, in template order. Write the answer a strong senior engineer would give in the time: concrete, opinionated, with the reasoning. Bullets are fine. These stay hidden until the learner reveals them, then appear beside the learner's own text.
4. A ` ```rubric ` block: 3–7 criteria, each `{ id, label, skill, look_for: [...] }`. `skill` is a key of `SKILLS` in `src/dsa/design/data/skills.js`. `look_for` lists what a strong answer covers, specific enough to score against.
5. Optionally `<Pitfalls>`: the usual mistakes, as a list.

The build checks that every workspace section has exactly one model answer.

### Architecture reviews (`kind: 'critique'`)

Registry: also a one-sentence `summary`. The MDX:

1. `<Brief>`: one or two sentences of context, then the code under review in a ` ```swift check ios title="File.swift" ` block (it must compile; realistic, 30–70 lines) or a written design.
2. ` ```workspace ` with `template: critique`.
3. A ` ```findings ` block: 4–9 findings, each `{ id, title, severity: high | medium | low, lines?: "12-18", detail }`. Line numbers count from the first line of the code block. Order by severity. A finding is a real problem with a consequence, not a style preference.
4. `<ReferenceReview>`: how an experienced reviewer would write it up: what matters most, the plan to fix it in small steps, and the tests to add.

### Katas (`kind: 'problem'`)

Registry: also `swiftTest: '<Type>Tests'`. The statement follows the DSA problem format (task, signature in inline code, `## Examples` table, `## Constraints`, `<Hints>`, `## Solutions` with `<Approach>`). In `design-swift`:

- **One namespace per kata:** `public enum <Type>` holding the kata's types (protocols, structs, actors, classes) as nested declarations, so 240 katas never collide.
- **Foundation and Swift Concurrency only**, so `swift test` runs on a Mac. Anything iOS-only stays in lessons.
- **Inject the world:** time (`any Clock<Duration>`, `TestClock` in tests), randomness (`some RandomNumberGenerator`, `SeededGenerator`), the network (`HTTPClient`, `StubHTTPClient`), storage (`InMemoryKeyValueStore`). Tests are deterministic and fast.
- **Stubs fail fast:** they compile, return a placeholder or `throw Unimplemented()`, and never use `fatalError`, `preconditionFailure`, `while true` or sleeps. `design:check` rejects those.
- **Tests:** Swift Testing, `#if SOLUTIONS import Solutions #else import Exercises #endif`, `@Suite struct <Type>Tests`. Test behaviour, not implementation. Async tests use `TestClock.advance(by:)` and `settle()`; give suites that touch shared state `.serialized`.

## Checking your work

```bash
npm run design:compile -- --module <module-id>        # MDX, quizzes, diagrams, exercise blocks
npm run design:examples -- --verify --module <module-id>
npm run design:check -- --module <module-id>
cd design-swift && swift build --scratch-path <your own path>
swift test --scratch-path <your own path> --filter <Type>Tests                  # must fail, without crashing
swift test --scratch-path <your own path> -Xswiftc -DSOLUTIONS --filter <Type>Tests   # must pass
```

Exercise and review files are checked by `design:compile` and their code by a full `npm run design:examples -- --verify`.
