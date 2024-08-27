/// Layout: (RC)
///                   Left                           Right
///  (00)(01)(02)(03)(04)(05)                   (01)(02)(03)(04)(05)(06)
///  (10)(11)(12)(13)(14)(15)                   (11)(12)(13)(14)(15)(16)
///  (20)(21)(22)(23)(24)(25)                   (21)(22)(23)(24)(25)(26)
///                     (26)(16)(06)     (00)(10)(20)


const Keymap = std.enums.EnumFieldStruct(Layer, [matrix.row_count][matrix.col_count]Mapped, null);
const left_keymap: Keymap = .{
    .abc = .{
        .{ .{.layer=.track},                .{.raw=.kb_j},              .{.raw=.kb_g},                  .{.raw=.kb_m},                  .{.raw=.kb_p},                  .{.raw=.kb_v},              .{.raw=.kb_return},     },
        .{ .{.raw=.kb_q},                   .{.raw=.kb_r},              .{.raw=.kb_s},                  .{.raw=.kb_n},                  .{.raw=.kb_d},                  .{.raw=.kb_b},              .{.raw=.kb_t},          },
        .{ .{.raw=.kb_z},                   .{.raw=.kb_x},              .{.raw=.kb_f},                  .{.raw=.kb_l},                  .{.raw=.kb_c},                  .{.raw=.kb_w},              .shift,                 },
    },
    .num = .{
        .{ .{.layer=.track},                .{.raw=.kp_divide},         .{.unshifted=.kb_7_ampersand},  .{.unshifted=.kb_8_asterisk},   .{.unshifted=.kb_9_oparen},     .{.raw=.kp_minus},          .{.raw=.kp_enter},                 },
        .{ .{.raw=.tab},                    .{.raw=.kp_multiply},       .{.unshifted=.kb_4_dollar},     .{.unshifted=.kb_5_percent},    .{.unshifted=.kb_6_caret},      .{.raw=.kp_plus},           .{.unshifted=.period_greaterthan}, },
        .{ .{.raw=.backspace},              .{.shifted=.kb_5_percent},  .{.unshifted=.kb_1_exclaim},    .{.unshifted=.kb_2_at},         .{.unshifted=.kb_3_octothorpe}, .{.shifted=.kb_4_dollar},   .{.unshifted=.kb_0_cparen},        },
    },
    .sym = .{
        .{ .{.layer=.track},                .{.shifted=.backtick_tilde}, .{.shifted=.kb_1_exclaim},     .{.shifted=.squote_dquote},     .{.unshifted=.squote_dquote},   .{.shifted=.kb_6_caret},    .{.shifted=.semicolon_colon},    },
        .{ .{.shifted=.kb_3_octothorpe},    .{.shifted=.kb_7_ampersand}, .{.shifted=.obracket_obrace},  .{.shifted=.cbracket_cbrace},   .{.shifted=.backslash_vbar},    .colon_equals,              .{.unshifted=.semicolon_colon}, },
        .{ .{.unshifted=.backtick_tilde},   .double_ampersand,           .{.shifted=.kb_2_at},          .{.shifted=.slash_question},    .double_vbar,                   .double_colon,              .{.unshifted=.comma_lessthan},  },
    },
    .fx = .{
        .{ .{.layer=.track},                .{.raw=.print_screen},      .{.raw=.pause},                 .{.raw=.caps_lock},             .{.raw=.kp_num_lock},           .{.raw=.scroll_lock},       .host_right,            },
        .{ .{.raw=.f1},                     .{.raw=.f2},                .{.raw=.f3},                    .{.raw=.f4},                    .{.raw=.f5},                    .{.raw=.f6},                .host_toggle,           },
        .{ .{.raw=.f7},                     .{.raw=.f8},                .{.raw=.f9},                    .{.raw=.f10},                   .{.raw=.f11},                   .{.raw=.f12},               .host_left,             },
    },
    .qwerty = .{
        .{ .{.raw=.escape},                 .{.raw=.kb_q},              .{.raw=.kb_w},                  .{.raw=.kb_e},                  .{.raw=.kb_r},                  .{.raw=.kb_t},              .{.raw=.kb_return},     },
        .{ .{.raw=.tab},                    .{.raw=.kb_a},              .{.raw=.kb_s},                  .{.raw=.kb_d},                  .{.raw=.kb_f},                  .{.raw=.kb_g},              .alt,                   },
        .{ .{.layer=.sym},                  .{.raw=.kb_z},              .{.raw=.kb_x},                  .{.raw=.kb_c},                  .{.raw=.kb_v},                  .{.raw=.kb_b},              .shift,                 },
    },
    .game = .{
        .{ .{.raw=.escape},                 .{.raw=.backtick_tilde},    .{.raw=.kb_q},                  .{.raw=.kb_w},                  .{.raw=.kb_e},                  .{.raw=.kb_r},              .{.raw=.kb_3_octothorpe}, },
        .{ .alt,                            .{.raw=.tab},               .{.raw=.kb_a},                  .{.raw=.kb_s},                  .{.raw=.kb_d},                  .{.raw=.kb_f},              .{.raw=.kb_2_at},         },
        .{ .ctrl,                           .shift,                     .{.raw=.kb_z},                  .{.raw=.kb_x},                  .{.raw=.kb_c},                  .{.raw=.kb_v},              .{.raw=.kb_1_exclaim},    },
    },
    .track = .{
        .{  .{.layer=.track},               .track_lock,                .{.raw=.volume_down},           .{.raw=.mute},                  .{.raw=.volume_up},             .unused,                    .{.raw=.kb_return},     },
        .{  .unused,                        .unused,                    .{.consumer=.prev_track},       .{.consumer=.play_pause},       .{.consumer=.next_track},       .unused,                    .host_toggle,           },
        .{  .mb4,                           .mb5,                       .mb6,                           .unused,                        .unused,                        .unused,                    .shift,                 },
    },
};
const right_keymap: Keymap = .{
    .abc = .{
        .{ .ctrl,                           .{.raw=.tab},                       .{.layer=.sym},         .{.layer=.num},                 .{.raw=.home},                  .{.raw=.end},               .{.layer=.fx},          },
        .{ .{.raw=.space},                  .alt,                               .{.raw=.kb_a},          .{.raw=.kb_e},                  .{.raw=.kb_i},                  .{.raw=.kb_h},              .{.raw=.backspace},     },
        .{ .{.shifted=.hyphen_underscore},  .{.unshifted=.period_greaterthan},  .{.raw=.kb_u},          .{.raw=.kb_o},                  .{.raw=.kb_y},                  .{.raw=.kb_k},              .{.raw=.delete},        },
    },
    .num = .{
        .{ .{.raw=.equals_plus},            .{.raw=.tab},               .{.layer=.sym},                 .{.layer=.num},                 .{.raw=.home},                  .{.raw=.end},                    .{.layer=.fx},              },
        .{ .{.raw=.space},                  .{.shifted=.comma_lessthan},.{.shifted=.kb_9_oparen},       ._0x,                           .{.shifted=.kb_0_cparen},       .{.shifted=.period_greaterthan}, .{.raw=.backspace},         },
        .{ .{.shifted=.hyphen_underscore},  .{.unshifted=.kb_4_dollar}, .{.unshifted=.kb_5_percent},    .{.unshifted=.kb_6_caret},      .{.unshifted=.kb_7_ampersand},  .{.unshifted=.kb_8_asterisk},    .{.unshifted=.kb_9_oparen}, },
    },
    .sym = .{
        .{ .double_equals,                  .{.raw=.tab},               .{.layer=.sym},                 .{.layer=.num},                 .{.raw=.home},                  .{.layer=.track},           .{.layer=.fx},          },
        .{ .{.raw=.space},                  .lessthan_equals,           .{.unshifted=.obracket_obrace}, .exclaim_equals,                .{.unshifted=.cbracket_cbrace}, .greaterthan_equals,        .{.raw=.backspace},     },
        .{ .{.unshifted=.backslash_vbar},   .double_lessthan,           .double_question,               .equals_greaterthan,            .question_colon,                .double_greaterthan,        .{.raw=.delete},        },
    },
    .fx = .{
        .{ .{.layer=.qwerty},               .{.raw=.tab},               .{.layer=.sym},                 .{.layer=.num},                 .{.raw=.home},                  .{.raw=.end},               .{.layer=.fx},          },
        .{ .{.raw=.escape},                 .unused,                    .{.raw=.page_up},               .{.raw=.nav_up},                .{.raw=.page_down},             .unused,                    .unused,                },
        .{ .{.layer=.game},                 .track_lock,                .{.raw=.nav_left},              .{.raw=.nav_down},              .{.raw=.nav_right},             .unused,                    .unused,                },
    },
    .qwerty = .{
        .{ .ctrl,                          .{.raw=.kb_y},               .{.raw=.kb_u},                  .{.raw=.kb_i},                  .{.raw=.kb_o},                  .{.raw=.kb_p},              .{.layer=.abc},         },
        .{ .{.raw=.space},                 .{.raw=.kb_h},               .{.raw=.kb_j},                  .{.raw=.kb_k},                  .{.raw=.kb_l},                  .{.raw=.semicolon_colon},   .{.raw=.squote_dquote}, },
        .{ .{.shifted=.hyphen_underscore}, .{.raw=.kb_n},               .{.raw=.kb_m},                  .{.raw=.comma_lessthan},        .{.raw=.period_greaterthan},    .{.raw=.slash_question},    .{.layer=.num},         },
    },
    .game = .{
        .{ .lmb,                            .{.raw=.kb_4_dollar},       .{.raw=.kb_5_percent},          .{.raw=.kb_6_caret},            .{.raw=.kb_7_ampersand},        .{.raw=.kb_8_asterisk},     .{.layer=.abc},         },
        .{ .{.raw=.space},                  .{.raw=.kb_g},              .{.raw=.kb_h},                  .{.raw=.kb_j},                  .{.raw=.kb_k},                  .{.raw=.kb_l},              .{.raw=.kb_p},          },
        .{ .rmb,                            .{.raw=.kb_b},              .{.raw=.kb_n},                  .{.raw=.kb_m},                  .{.raw=.kb_t},                  .{.raw=.kb_i},              .{.raw=.kp_enter},      },
    },
    .track = .{
        .{ .ctrl,                           .unused,                    .{.layer=.sym},                 .{.layer=.num},                 .unused,                        .unused,                    .{.layer=.fx},          },
        .{ .{.raw=.space},                  .alt,                       .unused,                        .unused,                        .unused,                        .unused,                    .unused,                },
        .{ .{.shifted=.hyphen_underscore},  .unused,                    .unused,                        .unused,                        .lmb,                           .mmb,                       .rmb,                   },
    },
};

