const navnum_color: RGB = .{ .g = 500 };
const shifted_color: RGB = .{ .b = 1000 };
const ctrl_color: RGB = .{ .r = 500, .g = 200 };
const alt_color: RGB = .{ .g = 500, .b = 200 };
const gui_color: RGB = .{ .r = 500, .b = 600 };
const rollover_error_color: RGB = .{ .r = 1000 };

const caps_lock_color: RGB = .{ .r = 1000 };
const num_lock_color: RGB = .{ .r = 1000 };
const scroll_lock_color: RGB = .{ .r = 1000 };

const max_tap_duration = .{ .ms = 400 };
const max_double_tap_interval = .{ .ms = 650 };

const Keymap = std.enums.EnumFieldStruct(Layer, [5][6]USB_Key, null);
const left_keymap: Keymap = .{
    .alpha = .{
        .{ a(.kp_lessthan), a(.kp_obrace),   a(.kp_multiply), a(.kp_divide),      a(.kp_exclaim), .{}      },
        .{ u(.kb_w),        u(.kb_f),        u(.kb_m),        u(.kb_p),           u(.kb_b),       .{}      },
        .{ u(.kb_r),        u(.kb_s),        u(.kb_n),        u(.kb_t),           u(.kb_g),       .{}      },
        .{ u(.kb_x),        u(.kb_c),        u(.kb_l),        u(.kb_d),           u(.kb_q),       .{}      },
        .{ a(.lalt),        a(alpha_toggle), u(.space),       s(.backtick_tilde), u(.backspace),  a(.home) },
    },
    .alpha_shifted = .{
        .{ a(.kp_oparen), u(.obracket_obrace), a(.kp_plus),           a(.kp_minus),       s(.kb_4_dollar), .{}      },
        .{ s(.kb_w),      s(.kb_f),            s(.kb_m),              s(.kb_p),           s(.kb_b),        .{}      },
        .{ s(.kb_r),      s(.kb_s),            s(.kb_n),              s(.kb_t),           s(.kb_g),        .{}      },
        .{ s(.kb_x),      s(.kb_c),            s(.kb_l),              s(.kb_d),           s(.kb_q),        .{}      },
        .{ a(.lalt),      a(alpha_toggle),     s(.hyphen_underscore), u(.backtick_tilde), s(.backspace),   a(.home) },
    },
    .navnum = .{
        .{ a(.f7),   a(.f6),          a(.f10),      a(.f11),       a(.f12),       .{}      },
        .{ a(.f8),   a(.f9),          a(.nav_up),   a(.tab),       a(.page_up),   .{}      },
        .{ .{},      a(.nav_left),    a(.nav_down), a(.nav_right), a(.page_down), .{}      },
        .{ a(.f5),   a(.f4),          a(.f3),       a(.f2),        a(.f1),        .{}      },
        .{ a(.lalt), a(alpha_toggle), s(.space),    a(.insert),    u(.backspace), a(.home) },
    },
    .navnum_shifted = .{
        .{ a(.f7),   a(.f6),          a(.f10),               a(.f11),       a(.f12),       .{}      },
        .{ a(.f8),   a(.f9),          a(.nav_up),            a(.tab),       a(.page_up),   .{}      },
        .{ .{},      a(.nav_left),    a(.nav_down),          a(.nav_right), a(.page_down), .{}      },
        .{ a(.f5),   a(.f4),          a(.f3),                a(.f2),        a(.f1),        .{}      },
        .{ a(.lalt), a(alpha_toggle), s(.hyphen_underscore), a(.insert),    s(.backspace), a(.home) },
    },
};
const right_keymap: Keymap = .{
    .alpha = .{
        .{ a(.kp_greaterthan), a(.kp_cbrace), a(.kp_vbar),        a(.kp_ampersand),  a(.kp_at),          .{}     },
        .{ u(.kb_v),           u(.kb_j),      u(.comma_lessthan), a(.kp_dot_delete), u(.squote_dquote),  .{}     },
        .{ u(.kb_h),           u(.kb_i),      u(.kb_e),           u(.kb_a),          s(.slash_question), .{}     },
        .{ u(.kb_k),           u(.kb_y),      u(.kb_o),           u(.kb_u),          u(.kb_z),           .{}     },
        .{ a(.lcontrol),       a(.lshift),    a(.kb_return),      a(.escape),        a(.delete),         a(.end) },
    },
    .alpha_shifted = .{
        .{ a(.kp_cparen), u(.cbracket_cbrace), a(.kp_octothorpe),   u(.backslash_vbar),  a(.kp_caret),      .{}     },
        .{ s(.kb_v),      s(.kb_j),            u(.semicolon_colon), s(.semicolon_colon), s(.squote_dquote), .{}     },
        .{ s(.kb_h),      s(.kb_i),            s(.kb_e),            s(.kb_a),            a(.kp_percent),    .{}     },
        .{ s(.kb_k),      s(.kb_y),            s(.kb_o),            s(.kb_u),            s(.kb_z),          .{}     },
        .{ a(.lcontrol),  a(.lshift),          a(.kb_return),       a(.escape),          a(.delete),        a(.end) },
    },
    .navnum = .{
        .{ .{},               a(.lgui),           a(.kp_multiply),   a(.kp_divide),     a(.print_screen), .{}     },
        .{ a(.kp_minus),      a(.kp_9_page_up),   a(.kp_8_nav_up),   a(.kp_7_home),     a(.kp_equals),    .{}     },
        .{ a(.kp_0_insert),   a(.kp_6_nav_right), a(.kp_5),          a(.kp_4_nav_left), a(.kp_plus),      .{}     },
        .{ a(.kp_dot_delete), a(.kp_3_page_down), a(.kp_2_nav_down), a(.kp_1_end),      a(.kp_backspace), .{}     },
        .{ a(.lcontrol),      a(.lshift),         a(.kb_return),     a(.escape),        a(.delete),       a(.end) },
    },
    .navnum_shifted = .{
        .{ .{},               a(.lgui),           a(.kp_multiply),   a(.kp_divide),     a(.print_screen), .{}     },
        .{ a(.kp_minus),      a(.kp_9_page_up),   a(.kp_8_nav_up),   a(.kp_7_home),     a(.kp_equals),    .{}     },
        .{ a(.kp_0_insert),   a(.kp_6_nav_right), a(.kp_5),          a(.kp_4_nav_left), a(.kp_plus),      .{}     },
        .{ a(.kp_dot_delete), a(.kp_3_page_down), a(.kp_2_nav_down), a(.kp_1_end),      a(.kp_backspace), .{}     },
        .{ a(.lcontrol),      a(.lshift),         a(.kb_return),     a(.escape),        a(.delete),       a(.end) },
    },
};

