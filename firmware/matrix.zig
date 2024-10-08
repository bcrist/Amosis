/// Handles scanning and debouncing of the key and status LED matrix using hardware PWM channels.
/// `leds` can be updated at any time to change the color of the status LEDs.

pub const col_count = 7;
pub const row_count = 3;
pub const Row_Bitmap = std.meta.Int(.unsigned, col_count);

// pwm clock = 1.5151 MHz
// interrupt frequency = 3.03 kHz
// full matrix refresh frequency = 1.01 kHz
const clock_divisor = 66;
const max_count = 500;

const key_press_debounce: u8 = 0;
const key_press_cooldown: u8 = 6;
const key_release_debounce: u8 = 3;
const key_release_cooldown: u8 = 3;

const lhs = struct {
    const Cols = microbe.bus.Bus(&.{ .GPIO18, .GPIO17, .GPIO16, .GPIO15, .GPIO14, .GPIO13, .GPIO12 }, .{
        .name = "LHS Cols",
        .gpio_config = .{
            .maintenance = .pull_down,
            .input_enabled = true,
        },
    });

    const Rows = microbe.bus.Bus(&.{ .GPIO21, .GPIO20, .GPIO19 }, .{
        .name = "LHS Rows",
        .gpio_config = .{
            .speed = .slow,
            .strength = .@"2mA",
        },
    });

    comptime {
        std.debug.assert(Cols.State == Row_Bitmap);
        std.debug.assert(@bitSizeOf(Rows.State) == row_count);
    }
};

const rhs = struct {
    const Cols = microbe.bus.Bus(&.{ .GPIO15, .GPIO14, .GPIO13, .GPIO12, .GPIO11, .GPIO10, .GPIO9 }, .{
        .name = "RHS Cols",
        .gpio_config = .{
            .maintenance = .pull_down,
            .input_enabled = true,
        },
    });

    const Rows = microbe.bus.Bus(&.{ .GPIO18, .GPIO17, .GPIO16 }, .{
        .name = "RHS Rows",
        .gpio_config = .{
            .speed = .slow,
            .strength = .@"2mA",
        },
    });

    comptime {
        std.debug.assert(Cols.State == Row_Bitmap);
        std.debug.assert(@bitSizeOf(Rows.State) == row_count);
    }
};

const Sample_Interrupt = chip.PWM(.{
    .name = "Matrix Sample Interrupt",
    .channel = .ch7,
    .output = null,
    .clock = .{ .divisor_16ths = clock_divisor * 16 },
    .max_count = max_count,
});

const Key_State = union(enum) {
    idle,
    debounce: u8,
    cooldown: u8,

    pub fn start_debounce(self: *Key_State, row: usize, col: usize, pressed: bool) void {
        const cycles = if (pressed) key_press_debounce else key_release_debounce;
        if (cycles == 0) {
            self.start_cooldown(row, col, pressed);
        } else {
            self.* = .{ .debounce = cycles - 1 };
        }
    }

    pub fn start_cooldown(self: *Key_State, row: usize, col: usize, pressed: bool) void {
        if (pressed) {
            keys_pressed[row] |= @as(Row_Bitmap, 1) << @intCast(col);
            log.debug("R{} C{} down", .{ row, col });
        } else {
            keys_pressed[row] &= ~(@as(Row_Bitmap, 1) << @intCast(col));
            log.debug("R{} C{} up", .{ row, col });
        }
        keys_modified = true;
        const cycles = if (pressed) key_press_cooldown else key_release_cooldown;
        if (cycles == 0) {
            self.* = .idle;
        } else {
            self.* = .{ .cooldown = cycles - 1 };
        }
    }
};

var current_row: u8 = 0;
var row_idle: [row_count]bool = .{false} ** row_count;
var key_state: [row_count][col_count]Key_State = .{.{.idle} ** col_count} ** row_count;
var prev_keys_pressed: [row_count]Row_Bitmap = .{0} ** row_count;
var keys_pressed: [row_count]Row_Bitmap = .{0} ** row_count;
var keys_modified: bool = false;

pub fn init() void {
    if (Location.local == .left) {
        lhs.Cols.init();
        lhs.Cols.set_output_enable(false);

        lhs.Rows.init();
        lhs.Rows.set_output_enable(true);
    } else {
        rhs.Cols.init();
        rhs.Cols.set_output_enable(false);

        rhs.Rows.init();
        rhs.Rows.set_output_enable(true);
    }

    Sample_Interrupt.init();

    next_row();

    chip.peripherals.PWM.irq.raw.clear_bits(.{ .ch7 = true });
    chip.peripherals.PWM.irq.enable.modify(.{ .ch7 = true });

    chip.peripherals.NVIC.interrupt_clear_pending.write(.{ .PWM_IRQ_WRAP = true });
    chip.peripherals.NVIC.interrupt_set_enable.write(.{ .PWM_IRQ_WRAP = true });

    chip.peripherals.PWM.enable.set_bits(.{ .ch7 = true });
    log.info("initialized", .{});
}

pub fn update() void {
    if (keys_modified) {
        chip.peripherals.NVIC.interrupt_clear_enable.write(.{ .PWM_IRQ_WRAP = true });
        defer chip.peripherals.NVIC.interrupt_set_enable.write(.{ .PWM_IRQ_WRAP = true });
        link.send_keys(&keys_pressed);
        logic.process_keys(Location.local, &prev_keys_pressed, Row_Bitmap, &keys_pressed);
        keys_modified = false;
    }
}

pub fn handle_interrupt() void {
    chip.peripherals.PWM.irq.raw.clear_bits(.{ .ch7 = true });

    const row = current_row;
    const raw_old_keys: Row_Bitmap = keys_pressed[row];
    const raw_new_keys: Row_Bitmap = switch (Location.local) {
        .left => lhs.Cols.read(),
        .right => rhs.Cols.read(),
    };

    defer next_row();

    if (raw_old_keys == raw_new_keys and row_idle[row]) return;

    var all_idle = true;
    for (0.., &key_state[row]) |col, *state| {
        log.debug("checking col {}", .{ col });
        const old_bit: u1 = @truncate(raw_old_keys >> @intCast(col));
        const new_bit: u1 = @truncate(raw_new_keys >> @intCast(col));
        const old = old_bit == 1;
        const new = new_bit == 1;

        switch (state.*) {
            .idle => if (new != old) {
                state.start_debounce(row, col, new);
            },
            .debounce => |count| {
                if (new == old) {
                    state.* = .idle;
                } else if (count > 0) {
                    state.* = .{ .debounce = count - 1 };
                } else {
                    state.start_cooldown(row, col, new);
                }
            },
            .cooldown => |count| {
                if (count > 0) {
                    state.* = .{ .cooldown = count - 1 };
                } else if (new != old) {
                    state.start_debounce(row, col, new);
                } else {
                    state.* = .idle;
                }
            },
        }

        if (state.* != .idle) {
            all_idle = false;
        }
    }
    row_idle[row] = all_idle;
}

fn next_row() void {
    const new_row: u8 = if (current_row == 2) 0 else current_row + 1;
    current_row = new_row;

    var row_mask: u32 = 1;
    row_mask <<= @intCast(new_row);

    switch (Location.local) {
        .left => lhs.Rows.modify(@intCast(row_mask)),
        .right => rhs.Rows.modify(@intCast(row_mask)),
    }
}

const log = std.log.scoped(.matrix);

const Location = util.Location;
const Key_ID = util.Key_ID;
const util = @import("util.zig");
const link = @import("link.zig");
const logic = @import("logic.zig");
const chip = @import("chip");
const microbe = @import("microbe");
const std = @import("std");