const max_tap_duration = .{ .ms = 400 };
const max_double_tap_interval = .{ .ms = 650 };

const left_track_rotation = 60.0;
const left_track_matrix: [2][2]i32 = .{
    .{ @intFromFloat(@round(65536 * @cos(left_track_rotation))),  @intFromFloat(@round(65536 * -@sin(left_track_rotation)))  },
    .{ @intFromFloat(@round(65536 * @sin(left_track_rotation))),  @intFromFloat(@round(65536 * @cos(left_track_rotation)))  },
};

const right_track_divisor = 8;
const right_track_rotation = 100.0;
const right_track_matrix: [2][2]i32 = .{
    .{ @intFromFloat(@round(65536/right_track_divisor * @cos(right_track_rotation))),  @intFromFloat(@round(65536/right_track_divisor * -@sin(right_track_rotation)))  },
    .{ @intFromFloat(@round(65536/right_track_divisor * @sin(right_track_rotation))),  @intFromFloat(@round(65536/right_track_divisor * @cos(right_track_rotation)))  },
};

const Layer = enum {
    abc,
    num,
    sym,
    fx,
    qwerty,
    game,
    track,

    pub fn allow_transient(self: Layer) bool {
        return switch (self) {
            .num, .sym, .fx => true,
            .abc, .qwerty, .game, .track => false,
        };
    }

    pub fn color(self: Layer) RGB {
        return switch (self) {
            .abc => .{},
            .num => .{ .b = 4000 },
            .sym => .{ .g = 4000 },
            .fx => .{ .r = 4000, .g = 2000 },
            .qwerty => .{ .r = 4000 },
            .game => .{ .r = 4000, .b = 4000 },
            .track => .{ .r = 4000, .g = 4000, .b = 4000 },
        };
    }
};

