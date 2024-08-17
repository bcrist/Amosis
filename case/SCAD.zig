
element_alloc: std.mem.Allocator,
list_alloc: std.mem.Allocator,

const SCAD = @This();

pub threadlocal var scad: SCAD = undefined;

pub const Element = union(enum) {
    _comment: struct {
        parent: ?*const Element,
        text: []const u8,
    },

    _union: Container,
    _intersection: Container,
    _difference: Container,
    _hull: Container,
    _minkowski: Container,
    _color: struct {
        parent: ?*const Element,
        children: std.ArrayListUnmanaged(*const Element) = .{},
        name: []const u8,
    },

    _translate: Transform,
    _rotate: Transform,
    _scale: Transform,

    _polygon: struct {
        parent: ?*const Element,
        pts: []const @Vector(2, f64),
    },

    _linear_extrude: struct {
        parent: ?*const Element,
        children: std.ArrayListUnmanaged(*const Element) = .{},
        height: f64,
    },

    _cube: struct {
        parent: ?*const Element,
        dim: @Vector(3, f64),
    },
    _cylinder: struct {
        parent: ?*const Element,
        height: f64,
        base_radius: f64,
        end_radius: f64,
    },
    _module: struct {
        parent: ?*const Element,
        name: []const u8,
    },

    _switch_plate: struct {
        parent: ?*const Element,
        children: std.ArrayListUnmanaged(*const Element) = .{},
        width: f64,
        height: f64,

        pub fn y0(self: @This()) f64 {
            return -(self.height * 19.05 - root.switch_plate_inset) / 2;
        }
        pub fn y1(self: @This()) f64 {
            return (self.height * 19.05 - root.switch_plate_inset) / 2;
        }
        pub fn x0(self: @This()) f64 {
            return -(self.width * 19.05 - root.switch_plate_inset) / 2;
        }
        pub fn x1(self: @This()) f64 {
            return (self.width * 19.05 - root.switch_plate_inset) / 2;
        }
    },
    _key_switch: Container,
    _key_cap: struct {
        parent: ?*const Element,
        width: f64,
        height: f64,
    },

    fn make_child(self: *Element, what: Element) *Element {
        const ptr = scad.element_alloc.create(Element) catch @panic("OOM");
        ptr.* = what;
        if (self.get_children()) |list| {
            list.append(scad.list_alloc, ptr) catch @panic("OOM");
        } else @panic("Not a container");
        return ptr;
    }

    pub fn comment(self: *Element, text: []const u8) *Element {
        const dupe = scad.element_alloc.dupe(text) catch @panic("OOM");
        return self.make_child(.{ ._comment = .{
            .parent = self,
            .text = dupe,
        }});
    }

    pub fn @"union"(self: *Element) *Element {
        return self.make_child(.{ ._union = .{
            .parent = self,
        }});
    }

    pub fn intersection(self: *Element) *Element {
        return self.make_child(.{ ._intersection = .{
            .parent = self,
        }});
    }

    pub fn difference(self: *Element) *Element {
        return self.make_child(.{ ._difference = .{
            .parent = self,
        }});
    }

    pub fn hull(self: *Element) *Element {
        return self.make_child(.{ ._hull = .{
            .parent = self,
        }});
    }

    pub fn minkowski(self: *Element) *Element {
        return self.make_child(.{ ._minkowski = .{
            .parent = self,
        }});
    }

    pub fn color(self: *Element, name: []const u8) *Element {
        return self.make_child(.{ ._color = .{
            .parent = self,
            .name = name,
        }});
    }

    pub fn translate(self: *Element, transform: @Vector(3, f64)) *Element {
        return self.make_child(.{ ._translate = .{
            .parent = self,
            .transform = transform,
        }});
    }
    
    pub fn rotate(self: *Element, transform: @Vector(3, f64)) *Element {
        return self.make_child(.{ ._rotate = .{
            .parent = self,
            .transform = transform,
        }});
    }

    pub fn scale(self: *Element, transform: @Vector(3, f64)) *Element {
        return self.make_child(.{ ._scale = .{
            .parent = self,
            .transform = transform,
        }});
    }

    pub fn polygon(self: *Element, pts: []const @Vector(2, f64)) *Element {
        const dupe = scad.element_alloc.dupe(@Vector(2, f64), pts) catch @panic("OOM");
        return self.make_child(.{ ._polygon = .{
            .parent = self,
            .pts = dupe,
        }});
    }

    pub fn linear_extrude(self: *Element, height: f64) *Element {
        return self.make_child(.{ ._linear_extrude = .{
            .parent = self,
            .height = height,
        }});
    }

    pub fn cube(self: *Element, dim: @Vector(3, f64)) *Element {
        return self.make_child(.{ ._cube = .{
            .parent = self,
            .dim = dim,
        }});
    }

    pub fn cylinder(self: *Element, height: f64, base_radius: f64, end_radius: f64) *Element {
        return self.make_child(.{ ._cylinder = .{
            .parent = self,
            .height = height,
            .base_radius = base_radius,
            .end_radius = end_radius,
        }});
    }
    
    pub fn module(self: *Element, name: []const u8) *Element {
        return self.make_child(.{ ._module = .{
            .parent = self,
            .name = name,
        }});
    }

    pub fn switch_plate(self: *Element, width: f64, height: f64) *Element {
        return self.make_child(.{ ._switch_plate = .{
            .parent = self,
            .width = width,
            .height = height,
        }});
    }

    pub fn key_switch(self: *Element) *Element {
        return self.make_child(.{ ._key_switch = .{
            .parent = self,
        }});
    }

    pub fn key_cap(self: *Element, width: f64, height: f64) *Element {
        return self.make_child(.{ ._key_cap = .{
            .parent = self,
            .width = width,
            .height = height,
        }});
    }

    pub fn transform_to_world(self: *const Element, point: @Vector(3, f64)) @Vector(3, f64) {
        const transformed = switch (self.*) {
            ._comment, ._polygon, ._linear_extrude,
            ._union, ._intersection, ._difference, ._hull, ._minkowski, ._color,
            ._cube, ._cylinder, ._module, ._switch_plate, ._key_switch, ._key_cap => point,
            ._translate => |info| point + info.transform,
            ._rotate => |info| rotate_point(point, info.transform),
            ._scale => |info| point * info.transform,
        };

        return if (self.get_parent()) |parent| transform_to_world(parent, transformed) else transformed;
    }

    pub fn apply_transforms(self: *Element, transforms_to_copy: *const Element) *Element {
        var new_parent = self;

        const common_ancestor = self.find_common_ancestor(transforms_to_copy);

        if (transforms_to_copy.get_parent()) |parent_to_copy| {
            var apply_parent_transform = true;
            if (common_ancestor) |ancestor| {
                apply_parent_transform = parent_to_copy != ancestor;
            }
            if (apply_parent_transform) {
                new_parent = new_parent.apply_transforms(parent_to_copy);
            }
        }

        switch (transforms_to_copy.*) {
            ._comment, ._polygon, ._linear_extrude,
            ._union, ._intersection, ._difference, ._hull, ._minkowski, ._color,
            ._cube, ._cylinder, ._module, ._switch_plate, ._key_switch, ._key_cap => {},
            ._translate => |info| new_parent = new_parent.translate(info.transform),
            ._rotate => |info| new_parent = new_parent.rotate(info.transform),
            ._scale => |info| new_parent = new_parent.scale(info.transform),
        }

        return new_parent;
    }

    fn is_child_of(self: *const Element, maybe_ancestor: *const Element) bool {
        var el = self;
        while (el.get_parent()) |parent| {
            if (parent == maybe_ancestor) return true;
            el = parent;
        }
        return false;
    }

    fn find_common_ancestor(self: *const Element, other: *const Element) ?*const Element {
        var maybe_ancestor: ?*const Element = self;
        while (maybe_ancestor) |el| {
            if (other.is_child_of(el)) return el;
            maybe_ancestor = el.get_parent();
        }
        return null;
    }

    fn rotate_point(point: @Vector(3, f64), rotation: @Vector(3, f64)) @Vector(3, f64) {
        var p = point;
        if (rotation[0] != 0) {
            const rad = std.math.degreesToRadians(rotation[0]);
            const sin = @sin(rad);
            const cos = @cos(rad);
            const y = p[1];
            const z = p[2];
            p = .{
                p[0],
                y * cos - z * sin,
                y * sin + z * cos,
            };
        }
        if (rotation[1] != 0) {
            const rad = std.math.degreesToRadians(rotation[1]);
            const sin = @sin(rad);
            const cos = @cos(rad);
            const x = p[0];
            const z = p[2];
            p = .{
                x * cos + z * sin,
                p[1],
                -x * sin + z * cos,
            };
        }
        if (rotation[2] != 0) {
            const rad = std.math.degreesToRadians(rotation[2]);
            const sin = @sin(rad);
            const cos = @cos(rad);
            const x = p[0];
            const y = p[1];
            p = .{
                x * cos - y * sin,
                x * sin + y * cos,
                p[2],
            };
        }
        return p;
    }

    pub fn write(self: Element, writer: std.io.AnyWriter, indent: usize, new_line: bool) !void {
        if (new_line) {
            try writer.writeByteNTimes(' ', indent * 4);
        }

        switch (self) {
            ._comment => |info| return try writer.print("// {s}", .{ info.text }),
            ._union => |info| {
                if (info.parent == null) {
                    for (0.., info.children.items) |i, child| {
                        try child.write(writer, indent, i != 0);
                    }
                    return;
                } else {
                    try writer.writeAll("union()");
                }
            },
            ._intersection => try writer.writeAll("intersection()"),
            ._difference => try writer.writeAll("difference()"),
            ._hull => try writer.writeAll("hull()"),
            ._minkowski => try writer.writeAll("minkowski()"),
            ._color => |info| try writer.print("color(\"{}\")", .{ std.zig.fmtEscapes(info.name) }),
            ._translate => |info| try writer.print("translate([{d}, {d}, {d}])", .{ info.transform[0], info.transform[1], info.transform[2] }),
            ._rotate => |info| try writer.print("rotate([{d}, {d}, {d}])", .{ info.transform[0], info.transform[1], info.transform[2] }),
            ._scale => |info| try writer.print("scale([{d}, {d}, {d}])", .{ info.transform[0], info.transform[1], info.transform[2] }),
            ._polygon => |info| {
                try writer.writeAll("polygon(points=[");
                for (0.., info.pts) |i, p| {
                    if (i > 0) try writer.writeByte(',');
                    try writer.print("[{d},{d}]", .{ p[0], p[1] });
                }
                try writer.writeAll("])");
            },
            ._linear_extrude => |info| try writer.print("linear_extrude({d})", .{ info.height }),
            ._cube => |info| try writer.print("cube([{d}, {d}, {d}], center = true)", .{ info.dim[0], info.dim[1], info.dim[2] }),
            ._cylinder => |info| try writer.print("cylinder({d}, {d}, {d})", .{ info.height, info.base_radius, info.end_radius }),
            ._module => |info| try writer.print("{s}()", .{ info.name }),
            ._switch_plate => |info| {
                if (info.width != 1 or info.height != 1) {
                    try writer.print("cherry_mx_plate(width_u = {d}, height_u = {d})", .{ info.width, info.height });
                } else {
                    try writer.writeAll("cherry_mx_plate()");
                }
            },
            ._key_switch => try writer.writeAll("cherry_mx()"),
            ._key_cap => |info| {
                if (info.width != 1 or info.height != 1) {
                    try writer.print("keycap_sa(width_u = {d}, height_u = {d})", .{ info.width, info.height });
                } else {
                    try writer.writeAll("keycap_sa()");
                }
            },
        }

        const children = self.get_children_array();
        if (children.len == 1) {
            try writer.writeByte(' ');
            try children[0].write(writer, indent, false);
        } else if (children.len == 0) {
            try writer.writeAll(";\n");
        } else {
            try writer.writeAll(" {\n");
            for (children) |child| {
                try child.write(writer, indent + 1, true);
            }
            try writer.writeByteNTimes(' ', indent * 4);
            try writer.writeAll("}\n");
        }
    }

    fn get_children(self: *Element) ?*std.ArrayListUnmanaged(*const Element) {
        return switch (self.*) {
            inline else => |*el| if (@hasField(@TypeOf(el.*), "children")) &el.children else null,
        };
    }

    fn get_children_array(self: *const Element) []*const Element {
        return switch (self.*) {
            inline else => |*el| if (@hasField(@TypeOf(el.*), "children")) el.children.items else &.{},
        };
    }

    fn get_parent(self: *const Element) ?*const Element {
        return switch (self.*) {
            ._comment => |info| info.parent,
            ._union => |info| info.parent,
            ._intersection => |info| info.parent,
            ._difference => |info| info.parent,
            ._hull => |info| info.parent,
            ._minkowski => |info| info.parent,
            ._color => |info| info.parent,
            ._translate => |info| info.parent,
            ._rotate => |info| info.parent,
            ._scale => |info| info.parent,
            ._polygon => |info| info.parent,
            ._linear_extrude => |info| info.parent,
            ._cube => |info| info.parent,
            ._cylinder => |info| info.parent,
            ._module => |info| info.parent,
            ._switch_plate => |info| info.parent,
            ._key_switch => |info| info.parent,
            ._key_cap => |info| info.parent,
        };
    }
};

pub const Container = struct {
    parent: ?*const Element,
    children: std.ArrayListUnmanaged(*const Element) = .{},
};

pub const Transform = struct {
    parent: ?*const Element,
    children: std.ArrayListUnmanaged(*const Element) = .{},
    transform: @Vector(3, f64),
};

const root = @import("root");
const std = @import("std");
