/// Handles scanning and debouncing of the key and status LED matrix using hardware PWM channels.
/// `leds` can be updated at any time to change the color of the status LEDs.
/// 
/// Layout: (RC)
///                   Left                           Right
///               (02)(03)(04)                         (04)(03)(02)
///  (00) (10)(11)(12)(13)(14) (43)               (43) (14)(13)(12)(11)(10) (00)
///  (01) (20)(21)(22)(23)(24) (44)               (44) (24)(23)(22)(21)(20) (01)
///       (30)(31)(32)(33)(34) (45)               (45) (34)(33)(32)(31)(30)
///                         (42)(41)(40)     (40)(41)(42)

// pwm clock = 1.5151 MHz
// pwm frequency = 1.509 kHz
// interrupt frequency = 3.018 kHz
// full matrix refresh frequency = 251.5 Hz
const clock_divisor = 66;
const max_count = 1010;
const row_count = 1000;

const key_press_debounce: u8 = 0;
const key_press_cooldown: u8 = 6;
const key_release_debounce: u8 = 3;
const key_release_cooldown: u8 = 3;

const Cols = microbe.bus.Bus(&.{
    .GPIO8,
    .GPIO9,
    .GPIO10,
    .GPIO11,
    .GPIO12,
    .GPIO13,
}, .{
    .gpio_config = .{
        .maintenance = .pull_down,
        .input_enabled = true,
    },
});

const Row_0 = chip.PWM(.{
    .output = .GPIO14,
    .clock = .{ .divisor_16ths = clock_divisor * 16 },
    .max_count = max_count,
});
const Row_1 = chip.PWM(.{
    .output = .GPIO15,
    .clock = .{ .divisor_16ths = clock_divisor * 16 },
    .max_count = max_count,
});
const Row_2 = chip.PWM(.{
    .output = .GPIO16,
    .clock = .{ .divisor_16ths = clock_divisor * 16 },
    .max_count = max_count,
});
const Row_3 = chip.PWM(.{
    .output = .GPIO17,
    .clock = .{ .divisor_16ths = clock_divisor * 16 },
    .max_count = max_count,
});
const Row_4 = chip.PWM(.{
    .output = .GPIO18,
    .clock = .{ .divisor_16ths = clock_divisor * 16 },
    .max_count = max_count,
});
const Row_5 = chip.PWM(.{
    .output = .GPIO19,
    .clock = .{ .divisor_16ths = clock_divisor * 16 },
    .max_count = max_count,
});

const Blue_LED = chip.PWM(.{
    .output = .GPIO20,
    .polarity = .low_below_threshold,
    .clock = .{ .divisor_16ths = clock_divisor * 16 },
    .max_count = max_count,
});
const Red_LED = chip.PWM(.{
    .output = .GPIO21,
    .polarity = .low_below_threshold,
    .clock = .{ .divisor_16ths = clock_divisor * 16 },
    .max_count = max_count,
});
const Green_LED = chip.PWM(.{
    .output = .GPIO22,
    .polarity = .low_below_threshold,
    .clock = .{ .divisor_16ths = clock_divisor * 16 },
    .max_count = max_count,
});

const Sample_Interrupt = chip.PWM(.{
    .channel = .ch4,
    .output = null,
    .clock = .{ .divisor_16ths = clock_divisor * 16 },
    .max_count = @divExact(max_count, 2),
});

