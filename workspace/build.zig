//! build.zig — the rstack workspace: one build graph, both frameworks.
//!
//! Builds a single executable that imports merv (reactive data) and mer (merjs
//! web shell) together, on one Zig toolchain (0.15.1 — the ecosystem version;
//! merv also builds on 0.16). For a published app, declare merv/merjs as
//! build.zig.zon git dependencies; here they're referenced by local path so the
//! composition is verifiable in-repo.
const std = @import("std");

// Local checkouts (override with -Dmerv= / -Dmerjs= if elsewhere).
const MERV_DEFAULT = "/Users/lekt9/Projects/oss/merv/src/merv.zig";
const MER_DEFAULT = "/Users/lekt9/Projects/oss/merjs/src/mer.zig";

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const merv_path = b.option([]const u8, "merv", "path to merv/src/merv.zig") orelse MERV_DEFAULT;
    const mer_path = b.option([]const u8, "merjs", "path to merjs/src/mer.zig") orelse MER_DEFAULT;

    const merv = b.addModule("merv", .{ .root_source_file = .{ .cwd_relative = merv_path } });
    const mer = b.addModule("mer", .{ .root_source_file = .{ .cwd_relative = mer_path } });
    mer.addImport("mer", mer); // merjs's transitive @import("mer") resolves to itself

    const exe = b.addExecutable(.{
        .name = "rstack-app",
        .root_module = b.createModule(.{
            .root_source_file = b.path("app/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    exe.root_module.addImport("merv", merv);
    exe.root_module.addImport("mer", mer);
    b.installArtifact(exe);

    const run = b.addRunArtifact(exe);
    b.step("run", "Run the rstack composition proof").dependOn(&run.step);
}
