pub const Location = enum {
    left,
    right,

    pub var local: Location = undefined;
    pub var remote: Location = undefined;

    pub fn set_local(location: Location) void {
        log.info("Operating as {s} side", .{ @tagName(location) });
        local = location;
        remote = switch (location) {
            .left => .right,
            .right => .left,
        };
    }

    const log = std.log.scoped(.Location);
};

pub const Key_ID = struct {
    location: Location,
    row: u8,
    col: u8,

    pub fn format(self: Key_ID, fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;
        try writer.print("{s} R{} C{}", .{ @tagName(self.location), self.row, self.col });
    }
};

pub const Track = struct {
    x: i16 = 0,
    y: i16 = 0,
    z: u8 = 0,

    pub fn format(self: Track, fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;
        try writer.print("({}, {}) [{}]", .{ self.x, self.y, self.z });
    }
};

const matrix = @import("matrix.zig");
const config = @import("config");
const std = @import("std");