const Mapped = union (enum) {
    raw: hid.page.Keyboard,
    unshifted: hid.page.Keyboard,
    shifted: hid.page.Keyboard,
    consumer: hid.page.Consumer, // TODO
    layer: Layer,
    lmb,
    rmb,
    mmb,
    mb4,
    mb5,
    mb6,
    mb7,
    shift,
    ctrl,
    alt,
    track_lock,
    host_left,
    host_right,
    host_toggle,
    unused,
    double_colon,
    double_vbar,
    double_ampersand,
    double_equals,
    double_lessthan,
    double_greaterthan,
    double_question,
    colon_equals,
    exclaim_equals,
    lessthan_equals,
    greaterthan_equals,
    equals_greaterthan,
    question_colon,
    _0x,
};

const Pressed_Key = struct {
    microtick: Microtick,
    source: Key_ID,
    layer: Layer,
    mapped: Mapped,
    report_state: enum {
        unreported,
        reporting,
        reported,
    } = .unreported,
};

var left_available = false;
var right_available = false;
var enabled_location: ?Location = null;

var caps_lock = false;
var num_lock = false;
var scroll_lock = false;

var always_allow_track = false;

var sticky_layer: Layer = .abc;
var transient_layer: ?Layer = null;
var held_layer: ?Layer = null;
var last_tapped_layer: std.enums.EnumFieldStruct(Layer, Microtick, @enumFromInt(0)) = .{};

