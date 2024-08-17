const include_switches = false;
const include_caps = true;

pub const edge_radius = 1.5;
pub const plate_thickness = 5;
pub const switch_plate_inset = 0.9;
const fs = 0.25;

const extra_height: f64 = 4;

const home_radius: f64 = 200;
const keycap_height: f64 = 19.2; // above top of plate; including switch

const home_spacing: f64 = 19.5;
const top_key_spacing: f64 = 16;

const columns = [_]Column_Params {
    .{
        .name = "pinky extra column",
        .radius = 60,
        .displacement_angle = 6,
        .displacement_y = -11,
        .displacement_z = 5,
        //.key_width = 1.2,
        //.cap_width = 1.25,
    },
    .{
        .name = "pinky column",
        .radius = 60,
        .displacement_angle = 5,
        .displacement_y = -11,
        .displacement_z = 5,
        .key_width = 0.95,
    },
    .{
        .name = "ring finger column",
        .radius = 65,
        .displacement_angle = 3,
        .displacement_y = -3,
        .displacement_z = 1,
        .key_width = 1.15,
    },
    .{
        .name = "middle finger column",
        .radius = 55,
        .displacement_angle = 1,
        .displacement_y = 1,
        .displacement_z = -2,
        .key_width = 1.08,
    },
    .{
        .name = "index finger column",
        .radius = 65,
        .displacement_angle = 2,
        .displacement_y = -1,
        .displacement_z = 2,
    },
    .{
        .name = "index finger extra column",
        .radius = 60,
        .displacement_angle = 5,
        .displacement_y = -4,
        .displacement_z = 3,
        //.key_width = 1.25,
    },
};

const Column_Params = struct {
    name: []const u8,
    num_above_home: u8 = 1,
    num_below_home: u8 = 1,
    radius: f64,
    displacement_angle: f64 = 0,
    displacement_x: f64 = 0,
    displacement_y: f64 = 0,
    displacement_z: f64 = 0,
    key_width: f64 = 1,
    cap_width: f64 = 1,
};

const Model = enum {
    left,
    right,
};

pub fn main() !void {
    defer std.debug.assert(gpa.deinit() == .ok);

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var iter = try std.process.argsWithAllocator(gpa.allocator());
    defer iter.deinit();
    _ = iter.next(); // program name

    const model_name = iter.next() orelse return error.ModelNotSpecified;
    const model = std.meta.stringToEnum(Model, model_name) orelse return error.UnrecognizedModelName;

    const output_path = iter.next() orelse return error.OutputPathNotSpecified;
    var file = try std.fs.cwd().createFile(output_path, .{});
    defer file.close();

    SCAD.scad = .{
        .element_alloc = arena.allocator(),
        .list_alloc = gpa.allocator(),
    };

    var root: Element = .{ ._union = .{ .parent = null }};

    switch (model) {
        .left => try render(&root, false),
        .right => try render(&root, true),
    }

    try file.writer().print(
        \\edge_radius = {d};
        \\plate_thickness = {d};
        \\switch_plate_inset = {d};
        \\$fs = {d};
        \\
        \\
        , .{ edge_radius, plate_thickness, switch_plate_inset, fs });

    try root.write(file.writer().any(), 0, true);
    try file.writer().writeAll(@embedFile("modules.scad"));
}

