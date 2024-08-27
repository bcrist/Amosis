// Driver for Cirque TM040040 circular trackpads (as used in the steam controller)
// Reference:
// https://github.com/cirque-corp/Cirque_Pinnacle_1CA027/blob/master/Circular_Trackpad/Single_Pad_Sample_Code/SPI_CurvedOverlay/SPI_CurvedOverlay.ino

pub fn init() void {
    DR.init();
    DR.set_output_enable(false);

    Haptic.init();
    Haptic.set_output_enable(true);

    spi = SPI.init();
    spi.start();

    clear_status();

    start_write_register(.feed_config, @bitCast(Feed_Config{}));
    finish_write_register();
    start_write_register(.sys_config, @bitCast(Sys_Config{}));
    finish_write_register();
    start_write_register(.relative_feed_config, @bitCast(Relative_Feed_Config{}));
    finish_write_register();
    start_write_register(.sample_rate_hz, @as(u8, 100));
    finish_write_register();

    start_read_register(.firmware_id);
    log.info("Firmware ID: {X:0>2}", .{ finish_read_register() });

    start_read_register(.firmware_version);
    log.info("Firmware Version: {X:0>2}", .{ finish_read_register() });

    set_adc_gain(.full_scale);
    tune_edge_sensitivity();

    start_write_register(.feed_config, @bitCast(Feed_Config{
        .feed_enable = true,
        .mode = .absolute,
    }));
    finish_write_register();
    log.info("initialized", .{});
}

pub fn handle_spi_interrupt() void {
    spi.handle_interrupt();
}

pub fn update() void {
    if (!spi.is_tx_idle()) return;

    if (spi.can_read()) {
        const report = finish_read_autoincrement(Absolute_Report);
        finish_write_register();
        std.debug.assert(!spi.can_read());

        const x: i16 = report.x_msb;
        const y: i16 = report.y_msb;

        var track: Track = .{
            .x = (x << 8) | report.x_lsb,
            .y = (y << 8) | report.y_lsb,
            .z = report.z,
        };

        track.x -= 1024;
        track.x = std.math.clamp(@divTrunc(track.x * 3, 4), -750, 750);

        track.y -= 768;
        track.y = std.math.clamp(track.y, -750, 750);

        log.debug("{}", .{ track });
        link.send_track(track);
        logic.set_track(Location.local, track);
        return;
    }

    if (DR.read() == 1) {
        start_read_autoincrement(Absolute_Report, .data_0);
        start_write_register(.status, @bitCast(Status_Byte{}));
    }
}

/// By default, the the signal is maximally attenuated; reduce attenuation when using curved/thick overlays
fn set_adc_gain(value: ADC_Gain) void {
    var raw = read_extended_register(u8, .adc_gain);
    raw &= 0x3F;
    raw |= @intFromEnum(value);
    write_extended_register(.adc_gain, raw);
    log.info("ADC gain set to {s} ({})", .{ @tagName(value), raw });
}

/// Changes thresholds to improve detection of fingers
fn tune_edge_sensitivity() void {
    {
        const old = read_extended_register(u8, .x_axis_wide_z_min);
        log.info("Old X axis 'wide Z min': {}", .{ old });
        write_extended_register(.x_axis_wide_z_min, 0x04);
        const new = read_extended_register(u8, .x_axis_wide_z_min);
        log.info("New X axis 'wide Z min': {}", .{ new });
    }
    {
        const old = read_extended_register(u8, .y_axis_wide_z_min);
        log.info("Old Y axis 'wide Z min': {}", .{ old });
        write_extended_register(.y_axis_wide_z_min, 0x03);
        const new = read_extended_register(u8, .y_axis_wide_z_min);
        log.info("New Y axis 'wide Z min': {}", .{ new });
    }
}

fn start_write_register(reg: Register, value: u8) void {
    var writer = spi.writer();
    writer.writeByte(@intFromEnum(reg) | 0x80) catch unreachable;
    writer.writeByte(@bitCast(value)) catch unreachable;
}
fn finish_write_register() void {
    var reader = spi.reader();
    _ = reader.readByte() catch unreachable;
    _ = reader.readByte() catch unreachable;
}

fn start_read_register(reg: Register) void{
    var writer = spi.writer();
    writer.writeByte(@intFromEnum(reg) | 0xA0) catch unreachable;
    writer.writeByteNTimes(0xFB, 3) catch unreachable;
}
fn finish_read_register() u8 {
    var reader = spi.reader();
    var tmp: [4]u8 = undefined;
    _ = reader.readAll(&tmp) catch unreachable;
    return tmp[3];
}

fn start_read_autoincrement(comptime T: type, first: Register) void {
    var writer = spi.writer();
    writer.writeByte(@intFromEnum(first) | 0xA0) catch unreachable;
    writer.writeByteNTimes(0xFC, size_of(T) + 1) catch unreachable;
    writer.writeByte(0xFB) catch unreachable;
}
fn finish_read_autoincrement(comptime T: type) T {
    var reader = spi.reader();
    _ = reader.readByte() catch unreachable;
    _ = reader.readByte() catch unreachable;
    _ = reader.readByte() catch unreachable;
    var t: T = undefined;
    _ = reader.readAll(as_bytes(&t)) catch unreachable;
    return t;
}

/// N.B. This will block
fn clear_status() void {
    start_write_register(.status, @bitCast(Status_Byte{}));
    finish_write_register();
    microbe.Microtick.delay(.{ .us = 50 });
}

