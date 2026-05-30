<h1 align="center">rstack</h1>

<h3 align="center">A zero-Node, Zig-native full-stack — in the shape of the T3 stack.</h3>

<p align="center">
  Web shell · reactive data · validation · persistence · routing — composed,
  not glued. One schema, types by construction, from the database to the browser.
</p>

---

## What a stack is (and why)

A *stack* is not a template and not a pile of libraries. It is an **opinionated,
modular composition** where the **integration is the product**. The
[T3 stack](https://create.t3.gg) (`create-t3-app`) is the reference: Next.js +
TypeScript + tRPC + Tailwind + Prisma, scaffolded so the pieces compose into
**end-to-end typesafety** — the value is that a column added to the database
flows, type-checked, all the way to the React component. You pick the pieces; the
scaffolder wires the opinions.

`create-t3-app` proves the form: an interactive CLI collects choices, copies a
**base template**, then runs **modular installers** (one per package) that add
deps and wire config so the selected pieces work together. rstack copies that
shape exactly — base template + per-layer installers — for a different ecosystem.

## rstack's through-line

**One Zig schema flows DB → reactive engine → API → SSR → WASM client, with zero
Node and zero impedance.** Where T3 buys end-to-end *typesafety*, rstack buys
end-to-end *one-language, one-wire*: the same Zig types and the same binary wire
format on the server and in the browser (Zig→WASM), so there is no serialization
seam to keep in sync.

## The layers (T3 → rstack)

| T3 layer | rstack layer | what it is |
|---|---|---|
| Next.js (routing/SSR/client) | **[merjs](https://github.com/justrach/merjs)** | Next.js-style web framework in Zig — file routing, SSR, WASM client, Cloudflare Workers, 0 `node_modules` |
| tRPC + Prisma (typed data) | **[merv](https://github.com/lekt9/merv)** | reactive live-query engine — subscriptions push row-level deltas; reactive nearest-neighbour for AI/multimodal |
| Zod (validation) | **[dhi](https://github.com/justrach/dhi)** | data validation via Zig + SIMD WASM |
| Prisma DB | **[turbodb](https://github.com/justrach/turbodb)** / **[sqlnano](https://github.com/justrach/sqlnano)** | embedded store — mmap + WAL + B-tree + MVCC / SQLite-compatible |
| API server | **[turboapi-core](https://github.com/justrach/turboAPI)** | radix-trie router (43.5M lookups/s) + HTTP core |
| `create-t3-app` | **`create-rstack`** | the scaffolder in this repo |

## The integration, proven

The load-bearing seam — a frontend consuming a reactive query — is real and
checked end to end. merv's reactive client compiles to `wasm32-freestanding`
(exactly how merjs ships client logic); a native Zig server emits a binary delta
frame; the WASM client decodes it in the browser and updates a live view. See
[`merv/tools/wasm_check.mjs`](https://github.com/lekt9/merv): native server frame
→ WASM client view in a JS runtime, **one binary wire format, no JSON**.

```
schema.zig ── one source of types
   │
   ├─▶ merv reactor (server)   subscribe → row-level delta → wire
   └─▶ merv client (Zig→WASM)  decode delta → live view → merjs DOM
```

## Quick start

```bash
./create-rstack my-app          # scaffold (interactive), or:
./create-rstack my-app --data --web --no-git
cd my-app && zig build
```

`create-rstack` emits a base project, then runs the per-layer installers you
selected (`data` = merv reactive layer + WASM client, `web` = merjs shell,
`valid` = dhi). The shape mirrors `create-t3-app`: base template + modular
installers.

## Status — honest

- ✅ **Reactive data layer (merv)** — reactor + reactive nearest-neighbour,
  bench-gated; WASM client proven in a JS runtime.
- ✅ **The seam** — server delta frame → WASM client view, one wire, verified.
- ✅ **`create-rstack`** — scaffolds the rstack project shape (base + installers).
- ✅ **Single-toolchain workspace** — both frameworks build on **Zig 0.15.1**
  with zero porting (merv also builds on 0.16, so it spans both). `workspace/`
  is the proof: one executable imports **both** `merv` (reactor + router + WAL)
  and merjs's `mer` module and compiles+runs on one toolchain. `cd workspace &&
  zig build run`.
- ✅ **Durability** — merv write-ahead log + crash-safe recovery (`merv:
  zig build walcheck`).
- ✅ **Routing (turboAPI merge)** — radix/segment router with params + wildcard,
  method-indexed (`merv: zig build routercheck`).
- ⏳ **Schema codegen + app cutover** — generate the per-schema codec from a
  declarative `schema.zig`, then port a real app's schema/queries. The unreel
  app cutover is a separate private arc (its live beta is untouched).

MIT. Built on the work of [@justrach](https://github.com/justrach) (merjs, dhi,
turboAPI, turbodb) and [merv](https://github.com/lekt9/merv).