pub fn render(root: *Element, is_right: bool) !void {
    const flip: f64 = if (is_right) -1 else 1;

    const droot = root.difference();
    const uroot = droot.@"union"();

    const keys = render_keys_except_thumbs(uroot, is_right);
    for (keys) |column_keys| {
        for (column_keys[0..column_keys.len-1], column_keys[1..]) |k0, k1| {
            hull_between_keys_in_column(uroot, k0, k1, is_right);
        }
    }

    for (keys[0..keys.len-1], keys[1..]) |c0_keys, c1_keys| {
        for (c0_keys, c1_keys) |k0, k1| {
            hull_between_keys_in_row(uroot, k0, k1, is_right);
        }
        for (c0_keys[0..c0_keys.len-1], c0_keys[1..], c1_keys[0..c1_keys.len-1], c1_keys[1..]) |k00, k01, k10, k11| {
            hull_between_4_keys(uroot, k00, k01, k10, k11, is_right);
        }
    }

    const thumb_root = uroot.translate(keys[5][1].transform_to_world(.{ -6 * flip, 6, -10 }));
    const thumb_keys = render_thumb_keys(thumb_root, is_right);

    for (thumb_keys[0..thumb_keys.len-1], thumb_keys[1..]) |k0, k1| {
        hull_between_keys_in_row(uroot, k0, k1, is_right);
    }

    render_cirque(uroot, keys, thumb_keys, is_right);

    render_wall(uroot, &.{
        keys[0][0].transform_to_world(.{ keys[0][0]._switch_plate.x0() * flip, keys[0][0]._switch_plate.y0(), edge_radius - plate_thickness }),
        keys[0][0].transform_to_world(.{ keys[0][0]._switch_plate.x0() * flip, keys[0][0]._switch_plate.y1(), edge_radius - plate_thickness }),
        keys[0][1].transform_to_world(.{ keys[0][1]._switch_plate.x0() * flip, keys[0][1]._switch_plate.y0(), edge_radius - plate_thickness }),
        keys[0][1].transform_to_world(.{ keys[0][1]._switch_plate.x0() * flip, keys[0][1]._switch_plate.y1(), edge_radius - plate_thickness }),
        keys[0][2].transform_to_world(.{ keys[0][2]._switch_plate.x0() * flip, keys[0][2]._switch_plate.y0(), edge_radius - plate_thickness }),
        keys[0][2].transform_to_world(.{ keys[0][2]._switch_plate.x0() * flip, keys[0][2]._switch_plate.y1(), edge_radius - plate_thickness }),
        keys[0][2].transform_to_world(.{ keys[0][2]._switch_plate.x1() * flip, keys[0][2]._switch_plate.y1(), edge_radius - plate_thickness }),
        keys[1][2].transform_to_world(.{ keys[1][2]._switch_plate.x0() * flip, keys[1][2]._switch_plate.y1(), edge_radius - plate_thickness }),
        keys[1][2].transform_to_world(.{ keys[1][2]._switch_plate.x1() * flip, keys[1][2]._switch_plate.y1(), edge_radius - plate_thickness }),
        keys[2][2].transform_to_world(.{ keys[2][2]._switch_plate.x0() * flip, keys[2][2]._switch_plate.y1(), edge_radius - plate_thickness }),
        keys[2][2].transform_to_world(.{ keys[2][2]._switch_plate.x1() * flip, keys[2][2]._switch_plate.y1(), edge_radius - plate_thickness }),
        keys[3][2].transform_to_world(.{ keys[3][2]._switch_plate.x0() * flip, keys[3][2]._switch_plate.y1(), edge_radius - plate_thickness }),
        keys[3][2].transform_to_world(.{ keys[3][2]._switch_plate.x1() * flip, keys[3][2]._switch_plate.y1(), edge_radius - plate_thickness }),
        keys[4][2].transform_to_world(.{ keys[4][2]._switch_plate.x0() * flip, keys[4][2]._switch_plate.y1(), edge_radius - plate_thickness }),
        keys[4][2].transform_to_world(.{ keys[4][2]._switch_plate.x1() * flip, keys[4][2]._switch_plate.y1(), edge_radius - plate_thickness }),
        keys[5][2].transform_to_world(.{ keys[5][2]._switch_plate.x0() * flip, keys[5][2]._switch_plate.y1(), edge_radius - plate_thickness }),
        keys[5][2].transform_to_world(.{ keys[5][2]._switch_plate.x1() * flip, keys[5][2]._switch_plate.y1(), edge_radius - plate_thickness }),
        keys[5][2].transform_to_world(.{ keys[5][2]._switch_plate.x1() * flip, keys[5][2]._switch_plate.y0(), edge_radius - plate_thickness }),
        keys[5][1].transform_to_world(.{ keys[5][1]._switch_plate.x1() * flip, keys[5][1]._switch_plate.y1(), edge_radius - plate_thickness }),
        keys[5][1].transform_to_world(.{ keys[5][1]._switch_plate.x1() * flip, keys[5][1]._switch_plate.y0(), edge_radius - plate_thickness }),
        keys[5][0].transform_to_world(.{ keys[5][0]._switch_plate.x1() * flip, keys[5][0]._switch_plate.y1(), edge_radius - plate_thickness }),
        keys[5][0].transform_to_world(.{ keys[5][0]._switch_plate.x1() * flip, keys[5][0]._switch_plate.y0(), edge_radius - plate_thickness }),
        thumb_keys[1].transform_to_world(.{ thumb_keys[1]._switch_plate.x1() * flip, thumb_keys[1]._switch_plate.y1(), edge_radius - plate_thickness }),
        thumb_keys[2].transform_to_world(.{ thumb_keys[2]._switch_plate.x0() * flip, thumb_keys[2]._switch_plate.y1(), edge_radius - plate_thickness }),
        thumb_keys[2].transform_to_world(.{ thumb_keys[2]._switch_plate.x1() * flip, thumb_keys[2]._switch_plate.y1(), edge_radius - plate_thickness }),
        thumb_keys[2].transform_to_world(.{ thumb_keys[2]._switch_plate.x1() * flip, thumb_keys[2]._switch_plate.y1(), -edge_radius }),
        thumb_keys[2].transform_to_world(.{ thumb_keys[2]._switch_plate.x1() * flip, thumb_keys[2]._switch_plate.y0(), -edge_radius }),
    });

    // fill in hole between thumb keys and keywell
    plate_hull(uroot, &.{
        .{ keys[3][0], keys[3][0]._switch_plate.x1() * flip, keys[3][0]._switch_plate.y0() },
        .{ keys[4][0], keys[4][0]._switch_plate.x0() * flip, keys[4][0]._switch_plate.y0() },
        .{ thumb_keys[0], thumb_keys[0]._switch_plate.x0() * flip, thumb_keys[0]._switch_plate.y0() },
        .{ thumb_keys[0], thumb_keys[0]._switch_plate.x0() * flip, thumb_keys[0]._switch_plate.y1() },
    });
    plate_hull(uroot, &.{
        .{ keys[4][0], keys[4][0]._switch_plate.x0() * flip, keys[4][0]._switch_plate.y0() },
        .{ keys[4][0], keys[4][0]._switch_plate.x1() * flip, keys[4][0]._switch_plate.y0() },
        .{ thumb_keys[0], thumb_keys[0]._switch_plate.x0() * flip, thumb_keys[0]._switch_plate.y1() },
    });
    plate_hull(uroot, &.{
        .{ keys[4][0], keys[4][0]._switch_plate.x1() * flip, keys[4][0]._switch_plate.y0() },
        .{ keys[5][0], keys[5][0]._switch_plate.x0() * flip, keys[5][0]._switch_plate.y0() },
        .{ thumb_keys[0], thumb_keys[0]._switch_plate.x0() * flip, thumb_keys[0]._switch_plate.y1() },
    });
    plate_hull(uroot, &.{
        .{ keys[5][0], keys[5][0]._switch_plate.x0() * flip, keys[5][0]._switch_plate.y0() },
        .{ keys[5][0], keys[5][0]._switch_plate.x1() * flip, keys[5][0]._switch_plate.y0() },
        .{ thumb_keys[0], thumb_keys[0]._switch_plate.x0() * flip, thumb_keys[0]._switch_plate.y1() },
        .{ thumb_keys[1], thumb_keys[1]._switch_plate.x1() * flip, thumb_keys[0]._switch_plate.y1() },
    });

    const board_transform = droot.color("green").translate(.{ 80 * flip, -10, 1.29 });
    _ = board_transform.cube(.{ 60, 86, 2.6 });
    _ = board_transform.translate(.{ 17 * flip, 38, 0 }).cube(.{ 15, 20, 6 });
    _ = board_transform.translate(.{ -17 * flip, 37, 0 }).cube(.{ 15, 20, 6 });

    const link_connector = board_transform.hull();
    _ = link_connector.translate(.{ 17 - 5.6/2.0, 53, 1.7 + 1.3 }).rotate(.{ 90, 0, 0 }).cylinder(20, 1.75, 1.75);
    _ = link_connector.translate(.{ 17 + 5.6/2.0, 53, 1.7 + 1.3 }).rotate(.{ 90, 0, 0 }).cylinder(20, 1.75, 1.75);

    const usb_connector = board_transform.hull();
    _ = usb_connector.translate(.{ -17 - 5.6/2.0, 53, 1.7 + 1.3 }).rotate(.{ 90, 0, 0 }).cylinder(20, 1.75, 1.75);
    _ = usb_connector.translate(.{ -17 + 5.6/2.0, 53, 1.7 + 1.3 }).rotate(.{ 90, 0, 0 }).cylinder(20, 1.75, 1.75);

    // back LED
    _ = board_transform.translate(.{ 0, 53, 0.4 + 1.3 }).cube(.{ 2, 50, 1 });
    _ = board_transform.translate(.{ 0, 38, 0.4 + 1.3 }).cube(.{ 5, 10, 1 });

    // side LED
    _ = board_transform.translate(.{ 20 * flip, 10, 0.4 + 1.3 }).cube(.{ 50, 2, 1 });
    _ = board_transform.translate(.{ 25 * flip, 10, 0.4 + 1.3 }).cube(.{ 10, 5, 1 });

    // mounting holes
    _ = board_transform.translate(.{ 26 * flip, 25, 1.29 }).cylinder(6, 1.75, 1.75);
    _ = board_transform.translate(.{ 26 * flip, -25, 1.29 }).cylinder(6, 1.75, 1.75);
    _ = board_transform.translate(.{ -10 * flip, -38, 1.29 }).cylinder(6, 1.75, 1.75);

    const mounting_holes_root = uroot.translate(.{ 80 * flip, -10, 1.29 });
    _ = mounting_holes_root.translate(.{ 26 * flip, 25, 1.29 }).cylinder(16, 4, 1.5);
    _ = mounting_holes_root.translate(.{ 26 * flip, -25, 1.29 }).cylinder(16, 4, 1.5);
    _ = mounting_holes_root.translate(.{ -10 * flip, -38, 1.29 }).cylinder(16, 4, 1.5);

    render_support_base(root, &.{
        keys[0][0].transform_to_world(.{ keys[0][0]._switch_plate.x0() * flip, keys[0][0]._switch_plate.y0(), edge_radius - plate_thickness }),
        keys[0][0].transform_to_world(.{ keys[0][0]._switch_plate.x0() * flip, keys[0][0]._switch_plate.y1(), edge_radius - plate_thickness }),
        keys[0][1].transform_to_world(.{ keys[0][1]._switch_plate.x0() * flip, keys[0][1]._switch_plate.y0(), edge_radius - plate_thickness }),
        keys[0][1].transform_to_world(.{ keys[0][1]._switch_plate.x0() * flip, keys[0][1]._switch_plate.y1(), edge_radius - plate_thickness }),
        keys[0][2].transform_to_world(.{ keys[0][2]._switch_plate.x0() * flip, keys[0][2]._switch_plate.y0(), edge_radius - plate_thickness }),
        keys[0][2].transform_to_world(.{ keys[0][2]._switch_plate.x0() * flip, keys[0][2]._switch_plate.y1(), edge_radius - plate_thickness }),
        keys[0][2].transform_to_world(.{ keys[0][2]._switch_plate.x1() * flip, keys[0][2]._switch_plate.y1(), edge_radius - plate_thickness }),
        keys[1][2].transform_to_world(.{ keys[1][2]._switch_plate.x0() * flip, keys[1][2]._switch_plate.y1(), edge_radius - plate_thickness }),
        keys[1][2].transform_to_world(.{ keys[1][2]._switch_plate.x1() * flip, keys[1][2]._switch_plate.y1(), edge_radius - plate_thickness }),
        keys[2][2].transform_to_world(.{ keys[2][2]._switch_plate.x0() * flip, keys[2][2]._switch_plate.y1(), edge_radius - plate_thickness }),
        keys[2][2].transform_to_world(.{ keys[2][2]._switch_plate.x1() * flip, keys[2][2]._switch_plate.y1(), edge_radius - plate_thickness }),
        keys[3][2].transform_to_world(.{ keys[3][2]._switch_plate.x0() * flip, keys[3][2]._switch_plate.y1(), edge_radius - plate_thickness }),
        keys[3][2].transform_to_world(.{ keys[3][2]._switch_plate.x1() * flip, keys[3][2]._switch_plate.y1(), edge_radius - plate_thickness }),
        keys[4][2].transform_to_world(.{ keys[4][2]._switch_plate.x0() * flip, keys[4][2]._switch_plate.y1(), edge_radius - plate_thickness }),
        keys[4][2].transform_to_world(.{ keys[4][2]._switch_plate.x1() * flip, keys[4][2]._switch_plate.y1(), edge_radius - plate_thickness }),
        keys[5][2].transform_to_world(.{ keys[5][2]._switch_plate.x0() * flip, keys[5][2]._switch_plate.y1(), edge_radius - plate_thickness }),
        keys[5][2].transform_to_world(.{ keys[5][2]._switch_plate.x1() * flip, keys[5][2]._switch_plate.y1(), edge_radius - plate_thickness }),
        keys[5][2].transform_to_world(.{ keys[5][2]._switch_plate.x1() * flip, keys[5][2]._switch_plate.y0(), edge_radius - plate_thickness }),
        keys[5][1].transform_to_world(.{ keys[5][1]._switch_plate.x1() * flip, keys[5][1]._switch_plate.y1(), edge_radius - plate_thickness }),
        keys[5][1].transform_to_world(.{ keys[5][1]._switch_plate.x1() * flip, keys[5][1]._switch_plate.y0(), edge_radius - plate_thickness }),
        keys[5][0].transform_to_world(.{ keys[5][0]._switch_plate.x1() * flip, keys[5][0]._switch_plate.y1(), edge_radius - plate_thickness }),
        keys[5][0].transform_to_world(.{ keys[5][0]._switch_plate.x1() * flip, keys[5][0]._switch_plate.y0(), edge_radius - plate_thickness }),
        thumb_keys[1].transform_to_world(.{ thumb_keys[1]._switch_plate.x1() * flip, thumb_keys[1]._switch_plate.y1(), edge_radius - plate_thickness }),
        thumb_keys[2].transform_to_world(.{ thumb_keys[2]._switch_plate.x0() * flip, thumb_keys[2]._switch_plate.y1(), edge_radius - plate_thickness }),
        thumb_keys[2].transform_to_world(.{ thumb_keys[2]._switch_plate.x1() * flip, thumb_keys[2]._switch_plate.y1(), edge_radius - plate_thickness }),
        thumb_keys[2].transform_to_world(.{ thumb_keys[2]._switch_plate.x1() * flip, thumb_keys[2]._switch_plate.y1(), -edge_radius }),
        thumb_keys[2].transform_to_world(.{ thumb_keys[2]._switch_plate.x1() * flip, thumb_keys[2]._switch_plate.y0(), -edge_radius }),
        thumb_keys[0].transform_to_world(.{ thumb_keys[0]._switch_plate.x0() * flip, thumb_keys[0]._switch_plate.y0(), -edge_radius }),
        //keys[4][0].transform_to_world(.{ keys[4][0]._switch_plate.x1() * flip, keys[4][0]._switch_plate.y0(), edge_radius - plate_thickness }),
        //keys[4][0].transform_to_world(.{ keys[4][0]._switch_plate.x0() * flip, keys[4][0]._switch_plate.y0(), edge_radius - plate_thickness }),
        //keys[3][0].transform_to_world(.{ keys[3][0]._switch_plate.x1() * flip, keys[3][0]._switch_plate.y0(), edge_radius - plate_thickness }),
        //keys[3][0].transform_to_world(.{ keys[3][0]._switch_plate.x0() * flip, keys[3][0]._switch_plate.y0(), edge_radius - plate_thickness }),
        keys[2][0].transform_to_world(.{ keys[2][0]._switch_plate.x1() * flip, keys[2][0]._switch_plate.y0(), edge_radius - plate_thickness }),
        keys[2][0].transform_to_world(.{ keys[2][0]._switch_plate.x0() * flip, keys[2][0]._switch_plate.y0(), edge_radius - plate_thickness }),
        keys[1][0].transform_to_world(.{ keys[1][0]._switch_plate.x1() * flip, keys[1][0]._switch_plate.y0(), edge_radius - plate_thickness }),
        keys[1][0].transform_to_world(.{ keys[1][0]._switch_plate.x0() * flip, keys[1][0]._switch_plate.y0(), edge_radius - plate_thickness }),
        keys[0][0].transform_to_world(.{ keys[0][0]._switch_plate.x1() * flip, keys[0][0]._switch_plate.y0(), edge_radius - plate_thickness }),
        keys[0][0].transform_to_world(.{ keys[0][0]._switch_plate.x0() * flip, keys[0][0]._switch_plate.y0(), edge_radius - plate_thickness }),
    });
}

