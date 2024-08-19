/// Handles status LEDs using hardware PWM channels.

// pwm clock = 1.5151 MHz
// pwm frequency = 379 Hz
const clock_divisor = 66;
const max_count = 4000;

pub const RGB = struct {
    r: u16 = 0,
    g: u16 = 0,
    b: u16 = 0,
};

const lhs = struct {
    const Red_LED_Top = chip.PWM(.{
        .output = .GPIO6, // ch3a
        .polarity = .low_below_threshold,
        .clock = .{ .divisor_16ths = clock_divisor * 16 },
        .max_count = max_count,
    });
    const Green_LED_Top = chip.PWM(.{
        .output = .GPIO7, // ch3b
        .polarity = .low_below_threshold,
        .clock = .{ .divisor_16ths = clock_divisor * 16 },
        .max_count = max_count,
    });
    const Blue_LED_Top = chip.PWM(.{
        .output = .GPIO8, // ch4a
        .polarity = .low_below_threshold,
        .clock = .{ .divisor_16ths = clock_divisor * 16 },
        .max_count = max_count,
    });

    const Red_LED_Side = chip.PWM(.{
        .output = .GPIO9, // ch4b
        .polarity = .low_below_threshold,
        .clock = .{ .divisor_16ths = clock_divisor * 16 },
        .max_count = max_count,
    });
    const Green_LED_Side = chip.PWM(.{
        .output = .GPIO10, // ch5a
        .polarity = .low_below_threshold,
        .clock = .{ .divisor_16ths = clock_divisor * 16 },
        .max_count = max_count,
    });
    const Blue_LED_Side = chip.PWM(.{
        .output = .GPIO11, // ch5b
        .polarity = .low_below_threshold,
        .clock = .{ .divisor_16ths = clock_divisor * 16 },
        .max_count = max_count,
    });
};

const rhs = struct {
    const Red_LED_Top = chip.PWM(.{
        .output = .GPIO6, // ch3a
        .polarity = .low_below_threshold,
        .clock = .{ .divisor_16ths = clock_divisor * 16 },
        .max_count = max_count,
    });
    const Green_LED_Top = chip.PWM(.{
        .output = .GPIO7, // ch3b
        .polarity = .low_below_threshold,
        .clock = .{ .divisor_16ths = clock_divisor * 16 },
        .max_count = max_count,
    });
    const Blue_LED_Top = chip.PWM(.{
        .output = .GPIO8, // ch4a
        .polarity = .low_below_threshold,
        .clock = .{ .divisor_16ths = clock_divisor * 16 },
        .max_count = max_count,
    });

    const Red_LED_Side = chip.PWM(.{
        .output = .GPIO19, // ch1b
        .polarity = .low_below_threshold,
        .clock = .{ .divisor_16ths = clock_divisor * 16 },
        .max_count = max_count,
    });
    const Green_LED_Side = chip.PWM(.{
        .output = .GPIO20, // ch2a
        .polarity = .low_below_threshold,
        .clock = .{ .divisor_16ths = clock_divisor * 16 },
        .max_count = max_count,
    });
    const Blue_LED_Side = chip.PWM(.{
        .output = .GPIO21, // ch2b
        .polarity = .low_below_threshold,
        .clock = .{ .divisor_16ths = clock_divisor * 16 },
        .max_count = max_count,
    });
};

pub fn init() void {
    if (Location.local == .left) {
        lhs.Blue_LED_Top.init();
        lhs.Red_LED_Top.init();
        lhs.Green_LED_Top.init();
        
        lhs.Blue_LED_Side.init();
        lhs.Red_LED_Side.init();
        lhs.Green_LED_Side.init();

        lhs.Blue_LED_Top.set_threshold(0);
        lhs.Red_LED_Top.set_threshold(0);
        lhs.Green_LED_Top.set_threshold(0);
        
        lhs.Blue_LED_Side.set_threshold(0);
        lhs.Red_LED_Side.set_threshold(0);
        lhs.Green_LED_Side.set_threshold(0);

        comptime var enable_mask: chip.reg_types.pwm.Channel_Bitmap = .{};

        @field(enable_mask, @tagName(lhs.Red_LED_Top.channel)) = true;
        @field(enable_mask, @tagName(lhs.Green_LED_Top.channel)) = true;
        @field(enable_mask, @tagName(lhs.Blue_LED_Top.channel)) = true;
        
        @field(enable_mask, @tagName(lhs.Red_LED_Side.channel)) = true;
        @field(enable_mask, @tagName(lhs.Green_LED_Side.channel)) = true;
        @field(enable_mask, @tagName(lhs.Blue_LED_Side.channel)) = true;

        chip.peripherals.PWM.enable.set_bits(enable_mask);
    } else {
        rhs.Blue_LED_Top.init();
        rhs.Red_LED_Top.init();
        rhs.Green_LED_Top.init();
        
        rhs.Blue_LED_Side.init();
        rhs.Red_LED_Side.init();
        rhs.Green_LED_Side.init();

        rhs.Blue_LED_Top.set_threshold(0);
        rhs.Red_LED_Top.set_threshold(0);
        rhs.Green_LED_Top.set_threshold(0);
        
        rhs.Blue_LED_Side.set_threshold(0);
        rhs.Red_LED_Side.set_threshold(0);
        rhs.Green_LED_Side.set_threshold(0);

        comptime var enable_mask: chip.reg_types.pwm.Channel_Bitmap = .{};

        @field(enable_mask, @tagName(rhs.Red_LED_Top.channel)) = true;
        @field(enable_mask, @tagName(rhs.Green_LED_Top.channel)) = true;
        @field(enable_mask, @tagName(rhs.Blue_LED_Top.channel)) = true;
        
        @field(enable_mask, @tagName(rhs.Red_LED_Side.channel)) = true;
        @field(enable_mask, @tagName(rhs.Green_LED_Side.channel)) = true;
        @field(enable_mask, @tagName(rhs.Blue_LED_Side.channel)) = true;

        chip.peripherals.PWM.enable.set_bits(enable_mask);
    }
    
    log.info("initialized", .{});
}

pub fn set_top(location: Location, rgb: RGB) void {
    if (location != Location.local) return;
    if (Location.local == .left) {
        lhs.Red_LED_Top.set_threshold(rgb.r);
        lhs.Green_LED_Top.set_threshold(rgb.g);
        lhs.Blue_LED_Top.set_threshold(rgb.b);
    } else {
        rhs.Red_LED_Top.set_threshold(rgb.r);
        rhs.Green_LED_Top.set_threshold(rgb.g);
        rhs.Blue_LED_Top.set_threshold(rgb.b);
    }
}

pub fn set_side(location: Location, rgb: RGB) void {
    if (location != Location.local) return;
    if (Location.local == .left) {
        lhs.Red_LED_Side.set_threshold(rgb.r);
        lhs.Green_LED_Side.set_threshold(rgb.g);
        lhs.Blue_LED_Side.set_threshold(rgb.b);
    } else {
        rhs.Red_LED_Side.set_threshold(rgb.r);
        rhs.Green_LED_Side.set_threshold(rgb.g);
        rhs.Blue_LED_Side.set_threshold(rgb.b);
    }
}

const log = std.log.scoped(.leds);

const Location = util.Location;
const util = @import("util.zig");
const chip = @import("chip");
const microbe = @import("microbe");
const std = @import("std");
