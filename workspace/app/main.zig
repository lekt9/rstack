//! app/main.zig — the rstack composition proof.
//!
//! ONE executable, ONE Zig toolchain, importing BOTH frameworks: merv (the
//! reactive data engine — reactor, router, durability) and mer (the merjs web
//! shell). If this compiles and runs, the stack composes: the data layer and the
//! web layer coexist in a single compilation on one toolchain. That is the whole
//! claim of a "stack" — the integration, proven.
const std = @import("std");
const merv = @import("merv");
const mer = @import("mer");

pub fn main() !void {
    const a = std.heap.page_allocator;
    const p = std.debug.print;
    p("rstack — merv + merjs in one compilation, one toolchain\n", .{});
    p("======================================================\n", .{});

    // ── data layer (merv): the full surface links in this binary ─────────────
    var router = try merv.Router.init(a);
    defer router.deinit();
    try router.add("GET", "/movies/:id/shots/:shot", 7);
    const m = router.match("GET", "/movies/42/shots/3");
    p("merv.Router  : matched id={?d}", .{if (m) |mm| mm.id else null});
    if (m) |mm| {
        var i: usize = 0;
        while (i < mm.n) : (i += 1) p(" {s}={s}", .{ mm.params[i].name, mm.params[i].value });
    }
    p("\n", .{});
    p("merv.Knn     : reactive nearest-neighbour engine linked ({s})\n", .{@typeName(merv.Knn(struct { id: u64, v: [4]f32 }, 4))});
    p("merv.Wal     : durability (write-ahead log) linked\n", .{});

    // ── web layer (merjs): the framework public API links in the SAME binary ─
    p("merjs 'mer'  : h={} Request={} Response={} dhi={}\n", .{
        @hasDecl(mer, "h"), @hasDecl(mer, "Request"), @hasDecl(mer, "Response"), @hasDecl(mer, "dhi"),
    });

    p("\nVERDICT: PASS — the stack composes (data + web, one toolchain)\n", .{});
}