pub fn render_keys_except_thumbs(root: *Element, is_right: bool) []const[]*Element {
    var retval = SCAD.scad.element_alloc.alloc([]*Element, columns.len) catch @panic("OOM");

    for (0.., columns) |c, col| {
        var cf: f64 = @floatFromInt(c);
        if (c == 0) {
            cf = cf - col.key_width/2 + 0.5;
        } else if (c == columns.len - 1) {
            cf = cf + col.key_width/2 - 0.5;
        }

        retval[c] = SCAD.scad.element_alloc.alloc(*Element, col.num_above_home + col.num_below_home + 1) catch @panic("OOM");

        const roll_direction: f64 = if (is_right) 1 else -1;
        const roll_angle: f64 = roll_direction * cf * 180 * home_spacing / ((home_radius - keycap_height) * std.math.pi);
        var pitch_root = root
            .translate(.{ 0, 0, home_radius + extra_height })
            .rotate(.{ 0, roll_angle, 0 })
            .translate(.{
                col.displacement_x,
                col.displacement_y,
                col.displacement_z + col.radius - home_radius,
            });

        for (0 .. col.num_above_home + 1) |r| {
            const rf: f64 = @floatFromInt(r);
            const pitch_angle = col.displacement_angle + rf * 180 * top_key_spacing / ((col.radius - keycap_height) * std.math.pi);

            const plate = pitch_root
                .rotate(.{ pitch_angle, 0, 0 })
                .translate(.{ 0, 0, -col.radius })
                .switch_plate(col.key_width, 1);

            if (include_switches) {
                const sw = plate.key_switch();
                if (include_caps) _ = sw.key_cap(col.cap_width, 1);
            }

            retval[c][col.num_below_home + r] = plate;
        }

        for (1 .. col.num_below_home + 1) |r| {
            const rf: f64 = @floatFromInt(r);
            const pitch_angle = col.displacement_angle - rf * 180 * top_key_spacing / ((col.radius - keycap_height) * std.math.pi);

            const plate = pitch_root
                .rotate(.{ pitch_angle, 0, 0 })
                .translate(.{ 0, 0, -col.radius })
                .switch_plate(col.key_width, 1);

            if (include_switches) {
                const sw = plate.key_switch();
                if (include_caps) _ = sw.key_cap(col.cap_width, 1);
            }

            retval[c][col.num_below_home - r] = plate;
        }
    }

    return retval;
}