const Layer = enum {
    alpha,
    alpha_shifted,
    navnum,
    navnum_shifted,

    pub fn is_shifted(self: Layer) bool {
        return switch (self) {
            .alpha, .navnum => false,
            .alpha_shifted, .navnum_shifted => true,
        };
    }

    pub fn is_alpha(self: Layer) bool {
        return switch (self) {
            .alpha, .alpha_shifted => true,
            .navnum, .navnum_shifted => false,
        };
    }

    pub fn toggle_shift(self: *Layer) void {
        self.* = switch (self.*) {
            .alpha => .alpha_shifted,
            .alpha_shifted => .alpha,
            .navnum => .navnum_shifted,
            .navnum_shifted => .navnum,
        };
    }

    pub fn toggle_alpha(self: *Layer) void {
        self.* = switch (self.*) {
            .alpha => .navnum,
            .alpha_shifted => .navnum_shifted,
            .navnum => .alpha,
            .navnum_shifted => .alpha_shifted,
        };
    }
};

const alpha_toggle: microbe.usb.hid.page.Keyboard = @enumFromInt(0xFF);
const lmb: microbe.usb.hid.page.Keyboard = @enumFromInt(0xF8);
const rmb: microbe.usb.hid.page.Keyboard = @enumFromInt(0xF9);
const mmb: microbe.usb.hid.page.Keyboard = @enumFromInt(0xFA);
const mb4: microbe.usb.hid.page.Keyboard = @enumFromInt(0xFB);
const mb5: microbe.usb.hid.page.Keyboard = @enumFromInt(0xFC);
const mb6: microbe.usb.hid.page.Keyboard = @enumFromInt(0xFD);
const mb7: microbe.usb.hid.page.Keyboard = @enumFromInt(0xFE);

fn u(code: microbe.usb.hid.page.Keyboard) USB_Key { return .{ .unshifted = code }; }
fn s(code: microbe.usb.hid.page.Keyboard) USB_Key { return .{ .shifted = code }; }
fn a(code: microbe.usb.hid.page.Keyboard) USB_Key { return .{ .unshifted = code, .shifted = code }; }

