var keys_pressed: [matrix.row_count]matrix.Row_Bitmap = .{ 0 } ** matrix.row_count;

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
        'K' => if (uart.get_rx_available_count() >= matrix.row_count + 1) {
            _ = try r.readByte();
            var buf: [matrix.row_count]u8 = undefined;
            _ = try r.readAll(&buf);
            log.debug("received keys: {X:0>2} {X:0>2} {X:0>2}", .{
                buf[0],
                buf[1],
                buf[2],
            });
            logic.process_keys(Location.remote, &keys_pressed, u8, &buf);
            return true;
        } else {
            log.debug("waiting for completion of keys command (have {} bytes)", .{ uart.get_rx_available_count() });
        },
        'T' => if (uart.get_rx_available_count() >= 6) {
            _ = try r.readByte();
            const z = try r.readByte();
            const x = try r.readInt(i16, .little);
            const y = try r.readInt(i16, .little);
            const t: Track = .{ .x = x, .y = y, .z = z };
            log.debug("received track {}", .{ t });
            logic.set_track(Location.remote, t);
            return true;
        } else {
            log.debug("waiting for completion of track command (have {} bytes)", .{ uart.get_rx_available_count() });
        },
        'U' => {
            _ = try r.readByte();
            logic.on_usb_state_changed(Location.remote, true);
        },
        'u' => {
            _ = try r.readByte();
            logic.on_usb_state_changed(Location.remote, false);
        },
        'L' => {
            _ = try r.readByte();
            logic.on_received_caps_lock(true);
        },
        'l' => {
            _ = try r.readByte();
            logic.on_received_caps_lock(false);
        },
        'S' => {
            _ = try r.readByte();
            logic.on_received_scroll_lock(true);
        },
        's' => {
            _ = try r.readByte();
            logic.on_received_scroll_lock(false);
        },
        'N' => {
            _ = try r.readByte();
            logic.on_received_num_lock(true);
        },
        'n' => {
            _ = try r.readByte();
            logic.on_received_num_lock(false);
        },
        else => {
            _ = r.readByte() catch {};
            log.err("Unrecognized link command: {X:0>2}", .{ command });
            return true;
        },
    }
    return false;
}

pub fn send_caps_lock(active: bool) void {
    log.info("sending caps lock: {} ({} tx bytes available)", .{
        active,
        uart.get_tx_available_count(),
    });
    uart.writer().writeByte(if (active) 'L' else 'l') catch |err| {
        log.err("Error sending caps lock change: {s}", .{ @errorName(err) });
    };
}

pub fn send_num_lock(active: bool) void {
    log.info("sending num lock: {} ({} tx bytes available)", .{
        active,
        uart.get_tx_available_count(),
    });
    uart.writer().writeByte(if (active) 'N' else 'n') catch |err| {
        log.err("Error sending num lock change: {s}", .{ @errorName(err) });
    };
}

pub fn send_scroll_lock(active: bool) void {
    log.info("sending scroll lock: {} ({} tx bytes available)", .{
        active,
        uart.get_tx_available_count(),
    });
    uart.writer().writeByte(if (active) 'S' else 's') catch |err| {
        log.err("Error sending scroll lock change: {s}", .{ @errorName(err) });
    };
}

pub fn send_usb_state_changed(active: bool) void {
    log.info("sending usb state: {} ({} tx bytes available)", .{
        active,
        uart.get_tx_available_count(),
    });
    uart.writer().writeByte(if (active) 'U' else 'u') catch |err| {
        log.err("Error sending usb state change: {s}", .{ @errorName(err) });
    };
}

pub fn send_keys(keys: *const[matrix.row_count]matrix.Row_Bitmap) void {
    send_keys_internal(keys) catch |err| {
        log.err("Error sending keys: {s}", .{ @errorName(err) });
    };
}

fn send_keys_internal(keys: *const[matrix.row_count]matrix.Row_Bitmap) !void {
    log.debug("sending keys: {X:0>2} {X:0>2} {X:0>2} ({} tx bytes available)", .{
        keys[0],
        keys[1],
        keys[2],
        uart.get_tx_available_count(),
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
    log.debug("sending track {} ({} tx bytes available)", .{
        t, uart.get_tx_available_count(),
    });
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
const matrix = @import("matrix.zig");
const util = @import("util.zig");
const logic = @import("logic.zig");
const chip = @import("chip");
const microbe = @import("microbe");
const std = @import("std");