pub fn render_thumb_keys(root: *Element, is_right: bool) []*Element {
    var retval = SCAD.scad.element_alloc.alloc(*Element, 3) catch @panic("OOM");

    const adjusted_root = root
        .translate(.{ 0, -70, 0 })
        .rotate(if (is_right)
            .{ 10, -15, 35 }
        else 
            .{ 10, 15, -35 }
        );

    for (0..3) |n| {
        var nf: f64 = @floatFromInt(n);
        nf -= 1;
        if (is_right) nf *= -1;

        const plate = adjusted_root
            .translate(.{ nf * 20, 0, 0 })
            .switch_plate(1, 1.25);

        if (include_switches) {
            var sw = plate.key_switch();
            if (include_caps) _ = sw.key_cap(1, 1.25);
        }

        retval[n] = plate;
    }

    return retval;
}

pub fn render_cirque(root: *Element, keys: []const []const *Element, thumb_keys: []const *Element, is_right: bool) void {
    const flip: f64 = if (is_right) -1 else 1;

    const droot = root.difference();
    const iroot = droot.intersection();
    const uroot = iroot.@"union"();
    _ = iroot.translate(.{ 0, 0, 500 }).cube(.{ 1000, 1000, 1000 });

    _ = uroot.apply_transforms(thumb_keys[0]).translate(.{ 0, -40, 0 }).module("cirque_plate");
    render_cirque_hull_with_thumb_keys(uroot, thumb_keys, is_right);
    render_cirque_hull_with_col3(uroot, thumb_keys, keys, is_right);
    render_cirque_hull_with_col2(uroot, thumb_keys, keys, is_right);
    render_cirque_hull_with_col1(uroot, thumb_keys, keys, is_right);
    render_cirque_hull_with_col0(uroot, thumb_keys, keys, is_right);

    _ = droot.apply_transforms(thumb_keys[0]).translate(.{ 0, -40, 0 }).module("cirque_plate_holes");

    _ = droot.translate(.{ 60 * flip, -50, 0}).module("cable_guide");
    //_ = droot.translate(.{ 70 * flip, -60, 0}).rotate(.{ 0, 0, -30 * flip }).module("cable_guide");
    
}