const USB_Key = struct {
    unshifted: microbe.usb.hid.page.Keyboard = @enumFromInt(0),
    shifted: microbe.usb.hid.page.Keyboard = @enumFromInt(0),
};

const Pressed_Key = struct {
    microtick: Microtick,
    source: Key_ID,
    mapped: USB_Key,
};

var pressed_keys: [12]?Pressed_Key = .{ null } ** 12;

var last_tapped_alpha: Microtick = @enumFromInt(0);
var last_tapped_shift: Microtick = @enumFromInt(0);
var last_normal_key: Microtick = @enumFromInt(0);

var locked_layer: Layer = .alpha;
var layer: Layer = .alpha;

var ctrl: bool = false;
var alt: bool = false;
var gui: bool = false;

var rollover_error: bool = false;
var rollover_error_count: u8 = 0;

var left_track: Track = .{};
var left_track_down: Track = .{};
var left_track_remainder_x: i64 = 0;
var left_track_remainder_y: i64 = 0;

var right_track: [4]Track = .{ .{} } ** 4;
var right_track_origin: Track = .{};

var last_mouse_report_generated: Microtick = @enumFromInt(0);

pub fn init() void {
    last_mouse_report_generated = Microtick.now();
}

pub fn update() void {
    leds.set_side(.left, if (!layer.is_alpha()) navnum_color else .{});
    leds.set_side(.left, if (layer.is_shifted()) shifted_color else .{});
    leds.set_side(.left, if (ctrl) ctrl_color else .{});
    leds.set_side(.left, if (alt) alt_color else .{});
    leds.set_side(.left, if (gui) gui_color else .{});
    leds.set_side(.left, if (rollover_error) rollover_error_color else .{});

    leds.set_side(.right, if (usb.keyboard_status.current_report.caps_lock) caps_lock_color else .{});
    leds.set_side(.right, if (usb.keyboard_status.current_report.num_lock) num_lock_color else .{});
    leds.set_side(.right, if (usb.keyboard_status.current_report.scroll_lock) scroll_lock_color else .{});
}

fn key_pressed(key: Key_ID) void {
    const usb_key: USB_Key = switch (key.location) {
        .left => switch (layer) { inline else => |l| @field(left_keymap, @tagName(l))[key.row][key.col] },
        .right => switch (layer) { inline else => |l| @field(right_keymap, @tagName(l))[key.row][key.col] },
    };

    const now = Microtick.now();

    for (&pressed_keys) |*pressed| {
        if (pressed.* == null) {
            pressed.* = .{
                .microtick = now,
                .source = key,
                .mapped = usb_key,
            };
            break;
        }
    } else {
        rollover_error_count += 1;
        log.warn("rollover error; ignoring {s} R{} C{} press for {s}/{s}", .{
            @tagName(key.location),
            key.row,
            key.col,
            std.enums.tagName(microbe.usb.hid.page.Keyboard, usb_key.unshifted) orelse "?",
            std.enums.tagName(microbe.usb.hid.page.Keyboard, usb_key.shifted) orelse "?",
        });
        return;
    }

    switch (usb_key.unshifted) {
        alpha_toggle => layer.toggle_alpha(),
        .lshift, .rshift => layer.toggle_shift(),
        .lalt, .ralt => alt = !alt,
        .lcontrol, .rcontrol => ctrl = !ctrl,
        .lgui, .rgui => gui = !gui,
        else => {},
    }

    push_keyboard_report();
}