var pressed_keys: [12]?Pressed_Key = .{ null } ** 12;

const mods = struct {
    const State = struct {
        last_tapped: Microtick = @enumFromInt(0),
        held: bool = false,
        transient: bool = false,
        sticky: bool = false,

        pub fn active(self: State) bool {
            var v = self.sticky;
            if (self.transient or self.held) v = !v;
            return v;
        }
    };

    var shift: State = .{};
    var alt: State = .{};
    var ctrl: State = .{};
    var gui: State = .{};
};

var last_normal_key: Microtick = @enumFromInt(0);

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
    if (enabled_location == Location.local) {
        const usb_leds = usb.keyboard_status.current_report;
        if (usb_leds.caps_lock != caps_lock) {
            caps_lock = usb_leds.caps_lock;
            link.send_caps_lock(caps_lock);
        }
        if (usb_leds.num_lock != num_lock) {
            num_lock = usb_leds.num_lock;
            link.send_num_lock(num_lock);
        }
        if (usb_leds.scroll_lock != scroll_lock) {
            scroll_lock = usb_leds.scroll_lock;
            link.send_scroll_lock(scroll_lock);
        }
    }

    var right_top: RGB = .{};
    if (caps_lock) right_top.r = 4000;
    if (scroll_lock) right_top.g = 4000;
    if (!num_lock) right_top.b = 4000;
    leds.set_top(.right, right_top);

    var right_side: RGB = .{};
    if (mods.shift.active()) right_side.r = 4000;
    if (mods.alt.active()) right_side.g = 4000;
    if (mods.ctrl.active()) right_side.b = 4000;
    leds.set_side(.right, right_side);

    leds.set_top(.left, sticky_layer.color());
    leds.set_side(.left, current_layer().color());
}

pub fn on_received_caps_lock(state: bool) void {
    if (enabled_location == Location.remote) {
        caps_lock = state;
    }
}
pub fn on_received_num_lock(state: bool) void {
    if (enabled_location == Location.remote) {
        num_lock = state;
    }
}
pub fn on_received_scroll_lock(state: bool) void {
    if (enabled_location == Location.remote) {
        scroll_lock = state;
    }
}

pub fn current_layer() Layer {
    const transient_or_sticky = if (transient_layer == sticky_layer) .abc else (transient_layer orelse sticky_layer);
    return if (held_layer == transient_or_sticky) .abc else (held_layer orelse transient_or_sticky);
}