fn render_cirque_hull_with_thumb_keys(root: *Element, thumb_keys: []const *Element, is_right: bool) void {
    const flip: f64 = if (is_right) -1 else 1;
    const hull = root.hull();

    const k0_root = hull.apply_transforms(thumb_keys[0]);
    _ = k0_root.translate(.{ 0, -40, 0 }).rotate(.{ 0, 0, -45 * flip }).module("half_cirque_plate");
    _ = k0_root.translate(.{ thumb_keys[0]._switch_plate.x0() * flip, thumb_keys[0]._switch_plate.y0(), 0 }).module("edge_capsule");

    const k2_root = hull.apply_transforms(thumb_keys[2]);
    _ = k2_root.translate(.{ thumb_keys[2]._switch_plate.x1() * flip, thumb_keys[2]._switch_plate.y0(), 0 }).module("edge_capsule");

    render_wall(hull, &.{
        thumb_keys[2].transform_to_world(.{ thumb_keys[2]._switch_plate.x1() * flip, thumb_keys[2]._switch_plate.y0(), -edge_radius }),
    });
}

fn render_cirque_hull_with_col3(root: *Element, thumb_keys: []const *Element, keys: []const []const *Element, is_right: bool) void {
    const flip: f64 = if (is_right) -1 else 1;
    const hull = root.hull();

    const k0_root = hull.apply_transforms(thumb_keys[0]);
    _ = k0_root.translate(.{ 0, -40, 0 }).rotate(.{ 0, 0, 104 * flip }).module("half_cirque_plate");

    plate_hull(hull, &.{
        .{ thumb_keys[0], thumb_keys[0]._switch_plate.x0() * flip, thumb_keys[0]._switch_plate.y0() },

        .{ keys[3][0], keys[3][0]._switch_plate.x0(), keys[3][0]._switch_plate.y0() },
        .{ keys[3][0], keys[3][0]._switch_plate.x1(), keys[3][0]._switch_plate.y0() },

        .{ keys[2][0], keys[2][0]._switch_plate.x1() * flip, keys[2][0]._switch_plate.y0() },
    });
}

