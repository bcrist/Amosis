pub const Location = enum {
    left,
    right,

    pub const local: Location = if (is_left()) .left else .right;
    pub const remote: Location = if (is_left()) .right else .left;
};

pub const Key_ID = struct {
    location: Location,
    row: u8,
    col: u8,
};

pub const Track = struct {
    x: i16 = 0,
    y: i16 = 0,
    z: u8 = 0,
};

pub const RGB = struct {
    r: u16 = 0,
    g: u16 = 0,
    b: u16 = 0,
};

pub fn set_led(location: Location, row: u8, color: RGB) void {
    if (location == Location.local) {
        matrix.leds[row] = color;
    }
}

pub inline fn is_left() bool {
    return comptime std.mem.eql(u8, @tagName(config.side), "left");
}

const matrix = @import("matrix.zig");
const config = @import("config");
const std = @import("std");
