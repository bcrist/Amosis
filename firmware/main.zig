// On the LHS, GPIO9 connects to VCC through a small resistor and one of the red LEDs.
// With the very low current sinked by the RP2040's pull-down, it should be above the 2V needed to reliably detect a high.
// On the RHS, GPIO9 is COL0, so if GPIO16/17/18 (ROW0/1/2) are also low, it won't be pulled high, even if some switches are active.
const Loc_Detect = microbe.Bus(&.{ .GPIO9, .GPIO16, .GPIO17, .GPIO18 }, .{ .gpio_config = .{
    .hysteresis = false,
    .maintenance = .pull_down,
}});

pub fn main() !void {
    debug_uart = @TypeOf(debug_uart).init();
    debug_uart.start();

    {
        Loc_Detect.init();
        defer Loc_Detect.deinit();

        Loc_Detect.set_output_enable(false);
        microbe.Tick.delay(.{ .ms = 1 });
        const gpio9: u1 = @truncate(Loc_Detect.read());
        Location.set_local(if (gpio9 == 1) .left else .right);
    }

    leds.init();
    matrix.init();
    link.init();
    pinnacle.init();
    logic.init();
    usb.init();

    while (true) {
        matrix.update();
        link.update();
        pinnacle.update();
        logic.update();
        usb.update();
    }
}


pub const clocks: chip.clocks.Config = .{
    .xosc = .{},
    .sys_pll = .{ .frequency_hz = 100_000_000 },
    .usb_pll = .{ .frequency_hz = 48_000_000 },
    .usb = .{ .frequency_hz = 48_000_000 },
    .uart_spi = .{},
};

pub const handlers = struct {
    pub const SysTick = chip.timing.handle_tick_interrupt;
    pub const SPI1_IRQ = pinnacle.handle_spi_interrupt;
    pub const PWM_IRQ_WRAP = matrix.handle_interrupt;
    pub const UART1_IRQ = link.handle_interrupt;
    pub fn UART0_IRQ() void {
        debug_uart.handle_interrupt();
    }
};

pub var debug_uart: chip.UART(.{
    .baud_rate = 115207,
    .tx = .GPIO0,
    //.cts = .GPIO2,
    .rx = null,
    .tx_buffer_size = 4096,
}) = undefined;

pub const panic = microbe.default_panic;
pub const std_options: std.Options = .{
    .logFn = microbe.default_log,
    .log_level = std.log.Level.info,
    .log_scope_levels = &.{
        .{ .scope = .usb, .level = .info },
        .{ .scope = .hid, .level = .info },
        .{ .scope = .pinnacle, .level = .info },
        .{ .scope = .matrix, .level = .info },
    },
};

comptime {
    chip.init_exports();
}

export const _boot2_checksum: u32 linksection(".boot2_checksum") = 0x1756F7BC;

const Location = @import("util.zig").Location;
const logic = @import("logic.zig");
const usb = @import("usb.zig");
const pinnacle = @import("pinnacle.zig");
const matrix = @import("matrix.zig");
const leds = @import("leds.zig");
const link = @import("link.zig");
const chip = @import("chip");
const microbe = @import("microbe");
const std = @import("std");