fn key_pressed(key: Key_ID) void {
    log.debug("key pressed: {}", .{ key });
    const layer = current_layer();
    const mapped: Mapped = switch (key.location) {
        .left => switch (layer) { inline else => |l| @field(left_keymap, @tagName(l))[key.row][key.col] },
        .right => switch (layer) { inline else => |l| @field(right_keymap, @tagName(l))[key.row][key.col] },
    };

    const now = Microtick.now();

    for (pressed_keys, 0..) |maybe_pressed, i| {
        if (maybe_pressed) |pressed| {
            if (std.meta.eql(pressed.source, key)) {
                pressed_keys[i] = .{
                    .microtick = now,
                    .source = key,
                    .layer = layer,
                    .mapped = mapped,
                };
                break;
            }
        }
    } else for (pressed_keys, 0..) |maybe_pressed, i| {
        if (maybe_pressed == null) {
            pressed_keys[i] = .{
                .microtick = now,
                .source = key,
                .layer = layer,
                .mapped = mapped,
            };
            break;
        }
    } else {
        log.warn("rollover error; ignoring {} press for {}", .{ key, mapped });
        return;
    }

    switch (mapped) {
        .layer => |l| held_layer = l,
        .shift => mods.shift.held = true,
        .ctrl => mods.ctrl.held = true,
        .alt => mods.alt.held = true,
        else => {},
    }

    push_keyboard_report(.{});
}