fn render_cirque_hull_with_col2(root: *Element, thumb_keys: []const *Element, keys: []const []const *Element, is_right: bool) void {
    const flip: f64 = if (is_right) -1 else 1;
    const hull = root.hull();

    const k0_root = hull.apply_transforms(thumb_keys[0]);
    _ = k0_root.translate(.{ 0, -40, 0 }).rotate(.{ 0, 0, 104 * flip }).module("half_cirque_plate");

    plate_hull(hull, &.{
        .{ keys[2][0], keys[2][0]._switch_plate.x0(), keys[2][0]._switch_plate.y0() },
        .{ keys[2][0], keys[2][0]._switch_plate.x1(), keys[2][0]._switch_plate.y0() },

        .{ keys[1][0], keys[1][0]._switch_plate.x1() * flip, keys[1][0]._switch_plate.y0() },
    });
}

fn render_cirque_hull_with_col1(root: *Element, thumb_keys: []const *Element, keys: []const []const *Element, is_right: bool) void {
    const flip: f64 = if (is_right) -1 else 1;
    const hull = root.hull();

    const k0_root = hull.apply_transforms(thumb_keys[0]);
    _ = k0_root.translate(.{ 0, -40, 0 }).rotate(.{ 0, 0, 144 * flip }).module("half_cirque_plate");

    plate_hull(hull, &.{
        .{ keys[1][0], keys[1][0]._switch_plate.x0(), keys[1][0]._switch_plate.y0() },
        .{ keys[1][0], keys[1][0]._switch_plate.x1(), keys[1][0]._switch_plate.y0() },
    });
}

