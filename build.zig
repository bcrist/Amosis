var builder: *std.Build = undefined;
var generate_scad_exe: *std.Build.Step.Compile = undefined;

pub fn build(b: *std.Build) void {
    builder = b;
    generate_scad_exe = b.addExecutable(.{
        .name = "generate_scad",
        .root_source_file = b.path("case/generate_scad.zig"),
        .target = b.host,
        .optimize = .ReleaseFast,
    });

    build_stl("left");
    build_stl("right");

    const chip = rpi.rp2040(rpi.zd25q80c);

    const boot2_object = rpi.add_boot2_object(b, .{
        .source = .{ .module = b.dependency("microbe-rpi", .{}).module("boot2-default") },
        .chip = chip,
    });

    const exe = microbe.add_executable(b, .{
        .name = "firmware.elf",
        .root_source_file = b.path("firmware/main.zig"),
        .chip = chip,
        .sections = rpi.default_rp2040_sections(),
        .optimize = b.standardOptimizeOption(.{ .preferred_optimize_mode = .ReleaseSmall }),
    });
    exe.addObject(boot2_object);

    const install_elf = b.addInstallArtifact(exe, .{});
    const copy_elf = b.addInstallBinFile(exe.getEmittedBin(), "firmware.elf");

    const bin = exe.addObjCopy(.{ .format = .bin });
    const checksummed_bin = rpi.boot2_checksum(b, bin.getOutput());
    const install_bin = b.addInstallBinFile(checksummed_bin, "firmware.bin");

    const uf2 = microbe.add_bin_to_uf2(b, "firmware.uf2", &.{
        .{
            .path = checksummed_bin,
            .family = .rp2040,
        },
    });
    const install_uf2 = b.addInstallBinFile(uf2, "firmware.uf2");

    b.getInstallStep().dependOn(&install_elf.step);
    b.getInstallStep().dependOn(&copy_elf.step);
    b.getInstallStep().dependOn(&install_bin.step);
    b.getInstallStep().dependOn(&install_uf2.step);
}

fn build_stl(name: []const u8) void {
    const scad_filename = std.fmt.allocPrint(builder.allocator, "{s}.scad", .{ name }) catch @panic("OOM");
    const stl_filename = std.fmt.allocPrint(builder.allocator, "{s}.stl", .{ name }) catch @panic("OOM");

    var generate_scad = builder.addRunArtifact(generate_scad_exe);
    generate_scad.addArg(name);
    const scad = generate_scad.addOutputFileArg(scad_filename);

    const install_scad = builder.addInstallFile(scad, scad_filename);
    builder.getInstallStep().dependOn(&install_scad.step);

    var convert = builder.addSystemCommand(&.{ "openscad", "--enable", "manifold", "-o" });
    const stl = convert.addOutputFileArg(stl_filename);
    convert.addFileArg(scad);

    const install_stl = builder.addInstallFile(stl, stl_filename);
    builder.getInstallStep().dependOn(&install_stl.step);
}

const microbe = @import("microbe");
const rpi = @import("microbe-rpi");
const std = @import("std");