fn key_released(key: Key_ID) void {
    log.debug("key released: {}", .{ key });
    const now = Microtick.now();

    const found: *?Pressed_Key = for (pressed_keys, 0..) |maybe_pressed, i| {
        if (maybe_pressed) |pressed| {
            if (std.meta.eql(pressed.source, key)) break &pressed_keys[i];
        }
    } else {
        return;
    };
    
    const pressed: Pressed_Key = found.*.?;
    found.* = null;
    push_keyboard_report(.{});

    const was_tap = pressed.microtick.is_after(last_normal_key) and pressed.microtick.plus(max_tap_duration).is_after(now);

    switch (pressed.mapped) {
        .layer => |layer| {
            if (held_layer == layer) {
                held_layer = null;
            }

            const was_double_tap = was_tap and switch (layer) {
                inline else => |l| @field(last_tapped_layer, @tagName(l)).plus(max_double_tap_interval).is_after(now),
            };

            if (was_double_tap) {
                log.info("Double Tap {s}", .{ @tagName(layer) });
                if (sticky_layer == layer) {
                    return_to_normal();
                } else {
                    sticky_layer = layer;
                    if (transient_layer == layer) transient_layer = null;
                }
            } else if (was_tap) {
                log.info("Tap {s}", .{ @tagName(layer) });
                if (sticky_layer == layer) {
                    return_to_normal();
                } else if (layer.allow_transient()) {
                    if (transient_layer == layer) {
                        transient_layer = null;
                    } else {
                        transient_layer = layer;
                    }
                } else {
                    sticky_layer = layer;
                    if (transient_layer == layer) transient_layer = null;
                }
                switch (layer) {
                    inline else => |l| @field(last_tapped_layer, @tagName(l)) = now,
                }
            } else {
                log.info("Long Press/Chord {s}", .{ @tagName(layer) });
                if (transient_layer == layer) transient_layer = null;
            }
        },
        .shift, .alt, .ctrl => {
            const mod: *mods.State = switch (pressed.mapped) {
                .shift => &mods.shift,
                .alt => &mods.alt,
                .ctrl => &mods.ctrl,
                else => unreachable,
            };
            mod.held = false;
            const was_double_tap = was_tap and mod.last_tapped.plus(max_double_tap_interval).is_after(now);
            if (was_double_tap) {
                log.info("Double Tap {s}", .{ @tagName(pressed.mapped) });
                mod.sticky = !mod.sticky;
                mod.transient = false;
            } else if (was_tap) {
                log.info("Tap {s}", .{ @tagName(pressed.mapped) });
                mod.transient = !mod.transient;
                mod.last_tapped = now;
            } else {
                log.info("Long Press/Chord {s}", .{ @tagName(pressed.mapped) });
                mod.transient = false;
            }
        },

        .raw, .unshifted, .shifted, .consumer => {
            if (pressed.report_state == .unreported) {
                push_keyboard_report(.{ .force = pressed.mapped });
            }
            clear_transient(now);
        },

        .track_lock => {
            always_allow_track = !always_allow_track;
            clear_transient(now);
        },
        
        .host_left => {
            enabled_location = .left;
            clear_transient(now);
        },
        .host_right => {
            enabled_location = .right;
            clear_transient(now);
        },
        .host_toggle => {
            if (enabled_location) |loc| {
                enabled_location = switch (loc) {
                    .left => .right,
                    .right => .left,
                };
            }
            clear_transient(now);
        },

        .double_colon => {
            push_keyboard_report(.{ .force_up = .semicolon_colon });
            push_keyboard_report(.{ .force = .{ .shifted = .semicolon_colon } });
            push_keyboard_report(.{ .force_up = .semicolon_colon });
            push_keyboard_report(.{ .force = .{ .shifted = .semicolon_colon } });
            clear_transient(now);
        },
        .double_vbar => {
            push_keyboard_report(.{ .force_up = .backslash_vbar });
            push_keyboard_report(.{ .force = .{ .shifted = .backslash_vbar } });
            push_keyboard_report(.{ .force_up = .backslash_vbar });
            push_keyboard_report(.{ .force = .{ .shifted = .backslash_vbar } });
            clear_transient(now);
        },
        .double_ampersand => {
            push_keyboard_report(.{ .force_up = .kb_7_ampersand });
            push_keyboard_report(.{ .force = .{ .shifted = .kb_7_ampersand } });
            push_keyboard_report(.{ .force_up = .kb_7_ampersand });
            push_keyboard_report(.{ .force = .{ .shifted = .kb_7_ampersand } });
            clear_transient(now);
        },
        .double_equals => {
            push_keyboard_report(.{ .force_up = .equals_plus });
            push_keyboard_report(.{ .force = .{ .unshifted = .equals_plus } });
            push_keyboard_report(.{ .force_up = .equals_plus });
            push_keyboard_report(.{ .force = .{ .unshifted = .equals_plus } });
            clear_transient(now);
        },
        .double_lessthan => {
            push_keyboard_report(.{ .force_up = .comma_lessthan });
            push_keyboard_report(.{ .force = .{ .shifted = .comma_lessthan } });
            push_keyboard_report(.{ .force_up = .comma_lessthan });
            push_keyboard_report(.{ .force = .{ .shifted = .comma_lessthan } });
            clear_transient(now);
        },
        .double_greaterthan => {
            push_keyboard_report(.{ .force_up = .period_greaterthan });
            push_keyboard_report(.{ .force = .{ .shifted = .period_greaterthan } });
            push_keyboard_report(.{ .force_up = .period_greaterthan });
            push_keyboard_report(.{ .force = .{ .shifted = .period_greaterthan } });
            clear_transient(now);
        },
        .double_question => {
            push_keyboard_report(.{ .force_up = .slash_question });
            push_keyboard_report(.{ .force = .{ .shifted = .slash_question } });
            push_keyboard_report(.{ .force_up = .slash_question });
            push_keyboard_report(.{ .force = .{ .shifted = .slash_question } });
            clear_transient(now);
        },
        .question_colon => {
            push_keyboard_report(.{ .force_up = .slash_question });
            push_keyboard_report(.{ .force = .{ .shifted = .slash_question } });
            push_keyboard_report(.{ .force_up = .semicolon_colon });
            push_keyboard_report(.{ .force = .{ .shifted = .semicolon_colon } });
            clear_transient(now);
        },
        .colon_equals => {
            push_keyboard_report(.{ .force_up = .semicolon_colon });
            push_keyboard_report(.{ .force = .{ .shifted = .semicolon_colon } });
            push_keyboard_report(.{ .force_up = .equals_plus });
            push_keyboard_report(.{ .force = .{ .unshifted = .equals_plus } });
            clear_transient(now);
        },
        .exclaim_equals => {
            push_keyboard_report(.{ .force_up = .kb_1_exclaim });
            push_keyboard_report(.{ .force = .{ .shifted = .kb_1_exclaim } });
            push_keyboard_report(.{ .force_up = .equals_plus });
            push_keyboard_report(.{ .force = .{ .unshifted = .equals_plus } });
            clear_transient(now);
        },
        .lessthan_equals => {
            push_keyboard_report(.{ .force_up = .comma_lessthan });
            push_keyboard_report(.{ .force = .{ .shifted = .comma_lessthan } });
            push_keyboard_report(.{ .force_up = .equals_plus });
            push_keyboard_report(.{ .force = .{ .unshifted = .equals_plus } });
            clear_transient(now);
        },
        .greaterthan_equals => {
            push_keyboard_report(.{ .force_up = .period_greaterthan });
            push_keyboard_report(.{ .force = .{ .shifted = .period_greaterthan } });
            push_keyboard_report(.{ .force_up = .equals_plus });
            push_keyboard_report(.{ .force = .{ .unshifted = .equals_plus } });
            clear_transient(now);
        },
        .equals_greaterthan => {
            push_keyboard_report(.{ .force_up = .equals_plus });
            push_keyboard_report(.{ .force = .{ .unshifted = .equals_plus } });
            push_keyboard_report(.{ .force_up = .period_greaterthan });
            push_keyboard_report(.{ .force = .{ .shifted = .period_greaterthan } });
            clear_transient(now);
        },
        ._0x => {
            push_keyboard_report(.{ .force_up = .kb_0_cparen });
            push_keyboard_report(.{ .force = .{ .unshifted = .kb_0_cparen } });
            push_keyboard_report(.{ .force_up = .kb_x });
            push_keyboard_report(.{ .force = .{ .unshifted = .kb_x } });
            clear_transient(now);
        },

        .lmb, .rmb, .mmb, .mb4, .mb5, .mb6, .mb7, .unused => {},
    }

    push_keyboard_report(.{});
}