fn render_cirque_hull_with_col0(root: *Element, thumb_keys: []const *Element, keys: []const []const *Element, is_right: bool) void {
    const flip: f64 = if (is_right) -1 else 1;
    const hull = root.hull();

    const k0_root = hull.apply_transforms(thumb_keys[0]);
    _ = k0_root.translate(.{ 0, -40, 0 }).rotate(.{ 0, 0, 140 * flip }).module("half_cirque_plate");

    plate_hull(hull, &.{
        .{ keys[0][0], keys[0][0]._switch_plate.x0(), keys[0][0]._switch_plate.y0() },
        .{ keys[0][0], keys[0][0]._switch_plate.x1(), keys[0][0]._switch_plate.y0() },
    });

    render_wall(hull, &.{
        keys[0][0].transform_to_world(.{ keys[0][0]._switch_plate.x0() * flip, keys[0][0]._switch_plate.y0(), edge_radius - plate_thickness }),
    });
}

pub fn render_wall(root: *Element, points: []const @Vector(3, f64)) void {
    if (points.len == 1) {
        const p0 = points[0];
        _ = root
            .translate(.{ p0[0], p0[1], 0 })
            .cylinder(p0[2], edge_radius * (p0[2] / 10), edge_radius);
        return;
    }

    for (points[0..points.len - 1], points[1..]) |p0, p1| {
        const hull = root.hull();

        _ = hull.translate(.{ p0[0], p0[1], 0 })
            .cylinder(p0[2], edge_radius * (p0[2] / 10), edge_radius);

        _ = hull.translate(.{ p1[0], p1[1], 0 })
            .cylinder(p1[2], edge_radius * (p1[2] / 10), edge_radius);
    }
}

