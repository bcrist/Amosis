var keys_pressed: [6]u6 = .{ 0 } ** 6;

pub fn init() void {
    uart = @TypeOf(uart).init();
    uart.start();
    log.info("initialized", .{});
}

pub fn handle_interrupt() void {
    uart.handle_interrupt();
}

pub fn update() void {
    while (true) {
        if (uart.peek_one() catch |err| c: {
            log.err("{s}", .{ @errorName(err) });
            _ = uart.reader().readByte() catch {};
            break :c null;
        }) |command| {
            if (!(handle_command(command) catch |err| b: {
                log.err("Error processing command {X:0>2}: {s}", .{ command, @errorName(err) });
                if (uart.can_read()) {
                    _ = uart.reader().readByte() catch {};
                }
                break :b true;
            })) return;
        } else return;
    }
}

fn handle_command(command: u8) !bool {
    var r = uart.reader();
    switch (command) {
        'K' => if (uart.get_rx_available_count() >= 7) {
            _ = try r.readByte();
            var buf: [6]u8 = undefined;
            _ = try r.readAll(&buf);
            log.debug("received keys: {X:0>2} {X:0>2} {X:0>2} {X:0>2} {X:0>2} {X:0>2}", .{
                buf[0],
                buf[1],
                buf[2],
                buf[3],
                buf[4],
                buf[5],
            });
            logic.process_keys(Location.remote, &keys_pressed, u8, &buf);
            return true;
        },
        'T' => if (uart.get_rx_available_count() >= 6) {
            _ = try r.readByte();
            const z = try r.readByte();
            const x = try r.readInt(i16, .little);
            const y = try r.readInt(i16, .little);
            log.debug("received track {}, {}: {}", .{ x, y, z });
            logic.set_track(Location.remote, .{ .x = x, .y = y, .z = z });
            return true;
        },
        else => {
            _ = r.readByte() catch {};
            log.err("Unrecognized link command: {X:0>2}", .{ command });
            return true;
        },
    }
    return false;
}

pub fn send_keys(keys: []u6) void {
    send_keys_internal(keys) catch |err| {
        log.err("Error sending keys: {s}", .{ @errorName(err) });
    };
}

fn send_keys_internal(keys: []u6) !void {
    log.debug("sending keys: {X:0>2} {X:0>2} {X:0>2} {X:0>2} {X:0>2} {X:0>2}", .{
        keys[0],
        keys[1],
        keys[2],
        keys[3],
        keys[4],
        keys[5],
    });
    var w = uart.writer();
    try w.writeByte('K');
    for (keys) |b| {
        try w.writeByte(b);
    }
}

pub fn send_track(t: Track) void {
    send_track_internal(t) catch |err| {
        log.err("Error sending track: {s}", .{ @errorName(err) });
    };
}

fn send_track_internal(t: Track) !void {
    log.debug("sending track {}, {}: {}", .{ t.x, t.y, t.z });
    var w = uart.writer();
    try w.writeByte('T');
    try w.writeByte(t.z);
    try w.writeInt(i16, t.x, .little);
    try w.writeInt(i16, t.y, .little);
}

pub var uart: chip.UART(.{
    .baud_rate = 1_000_000,
    .tx = .GPIO4,
    .rx = .GPIO5,
    .tx_buffer_size = 256,
    .rx_buffer_size = 256,
}) = undefined;

const log = std.log.scoped(.link);

const Location = util.Location;
const Track = util.Track;
const util = @import("util.zig");
const logic = @import("logic.zig");
const chip = @import("chip");
const microbe = @import("microbe");
const std = @import("std");