fn key_released(key: Key_ID) void {
    const now = Microtick.now();

    var found: ?*?Pressed_Key = null;
    var shift_held = false;
    var alt_held = false;
    var ctrl_held = false;
    var gui_held = false;
    for (&pressed_keys) |*maybe_pressed| {
        if (maybe_pressed.*) |pressed| {
            if (std.meta.eql(pressed.source, key)) {
                found = maybe_pressed;
            } else switch (pressed.mapped.unshifted) {
                .lshift, .rshift => shift_held = true,
                .lalt, .ralt => alt_held = true,
                .lcontrol, .rcontrol => ctrl_held = true,
                .lgui, .rgui => gui_held = true,
                else => {},
            }
        }
    }
    
    if (found) |maybe_pressed| {
        const pressed = maybe_pressed.*.?;
        maybe_pressed.* = null;
        push_keyboard_report();

        const was_tap = pressed.microtick.is_after(last_normal_key) and pressed.microtick.plus(max_tap_duration).is_after(now);

        switch (pressed.mapped.unshifted) {
            alpha_toggle => {
                if (was_tap) {
                    if (last_tapped_alpha.plus(max_double_tap_interval).is_after(now)) {
                        locked_layer.toggle_alpha();
                    }
                    last_tapped_alpha = now;
                } else {
                    layer.toggle_alpha();
                }
            },
            .lshift, .rshift => {
                if (was_tap) {
                    if (last_tapped_shift.plus(max_double_tap_interval).is_after(now)) {
                        locked_layer.toggle_shift();
                    }
                    last_tapped_shift = now;
                } else {
                    layer.toggle_shift();
                }
            },
            .lalt, .ralt => {
                if (!was_tap) {
                    alt = alt_held;
                }
            },
            .lcontrol, .rcontrol => {
                if (!was_tap) {
                    ctrl = ctrl_held;
                }
            },
            .lgui, .rgui => {
                if (!was_tap) {
                    gui = gui_held;
                }
            },
            else => {
                layer = locked_layer;
                if (shift_held) {
                    layer.toggle_shift();
                }
                alt = alt_held;
                ctrl = ctrl_held;
                gui = gui_held;
                last_normal_key = now;
            },
        }

        
    } else if (rollover_error_count > 0) {
        rollover_error_count -= 1;
    }

    push_keyboard_report();
}

fn push_keyboard_report() void {
    rollover_error = rollover_error_count > 0;

    var report: usb.default_configuration.keyboard_interface.Report = .{
        .modifiers = .{
            .left_control = ctrl,
            .left_alt = alt,
            .left_gui = gui,
        },
    };

    var want_unshifted: usize = 0;
    var want_shifted: usize = 0;
    for (pressed_keys) |maybe_pressed| {
        if (maybe_pressed) |pressed| {
            switch (pressed.mapped.unshifted) {
                alpha_toggle,
                lmb, rmb, mmb, mb4, mb5, mb6, mb7,
                .lshift, .rshift,
                .lalt, .ralt,
                .lcontrol, .rcontrol,
                .lgui, .rgui => continue,
                else => {},
            }

            const unshifted = @intFromEnum(pressed.mapped.unshifted);
            const shifted = @intFromEnum(pressed.mapped.shifted);

            if (unshifted > 0 and shifted == 0) want_unshifted += 1;
            if (unshifted == 0 and shifted > 0) want_shifted += 1;
        }
    }

    report.modifiers.left_shift = (want_shifted > want_unshifted) or (want_shifted == want_unshifted and layer.is_shifted());

    var next_slot: usize = 0;
    for (pressed_keys) |maybe_pressed| {
        if (maybe_pressed) |pressed| {
            switch (pressed.mapped.unshifted) {
                alpha_toggle,
                lmb, rmb, mmb, mb4, mb5, mb6, mb7,
                .lshift, .rshift,
                .lalt, .ralt,
                .lcontrol, .rcontrol,
                .lgui, .rgui => continue,
                else => {},
            }

            if (report.modifiers.left_shift) {
                if (@intFromEnum(pressed.mapped.shifted) != 0) {
                    if (next_slot < report.keys.len) {
                        report.keys[next_slot] = pressed.mapped.shifted;
                        next_slot += 1;
                    } else {
                        rollover_error = true;
                    }
                } else if (@intFromEnum(pressed.mapped.unshifted) != 0) {
                    rollover_error = true;
                }
            } else {
                if (@intFromEnum(pressed.mapped.unshifted) != 0) {
                    if (next_slot < report.keys.len) {
                        report.keys[next_slot] = pressed.mapped.unshifted;
                        next_slot += 1;
                    } else {
                        rollover_error = true;
                    }
                } else if (@intFromEnum(pressed.mapped.shifted) != 0) {
                    rollover_error = true;
                }
            }
        }
    }

    usb.keyboard_report.push(report);
}