/// N.B. This only works when feed is disabled and will block until the write is complete
fn write_extended_register(reg: Extended_Register, value: u8) void {
    const addr: packed struct (u16) {
        low: u8,
        high: u8,
    } = @bitCast(@intFromEnum(reg));

    start_write_register(.era_data, value);
    finish_write_register();
    start_write_register(.era_addr_msb, addr.high);
    finish_write_register();
    start_write_register(.era_addr_lsb, addr.low);
    finish_write_register();
    start_write_register(.era_command, 0x02); // single write
    finish_write_register();

    wait_for_era_completion();
    clear_status();
}

/// N.B. This only works when feed is disabled and will block until the read is complete
fn read_extended_register(comptime T: type, first: Extended_Register) T {
    const addr: packed struct (u16) {
        low: u8,
        high: u8,
    } = @bitCast(@intFromEnum(first));

    start_write_register(.era_addr_msb, addr.high);
    finish_write_register();
    start_write_register(.era_addr_lsb, addr.low);
    finish_write_register();

    var t: T = undefined;

    for (as_bytes(&t)) |*b| {
        start_write_register(.era_command, 0x05); // read, autoincrement
        finish_write_register();
        wait_for_era_completion();
        start_read_register(.era_data);
        b.* = finish_read_register();
        clear_status();
    }

    return t;
}

fn wait_for_era_completion() void {
    while (true) {
        start_read_register(.era_command);
        if (finish_read_register() == 0x00) return;
    }
}

fn as_bytes(ptr: anytype) []u8 {
    const T = std.meta.Child(@TypeOf(ptr));
    return std.mem.asBytes(ptr)[0..size_of(T)];
}

fn size_of(comptime T: type) comptime_int {
    return @divTrunc(@bitSizeOf(T) + 7, 8);
}




const Register = enum (u8) {
    firmware_id = 0x00,
    firmware_version = 0x01,
    status = 0x02,
    sys_config = 0x03,
    feed_config = 0x04,
    relative_feed_config = 0x05,
    calibration = 0x07,
    ps2_aux_control = 0x08,
    sample_rate_hz = 0x09,
    z_idle = 0x0A, // Number of Z=0 packets sent when Z goes from >0 to 0
    z_scaler = 0x0B, // Contains the pen Z_On threshold
    sleep_interval = 0x0C,    
    sleep_timer = 0x0D,
    data_0 = 0x12,
    data_1 = 0x13,
    data_2 = 0x14,
    data_3 = 0x15,
    data_4 = 0x16,
    data_5 = 0x17,
    era_data = 0x1B,
    era_addr_msb = 0x1C,
    era_addr_lsb = 0x1D,
    era_command = 0x1E,
};

const Extended_Register = enum (u16) {
    x_axis_wide_z_min = 0x0149,
    y_axis_wide_z_min = 0x0168,
    adc_gain = 0x0187,
};

const ADC_Gain = enum (u8) {
    full_scale = 0x00,
    one_half = 0x40,
    one_third = 0x80,
    one_quarter = 0xC0,
};

const Status_Byte = packed struct (u8) {
    _reserved0: u2 = 0,
    data_ready: bool = false,
    command_complete: bool = false,
    _reserved4: u4 = 0,
};

const Sys_Config = packed struct (u8) {
    in_reset: bool = false,
    shutdown: bool = false,
    sleep_enabled: bool = false,
    _reserved3: u5 = 0,
};

const Feed_Config = packed struct (u8) {
    feed_enable: bool = false,
    mode: enum (u1) {
        relative = 0,
        absolute = 1,
    } = .relative,
    filter_disabled: bool = false,
    x_axis_disabled: bool = false,
    y_axis_disabled: bool = false,
    _reserved5: u1 = 0,
    invert_abs_x: bool = false,
    invert_abs_y: bool = false,
};

const Relative_Feed_Config = packed struct (u8) {
    wheel_enabled: bool = false,
    all_taps_disabled: bool = true,
    rmb_taps_disabled: bool = true,
    scroll_disabled: bool = true,
    glide_extend_disabled: bool = true,
    _reserved5: u2 = 0,
    swap_axes: bool = false,
};

const Relative_Report = packed struct (u32) {
    lmb_pressed: bool,
    rmb_pressed: bool,
    mmb_pressed: bool,
    _reserved3: u1 = 1,
    x_negative: bool,
    y_negative: bool,
    _reserved6: u2 = 0,
    delta_x_magnitude: u8,
    delta_y_magnitude: u8,
    wheel: i8,
};

const Absolute_Report = packed struct (u48) {
    btn0_pressed: bool,
    btn1_pressed: bool,
    btn2_pressed: bool,
    btn3_pressed: bool,
    btn4_pressed: bool,
    btn5_pressed: bool,
    _reserved6: u10 = 0,
    x_lsb: u8,
    y_lsb: u8,
    x_msb: u4,
    y_msb: u4,
    z: u6,
    _reserved46: u2 = 0,
};

const Haptic = microbe.Bus(&.{ .GPIO23, .GPIO24 }, .{
    .name = "Haptic",
    .gpio_config = .{
        .speed = .slow,
        .strength = .@"8mA",
    },
});

const DR = microbe.Bus(&.{ .GPIO25 }, .{
    .name = "DR",
    .gpio_config = .{
        .input_enabled = true,
        .hysteresis = true,
        .maintenance = .pull_down,
    },
});

const SPI = chip.spi.Controller(.{
    .format = .spi_mode_1,
    .bit_rate = 1_000_000,
    .sck = .GPIO26,
    .tx = .GPIO27,
    .rx = .GPIO28,
    .cs = .GPIO29,
    .tx_buffer_size = 16,
    .rx_buffer_size = 16,
});

var spi: SPI = undefined;

const log = std.log.scoped(.pinnacle);

const Location = util.Location;
const Track = util.Track;
const util = @import("util.zig");
const link = @import("link.zig");
const logic = @import("logic.zig");
const chip = @import("chip");
const microbe = @import("microbe");
const std = @import("std");