const Key_State = union (enum) {
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
            keys_pressed[row] |= @as(u6, 1) << @intCast(col);
            log.debug("R{} C{} down", .{ row, col });
        } else {
            keys_pressed[row] &= ~(@as(u6, 1) << @intCast(col));
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
var row_idle: [6]bool = .{ false } ** 6;
var key_state: [6][6]Key_State = .{ .{ .idle } ** 6 } ** 6;
var prev_keys_pressed: [6]u6 = .{ 0 } ** 6;
var keys_pressed: [6]u6 = .{ 0 } ** 6;
var keys_modified: bool = false;

pub var leds: [6]RGB = .{ .{} } ** 6;

pub fn init() void {
    Cols.init();
    Cols.set_output_enable(false);

    Row_0.init();
    Row_1.init();
    Row_2.init();
    Row_3.init();
    Row_4.init();
    Row_5.init();

    Row_0.set_threshold(0);
    Row_1.set_threshold(0);
    Row_2.set_threshold(0);
    Row_3.set_threshold(0);
    Row_4.set_threshold(0);
    Row_5.set_threshold(0);

    Blue_LED.init();
    Red_LED.init();
    Green_LED.init();

    Sample_Interrupt.init();

    next_row();

    chip.peripherals.PWM.irq.raw.clear_bits(.{ .ch4 = true });
    chip.peripherals.PWM.irq.enable.modify(.{ .ch4 = true });

    chip.peripherals.NVIC.interrupt_clear_pending.write(.{ .PWM_IRQ_WRAP = true });
    chip.peripherals.NVIC.interrupt_set_enable.write(.{ .PWM_IRQ_WRAP = true });

    comptime var enable_mask: chip.reg_types.pwm.Channel_Bitmap = .{};
    enable_mask.ch4 = true;
    @field(enable_mask, @tagName(Row_0.channel)) = true;
    @field(enable_mask, @tagName(Row_1.channel)) = true;
    @field(enable_mask, @tagName(Row_2.channel)) = true;
    @field(enable_mask, @tagName(Row_3.channel)) = true;
    @field(enable_mask, @tagName(Row_4.channel)) = true;
    @field(enable_mask, @tagName(Row_5.channel)) = true;

    @field(enable_mask, @tagName(Blue_LED.channel)) = true;
    @field(enable_mask, @tagName(Green_LED.channel)) = true;
    @field(enable_mask, @tagName(Red_LED.channel)) = true;

    chip.peripherals.PWM.enable.set_bits(enable_mask);
    log.info("initialized", .{});
}

pub fn update() void {
    if (keys_modified) {
        chip.peripherals.NVIC.interrupt_clear_enable.write(.{ .PWM_IRQ_WRAP = true });
        defer chip.peripherals.NVIC.interrupt_set_enable.write(.{ .PWM_IRQ_WRAP = true });
        link.send_keys(&keys_pressed);
        logic.process_keys(Location.local, &prev_keys_pressed, u6, &keys_pressed);
        keys_modified = false;
    }
}

pub fn handle_interrupt() void {
    chip.peripherals.PWM.irq.raw.clear_bits(.{ .ch4 = true });

    const ch0_count = chip.peripherals.PWM.channel[@intFromEnum(Row_0.channel)].counter.read().count;
    if (ch0_count + 1 < max_count / 2) return;

    const row = current_row;
    const raw_old_keys = keys_pressed[row];
    const raw_new_keys = Cols.read();

    defer next_row();

    if (raw_old_keys == raw_new_keys and row_idle[row]) return;

    var all_idle = true;
    for (0.., &key_state[row]) |col, *state| {
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
    const new_row: u8 = if (current_row == 5) 0 else current_row + 1;
    current_row = new_row;

    switch (new_row) {
        0 => {
            Row_5.set_threshold(0);
            Row_0.set_threshold(row_count);
        },
        1 => {
            Row_0.set_threshold(0);
            Row_1.set_threshold(row_count);
        },
        2 => {
            Row_1.set_threshold(0);
            Row_2.set_threshold(row_count);
        },
        3 => {
            Row_2.set_threshold(0);
            Row_3.set_threshold(row_count);
        },
        4 => {
            Row_3.set_threshold(0);
            Row_4.set_threshold(row_count);
        },
        5 => {
            Row_4.set_threshold(0);
            Row_5.set_threshold(row_count);
        },
        else => unreachable,
    }

    const rgb = leds[new_row];
    Red_LED.set_threshold(rgb.r);
    Green_LED.set_threshold(rgb.g);
    Blue_LED.set_threshold(rgb.b);
}

const log = std.log.scoped(.matrix);

const Location = util.Location;
const Key_ID = util.Key_ID;
const RGB = util.RGB;
const util = @import("util.zig");
const link = @import("link.zig");
const logic = @import("logic.zig");
const chip = @import("chip");
const microbe = @import("microbe");
const std = @import("std");