pub fn process_keys(location: Location, old_keys_pressed: *[3]u7, comptime T: type, new_keys_pressed: *const[3]T) void {
    for (0.., old_keys_pressed, new_keys_pressed) |row, *old_ptr, new| {
        const old = old_ptr.*;
        if (old == new) continue;
        for (0..7) |col| {
            const old_bit: u1 = @truncate(old >> @intCast(col));
            const new_bit: u1 = @truncate(new >> @intCast(col));
            if (old_bit == new_bit) continue;
            if (new_bit == 1) {
                key_pressed(.{
                    .location = location,
                    .row = @intCast(row),
                    .col = @intCast(col),
                });
            } else {
                key_released(.{
                    .location = location,
                    .row = @intCast(row),
                    .col = @intCast(col),
                });
            }
        }
        old_ptr.* = @intCast(new);
    }
}

pub fn set_track(location: Location, track: Track) void {
    switch (location) {
        .left => {
            left_track = track;
            if (track.z > 0) {
                if (left_track_down.z == 0) {
                    left_track_down = track;
                }
            } else {
                left_track_down = .{};
            }
        },
        .right => {
            right_track[3] = right_track[2];
            right_track[2] = right_track[1];
            right_track[1] = right_track[0];
            right_track[0] = track;
            if (track.z > 0) {
                if (right_track_origin.z == 0) {
                    right_track_origin = track;
                }
            } else {
                right_track_origin = .{};
            }
        },
    }
}

pub fn get_mouse_report() Mouse_Report {
    var report: Mouse_Report = .{};

    const now = Microtick.now();
    const dt = std.math.clamp(@intFromEnum(now) -% @intFromEnum(last_mouse_report_generated), 0, 100_000);

    if (left_track.z > 0 and dt > 0) {
        left_track_remainder_x += @as(i64, left_track.x - left_track_down.x) * dt;
        left_track_remainder_y += @as(i64, left_track.y - left_track_down.y) * dt;

        const dx = std.math.clamp(left_track_remainder_x >> 18, -60, 60);
        const dy = std.math.clamp(left_track_remainder_y >> 18, -60, 60);

        left_track_remainder_x -= dx << 18;
        left_track_remainder_y -= dy << 18;

        report.x += @intCast(dx);
        report.y += @intCast(dy);

        log.debug("dt: {}  dx: {}  dy: {} rx: {}  ry: {}", .{ dt, dx, dy, left_track_remainder_x, left_track_remainder_y });
    }

    // if (right_track_origin.z > 0) {
    //     var right = average_right_track();
    //     const dx: i8 = @intCast(std.math.clamp(right.x - right_track_origin.x, -60, 60));
    //     const dy: i8 = @intCast(std.math.clamp(right.y - right_track_origin.y, -60, 60));

    //     right_track_origin.x += dx;
    //     right_track_origin.y += dy;

    //     report.x += dx;
    //     report.y -= dy;
    // }

    for (pressed_keys) |maybe_pressed| {
        if (maybe_pressed) |pressed| {
            switch (pressed.mapped.unshifted) {
                lmb => report.left_btn = true,
                rmb => report.right_btn = true,
                mmb => report.middle_btn = true,
                mb4 => report.btn_4 = true,
                mb5 => report.btn_5 = true,
                mb6 => report.btn_6 = true,
                mb7 => report.btn_7 = true,
                else => {},
            }
        }
    }

    last_mouse_report_generated = now;
    return report;
}

fn average_right_track() Track {
    const x = @as(i32, right_track[0].x) * 7
        + @as(i32, right_track[1].x) * 5
        + @as(i32, right_track[2].x) * 3
        + @as(i32, right_track[3].x)
        ;
    
    const y = @as(i32, right_track[0].y) * 7
        + @as(i32, right_track[1].y) * 5
        + @as(i32, right_track[2].y) * 3
        + @as(i32, right_track[3].y)
        ;

    const z = @as(u16, right_track[0].z) * 7
        + @as(u16, right_track[1].z) * 5
        + @as(u16, right_track[2].z) * 3
        + @as(u16, right_track[3].z)
        ;

    return .{
        .x = @intCast(@divTrunc(x, 16)),
        .y = @intCast(@divTrunc(y, 16)),
        .z = @intCast(@divTrunc(z, 16)),
    };
}

const log = std.log.scoped(.logic);

const Mouse_Report = usb.default_configuration.mouse_interface.Report;
const RGB = leds.RGB;
const leds = @import("leds.zig");
const Location = util.Location;
const Track = util.Track;
const Key_ID = util.Key_ID;
const util = @import("util.zig");
const usb = @import("usb.zig");
const Microtick = microbe.Microtick;
const microbe = @import("microbe");
const std = @import("std");