fn return_to_normal() void {
    sticky_layer = .abc;
    transient_layer = null;
    mods.shift.sticky = false;
    mods.shift.transient = false;
    mods.ctrl.sticky = false;
    mods.ctrl.transient = false;
    mods.alt.sticky = false;
    mods.alt.transient = false;
    mods.gui.sticky = false;
    mods.gui.transient = false;
}

fn clear_transient(now: Microtick) void {
    mods.shift.transient = false;
    mods.ctrl.transient = false;
    mods.alt.transient = false;
    mods.gui.transient = false;
    transient_layer = null;
    last_normal_key = now;
}

const Keyboard_Report_Options = struct {
    force: ?Mapped = null,
    force_up: ?hid.page.Keyboard = null,
};
fn push_keyboard_report(options: Keyboard_Report_Options) void {
    if (enabled_location != Location.local) {
        usb.keyboard_report.push(.{});
        return;
    }

    var report: usb.default_configuration.keyboard_interface.Report = .{
        .modifiers = .{
            .left_control = mods.ctrl.active(),
            .left_alt = mods.alt.active(),
            .left_gui = mods.gui.active(),
        },
    };

    var want_unshifted: usize = 0;
    var want_shifted: usize = 0;
    for (pressed_keys) |maybe_pressed| {
        if (maybe_pressed) |pressed| {
            switch (pressed.mapped) {
                .unshifted => want_unshifted += 1,
                .shifted => want_shifted += 1,
                else => {},
            }
        }
    }

    if (want_shifted > want_unshifted) {
        report.modifiers.left_shift = true;
    } else if (want_unshifted == 0) {
        report.modifiers.left_shift = mods.shift.active();
    }

    var next_slot: usize = 0;
    if (options.force) |forced| switch (forced) {
        .unshifted => |k| {
            report.modifiers.left_shift = false;
            report.keys[next_slot] = k;
            next_slot += 1;
        },
        .shifted => |k| {
            report.modifiers.left_shift = true;
            report.keys[next_slot] = k;
            next_slot += 1;
        },
        .raw => |k| {
            report.keys[next_slot] = k;
            next_slot += 1;
        },
        else => unreachable,
    };

    for (pressed_keys, 0..) |maybe_pressed, i| {
        if (maybe_pressed) |pressed| {
            if (pressed.report_state == .reported) continue;

            if (next_slot < report.keys.len) {
                const key_to_report: ?hid.page.Keyboard = switch (pressed.mapped) {
                    .unshifted => |k| if (!report.modifiers.left_shift and options.force_up != k) k else null,
                    .shifted => |k| if (report.modifiers.left_shift and options.force_up != k) k else null,
                    .raw => |k| if (options.force_up != k) k else null,
                    else => null,
                };
                if (key_to_report) |k| {
                    report.keys[next_slot] = k;
                    next_slot += 1;
                    pressed_keys[i].?.report_state = .reporting;
                    continue;
                }
            }

            if (pressed.report_state == .reporting) {
                pressed_keys[i].?.report_state = .reported;
            }
        }
    }

    usb.keyboard_report.push(report);
}

