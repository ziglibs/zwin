const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();
    const target = b.standardTargetOptions(.{});

    const exe = b.addExecutable("demo", "src/demo.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();

    exe.linkLibC();
    exe.linkSystemLibraryName("user32");
    exe.linkSystemLibraryName("gdi32");

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());

    const test_step = b.step("demo", "Run demo");
    test_step.dependOn(&run_cmd.step);
}
