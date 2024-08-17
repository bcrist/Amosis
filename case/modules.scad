
module edge_sphere() {
    sphere(edge_radius);
}

module edge_capsule() {
    hull() {
        translate([0, 0, -edge_radius]) sphere(edge_radius);
        translate([0, 0, -plate_thickness + edge_radius]) sphere(edge_radius);
    }
}

module cherry_mx_plate(width_u = 1, height_u = 1) {
    u = 19.05;
    width = width_u * u - switch_plate_inset;
    height = height_u * u - switch_plate_inset;
    clip_thickness = 1.5;
    clip_inset = 0.25;
    clip_width = 5;
    hole_size = 14.2;
    nub_length = 3.5;
    nub_radius = 0.8;

    horiz_edge();
    rotate([0, 0, 180]) horiz_edge();
    
    vert_edge();
    rotate([0, 0, 180]) vert_edge();

    children();
    
    module vert_edge() {
        translate([-width/2, -height/2]) {
            hull() {
                translate([0, 0, -edge_radius]) sphere(edge_radius);
                translate([0, 0, -plate_thickness + edge_radius]) sphere(edge_radius);
                translate([width, 0, -edge_radius]) sphere(edge_radius);
                translate([width, 0, -plate_thickness + edge_radius]) sphere(edge_radius);
            }
            translate([0, 0, -clip_thickness]) cube([width, height/2 - hole_size/2, clip_thickness]);
            translate([0, 0, -plate_thickness]) {
                cube([width, height/2 - hole_size/2 - clip_inset, plate_thickness]);
                cube([width/2 - clip_width/2, height/2 - hole_size/2, plate_thickness]);
                translate([width/2 + clip_width/2, 0]) cube([width/2 - clip_width/2, height/2 - hole_size/2, plate_thickness]);
            }
        }
    }
    
    module horiz_edge() {
        translate([-width/2, -height/2]) {
            hull() {
                translate([0, 0, -edge_radius]) sphere(edge_radius);
                translate([0, 0, -plate_thickness + edge_radius]) sphere(edge_radius);
                translate([0, height, -edge_radius]) sphere(edge_radius);
                translate([0, height, -plate_thickness + edge_radius]) sphere(edge_radius);
            }
            translate([0, 0, -plate_thickness]) cube([width/2 - hole_size/2, height, plate_thickness]);
        }
        // nub
        translate([0, 0, -plate_thickness]) hull() {
            translate([-hole_size/2, 0, plate_thickness/2]) cube([0.01, nub_length, plate_thickness], center=true);
            translate([-hole_size/2, 0, nub_radius]) rotate([90, 0, 0]) cylinder(nub_length, nub_radius, nub_radius, center=true);
        }
    }
}

module cherry_mx() {
    stem_height = 4;
    stem_thickness_x = 1.35;
    stem_thickness_y = 1.15;
    stem_width = 4.5;

    stem_base_width = 7.2;
    stem_base_height = 5.6;
    stem_base_offset = 0.4;

    cover_top = 10.2;
    cover_bottom = 14.6;
    cover_height = 5.3;

    foot_height = 0.8;
    foot_width = 15.6;

    base = 14;
    base_height = 5.5;
    base_taper = 1;
    plate_height = 2.2;

    translate([0, 0, cover_height + foot_height + stem_base_offset]) {
        children();
    }

    translate([0, 0, stem_height + cover_height + foot_height])
    {
        color("cyan"){
            translate([0, 0, -stem_height / 2]) {
                cube([stem_thickness_x, stem_width, stem_height], center=true);
                cube([stem_width, stem_thickness_y, stem_height], center=true);
            }
            translate([0, 0, -stem_height - 1 + stem_base_offset]) {
                cube([stem_base_width, stem_base_height, 2], center=true);
            }
        }
        
        color("grey") translate([0, 0, -stem_height]) {		
            hull(){
                cube([cover_top, cover_top, 0.1], center=true);
                translate([0, 0, -cover_height]) cube([cover_bottom, cover_bottom, 0.1], center=true);
            }
            
            translate([0, 0, -cover_height]) {
                hull(){
                    translate([0, 0, -plate_height/2]) cube([base, base, plate_height], center=true);
                    translate([0, 0, -base_height]) cube([base - base_taper, base - base_taper, 0.1], center=true);
                }

                translate([0, 0, -foot_height/2]) cube([foot_width, foot_width, foot_height], center=true);
                translate([0, 0, -foot_height]) difference(){
                    hull(){
                        translate([0, 0, -1.4]) cube([3.5, 14, 0.1], center=true);
                        translate([0, 0, -2])   cube([3.5, 14.75, 0.1], center=true);
                        translate([0, 0, -2.5]) cube([3.5, 14, 0.1], center=true);
                    }
                    translate([0, 0, -1.5]) cube([2, 20, 4], center=true);
                }
            }
        }
    }
}