pub fn process_keys(location: Location, old_keys_pressed: *[matrix.row_count]matrix.Row_Bitmap, comptime T: type, new_keys_pressed: *const[matrix.row_count]T) void {
    for (0.., old_keys_pressed, new_keys_pressed) |row, *old_ptr, new| {
        const old = old_ptr.*;
        if (old == new) continue;
        for (0..matrix.col_count) |col| {
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
            if (track.z > 0) {
                if (right_track_origin.z == 0) {
                    right_track[0] = track;
                    right_track[1] = track;
                    right_track[2] = track;
                    right_track[3] = track;
                    right_track_origin = rotate_and_scale_right_track(track);
                } else {
                    right_track[3] = right_track[2];
                    right_track[2] = right_track[1];
                    right_track[1] = right_track[0];
                    right_track[0] = track;
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

    if (current_layer() == .track or always_allow_track) {
        const dt = std.math.clamp(@intFromEnum(now) -% @intFromEnum(last_mouse_report_generated), 0, 100_000);

        if (left_track.z > 0 and dt > 0) {
            const dx: i64 = left_track.x - left_track_down.x;
            const dy: i64 = left_track.y - left_track_down.y;

            const dxt = dx * dt;
            const dyt = dy * dt;

            left_track_remainder_x += (dxt * left_track_matrix[0][0] + dyt * left_track_matrix[0][1]) >> 16;
            left_track_remainder_y += (dxt * left_track_matrix[1][0] + dyt * left_track_matrix[1][1]) >> 16;

            const rdxtc = std.math.clamp(left_track_remainder_x >> 18, -60, 60);
            const rdytc = std.math.clamp(left_track_remainder_y >> 18, -60, 60);

            left_track_remainder_x -= rdxtc << 18;
            left_track_remainder_y -= rdytc << 18;

            report.x += @intCast(rdxtc);
            report.y += @intCast(rdytc);
        }

        if (right_track_origin.z > 0) {
            const right = rotate_and_scale_right_track(average_right_track());
            const dx: i8 = @intCast(std.math.clamp(right.x - right_track_origin.x, -60, 60));
            const dy: i8 = @intCast(std.math.clamp(right.y - right_track_origin.y, -60, 60));

            right_track_origin.x += dx;
            right_track_origin.y += dy;

            report.x += dx;
            report.y += dy;
        }
    }

    for (pressed_keys) |maybe_pressed| {
        if (maybe_pressed) |pressed| {
            switch (pressed.mapped) {
                .lmb => report.left_btn = true,
                .rmb => report.right_btn = true,
                .mmb => report.middle_btn = true,
                .mb4 => report.btn_4 = true,
                .mb5 => report.btn_5 = true,
                .mb6 => report.btn_6 = true,
                .mb7 => report.btn_7 = true,
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
        .x = @intCast(x >> 4),
        .y = @intCast(y >> 4),
        .z = @intCast(z >> 4),
    };
}

fn rotate_and_scale_right_track(t: Track) Track {
    const x = t.x;
    const y = t.y;
    const rx = (x * right_track_matrix[0][0] + y * right_track_matrix[0][1]);
    const ry = (x * right_track_matrix[1][0] + y * right_track_matrix[1][1]);

    return .{
        .x = @intCast(rx >> 16),
        .y = @intCast(ry >> 16),
        .z = t.z,
    };
}

fn set_enabled_location(maybe_loc: ?Location) void {
    enabled_location = maybe_loc;
    log.info("using host: {?}", .{ maybe_loc });
}

pub fn on_usb_state_changed(loc: Location, active: bool) void {
    log.info("{} USB state: {}", .{ loc, active });
    switch (loc) {
        .left => left_available = active,
        .right => right_available = active,
    }
    if (!left_available and !right_available) {
        set_enabled_location(null);
    } else if (left_available and !right_available) {
        set_enabled_location(.left);
    } else if (right_available and !left_available) {
        set_enabled_location(.right);
    }
}

const log = std.log.scoped(.logic);

const Mouse_Report = usb.default_configuration.mouse_interface.Report;
const RGB = leds.RGB;
const leds = @import("leds.zig");
const Location = util.Location;
const Track = util.Track;
const Key_ID = util.Key_ID;
const link = @import("link.zig");
const matrix = @import("matrix.zig");
const util = @import("util.zig");
const hid = microbe.usb.hid;
const usb = @import("usb.zig");
const Microtick = microbe.Microtick;
const microbe = @import("microbe");
const std = @import("std");
