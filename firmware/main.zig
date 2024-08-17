pub fn main() !void {
    debug_uart = @TypeOf(debug_uart).init();
    debug_uart.start();

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

export const _boot2_checksum: u32 linksection(".boot2_checksum") = 0x5950FD7C;

const logic = @import("logic.zig");
const usb = @import("usb.zig");
const pinnacle = @import("pinnacle.zig");
const matrix = @import("matrix.zig");
const link = @import("link.zig");
const chip = @import("chip");
const microbe = @import("microbe");
const std = @import("std");