module keycap_sa(raw_row = 3, width_u = 1, height_u = 1) {
    row = 3 - abs(3 - raw_row);
    base_height = 12.6;
    sa_radius = 33.3;
    row_offset = 4;
    dy = row_offset * (3 - raw_row);
    u = 19.05;
    width = width_u * u;
    height = height_u * u;
    color("#99f") translate([0, -dy, -row + 1]) difference() {
        intersection() {
            union() {
                translate([sa_radius - width/2, height/2 + dy, 0])   rotate([90,0,0]) cylinder(h = height, r = sa_radius);
                translate([sa_radius + width/2, dy, sa_radius/2]) cube([width*2, height, sa_radius], center=true);
            }
            union() {
                translate([-width/2, sa_radius - height/2 + dy, 0]) rotate([90,0,90])  cylinder(h = width, r = sa_radius);
                translate([0, sa_radius + height/2 + dy, sa_radius/2]) cube([width, height*2, sa_radius], center=true);
            }
            union() {
                translate([-sa_radius + width/2, -height/2 + dy, 0])   rotate([90,0,180]) cylinder(h = height, r = sa_radius);
                translate([-sa_radius - width/2, dy, sa_radius/2]) cube([width*2, height, sa_radius], center=true);
            }
            union() {
                translate([width/2, -sa_radius + height/2 + dy, 0]) rotate([90,0,270])  cylinder(h = width, r = sa_radius);
                translate([0, -sa_radius - height/2 + dy, sa_radius/2]) cube([width, height*2, sa_radius], center=true);
            }
        }
        scale([width_u, height_u, 1]) {
            translate([0, 0, base_height + sa_radius]) sphere(r = sa_radius);
            translate([0, 0, -sa_radius + row - 1]) cube(sa_radius * 2, center=true);
        }
    }
}

cirque_outer_diameter = 42.8;
cirque_inner_diameter = 35;
cirque_inset_depth = 2;
cirque_border_width = 1;
cirque_base_thickness = 30;
cirque_edge_radius = 8;

module half_cirque_plate() {
    total_depth = cirque_base_thickness + cirque_inset_depth;
    outer_radius = cirque_outer_diameter / 2;
    
    translate([0, 0, -total_depth]) {
        intersection() {
            mask_side_length = 2 * (outer_radius + cirque_border_width + cirque_edge_radius);
            translate([0, mask_side_length/2, 0]) cube([mask_side_length, mask_side_length, total_depth * 2], center = true);
            minkowski() {
                cylinder(h = total_depth - cirque_edge_radius, r = outer_radius + cirque_border_width, $fn = 180);
                sphere(cirque_edge_radius, $fn = 90);
            }
        }
    }
}

module cirque_plate() {
    total_depth = cirque_base_thickness + cirque_inset_depth;
    outer_radius = cirque_outer_diameter / 2;
    
    translate([0, 0, -total_depth]) {
        minkowski() {
            cylinder(h = total_depth - cirque_edge_radius, r = outer_radius + cirque_border_width, $fn = 180);
            sphere(cirque_edge_radius, $fn = 90);
        }
    }
}

module cirque_plate_holes() {
    total_depth = cirque_base_thickness + cirque_inset_depth;
    outer_radius = cirque_outer_diameter / 2;
    inner_radius = cirque_inner_diameter / 2;
    
    translate([0, 0, -total_depth]) {
        cylinder(h = 3*total_depth, r = inner_radius, center = true);
        translate([0, 0, cirque_base_thickness]) cylinder(h = total_depth, r = outer_radius, $fn = 180);
    }
}

module cable_guide() {
    minkowski() {
        cube([1, 40, 10], center=true);
        sphere(5);
    }
}