fn render_support_base(root: *Element, points: []const @Vector(3, f64)) void {
    const pts = SCAD.scad.element_alloc.alloc(@Vector(2, f64), points.len) catch @panic("OOM");
    for (points, pts) |src, *dest| {
        dest.* = .{ src[0], src[1] };
    }

    const support_diff = root.difference();
    _ = support_diff.linear_extrude(0.5).polygon(pts);
    const minkowski = support_diff.minkowski();
    const minkowski_base = minkowski.@"union"();
    render_wall(minkowski_base, points);
    _ = minkowski.cylinder(1, 3, 3);
}


fn hull_between_keys_in_column(root: *Element, k0: *Element, k1: *Element, is_right: bool) void {
    const flip: f64 = if (is_right) -1 else 1;
    plate_hull(root, &.{
        .{ k0, k0._switch_plate.x0() * flip, k0._switch_plate.y1() },
        .{ k0, k0._switch_plate.x1() * flip, k0._switch_plate.y1() },
        .{ k1, k1._switch_plate.x0() * flip, k1._switch_plate.y0() },
        .{ k1, k1._switch_plate.x1() * flip, k1._switch_plate.y0() },
    });
}

fn hull_between_keys_in_row(root: *Element, k0: *Element, k1: *Element, is_right: bool) void {
    const flip: f64 = if (is_right) -1 else 1;
    plate_hull(root, &.{
        .{ k0, k0._switch_plate.x1() * flip, k0._switch_plate.y0() },
        .{ k0, k0._switch_plate.x1() * flip, k0._switch_plate.y1() },
        .{ k1, k1._switch_plate.x0() * flip, k1._switch_plate.y0() },
        .{ k1, k1._switch_plate.x0() * flip, k1._switch_plate.y1() },
    });
}

fn hull_between_4_keys(root: *Element, k00: *Element, k01: *Element, k10: *Element, k11: *Element, is_right: bool) void {
    const flip: f64 = if (is_right) -1 else 1;
    plate_hull(root, &.{
        .{ k00, k00._switch_plate.x1() * flip, k00._switch_plate.y1() },
        .{ k01, k01._switch_plate.x1() * flip, k01._switch_plate.y0() },
        .{ k10, k10._switch_plate.x0() * flip, k10._switch_plate.y1() },
        .{ k11, k11._switch_plate.x0() * flip, k11._switch_plate.y0() },
    });
}

fn plate_hull(root: *Element, points: []const struct { *Element, f64, f64 }) void {
    const hull = root.hull();
    for (points) |p| {
        _ = hull.translate(p[0].transform_to_world(.{ p[1], p[2], -edge_radius })).module("edge_sphere");
        _ = hull.translate(p[0].transform_to_world(.{ p[1], p[2], edge_radius - plate_thickness })).module("edge_sphere");
    }
}

var gpa: std.heap.GeneralPurposeAllocator(.{}) = .{};

const Element = SCAD.Element;
const SCAD = @import("SCAD.zig");
const std = @import("std");
