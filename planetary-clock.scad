include <gears/gears.scad>
include <../BOSL2/std.scad>

/*
Units are in mm
*/

// Show / hide
show_cover = false;
show_hour_ring = false;
show_hour_carrier = true;
show_case = true;
show_stand = false;
disassembled = true;

// Parameters
acrylic_thickness = 3.175;

thickness = 3;

hour_modul = 1;
hour_sun_teeth = 16;
hour_planet_teeth = 36;
hour_n_planets = 3;
hour_bore = 3.75;

ring_outer_r = hour_modul * (hour_sun_teeth + 2 * hour_planet_teeth) / 2 + hour_modul + hour_modul / 6 + 14;
minute_bore = 5.6;
minute_step = 15;
current_hour_angle = 0; // 0 = 12 o'clock, 30 = 1 o'clock, 60 = 2, etc.

// Hour ring inner
if (show_hour_ring) {
  difference() {
    planetary_gear(
      modul=hour_modul,
      sun_teeth=hour_sun_teeth,
      planet_teeth=hour_planet_teeth,
      number_planets=hour_n_planets,
      width=thickness,
      rim_width=14,
      bore=hour_bore,
      pressure_angle=20,
      helix_angle=30,
      together_built=disassembled,
      optimized=true
    );

    for (i = [1:12]) {
      hour_angle = 360 / 12 * i;
      rotate([0, 0, -hour_angle])
        translate([50.5, 0, thickness / 2])
          linear_extrude(height=thickness)
            text(str(i), size=6.75, halign="center", valign="center");

      for (j = [minute_step:minute_step:59]) {
        minute_angle = hour_angle + (j / minute_step) * 7.5;
        rotate([0, 0, -minute_angle])
          translate([54, 0, thickness / 2])
            linear_extrude(height=thickness)
              // rotate([0, 0, minute_angle])
              text(format_int(j, 2), size=4, halign="center", valign="center");
      }
    }

    // Tick marks on outer edge
    // Hour ticks — longer
    for (i = [0:11]) {
      rotate([0, 0, -360 / 12 * i])
        translate([ring_outer_r - 3.25, -0.5, thickness / 2])
          cube([3.5, 1, thickness]);
    }
    // Quarter-hour ticks — shorter
    for (i = [1:12]) {
      for (j = [minute_step:minute_step:59]) {
        rotate([0, 0, -(360 / 12 * i + (j / minute_step) * 7.5)])
          translate([ring_outer_r - 2, -0.25, thickness / 2])
            cube([2, 0.5, thickness]);
      }
    }
  }
}

// Acrylic cover
cover_r = ring_outer_r + 10;
cover_bottom_z = thickness + 0.5;
if (show_cover) {
  translate([0, 0, cover_bottom_z])
    difference() {
      cylinder(h=acrylic_thickness, r=cover_r);

      // Arc window — 90 degree annular sector revealing only the ring face
      rotate([0, 0, -current_hour_angle])
        linear_extrude(height=acrylic_thickness + 0.1)
          intersection() {
            difference() {
              circle(r=ring_outer_r);
              circle(r=ring_outer_r - 14); // match rim_width to only expose the ring face
            }
            polygon(
              [
                [0, 0],
                [cover_r * 2 * cos(45), cover_r * sin(45)],
                [cover_r * 2 * cos(-45), cover_r * sin(-45)],
              ]
            );
          }

      // Triangle notch cut into outer rim pointing inward at current time
      rotate([0, 0, -current_hour_angle])
        translate([0, 0, acrylic_thickness / 2])
          linear_extrude(height=acrylic_thickness)
            polygon(
              [
                [(cover_r - 1) * cos(2), (cover_r + 0.1) * sin(2)],
                [(cover_r - 1) * cos(-2), (cover_r + 0.1) * sin(-2)],
                [cover_r - 8, 0],
              ]
            );
      // Hook notches — slots cut into cover edge to engage with case hooks
      for (i = [0:num_hooks - 1]) {
        hook_angle = current_hour_angle + 180 + (i - (num_hooks - 1) / 2) * (200 / num_hooks);
        rotate([0, 0, hook_angle])
          translate([case_inner_r - hook_depth - hook_clearance, -hook_width / 2 - hook_clearance, -0.05])
            cube([hook_depth + hook_clearance + 1, hook_width + 2 * hook_clearance, acrylic_thickness + 0.1]);
      }
    }
}

// Carrier
if (show_hour_carrier) {
  orbit_radius = hour_modul * (hour_sun_teeth + hour_planet_teeth) / 2;
  num_holes = 3;
  translate([0, 0, -thickness - 0.25])
    union() {
      difference() {
        carrier_r = hour_bore + orbit_radius;
        cylinder(h=thickness, r=carrier_r);
        cylinder(h=thickness + 0.1, r=minute_bore / 2);
        for (i = [0:num_holes - 1]) {
          rotate([0, 0, i * 360 / num_holes - 60])
            translate([orbit_radius * 0.6, 0, 0])
              cylinder(h=thickness + 0.1, r=orbit_radius / 2.5);
        }
      }
      for (i = [0:hour_n_planets]) {
        rotate([0, 0, 360 / hour_n_planets * i])
          translate([orbit_radius, 0, 0])
            union() {
              cylinder(h=2 * thickness + 0.5, r=hour_bore / 2 - 0.15);
              translate([0, 0, 2 * thickness + 0.25])
                sphere(r=hour_bore / 2 - 0.05);
            }
      }
    }
}

// Clock movement (standard quartz)
clock_width = 56;
clock_length = 56;
clock_height = 16;

pillar_r = 3.8;
pillar_h = 16;

clock_bottom_z = -thickness - clock_height - 0.25 - pillar_h;
translate([0, 0, clock_bottom_z])
  color("Gray")
    union() {
      cube([clock_width, clock_length, clock_height], center=true);
      cylinder(r=pillar_r, h=pillar_h + clock_height, center=false);
      cylinder(r=minute_bore / 2, h=clock_height + pillar_h + 3, center=false);
      cylinder(r=hour_bore / 2, h=clock_height + pillar_h + 6, center=false);
    }

case_bottom_z = clock_bottom_z + clock_height;
case_wall_thickness = 3;
case_outer_r = cover_r + case_wall_thickness;
case_inner_r = cover_r + 1;
case_wall_height = cover_bottom_z - case_bottom_z + acrylic_thickness;

// Case
if (show_case) {
  color("SlateGray")
    difference() {
      union() {
        // Cylindrical shell wall
        translate([0, 0, case_bottom_z])
          difference() {
            cylinder(h=case_wall_height, r=case_outer_r);
            cylinder(h=case_wall_height + 0.1, r=case_inner_r);
          }

        // Back plate
        translate([0, 0, case_bottom_z])
          cylinder(h=thickness, r=case_outer_r);

        // Ring support ledge — annular lip inside the case at z=0
        translate([0, 0, -ledge_thickness])
          difference() {
            cylinder(h=ledge_thickness, r=case_inner_r);
            cylinder(h=ledge_thickness + 0.1, r=ring_outer_r - ledge_width);
          }
      }
      // Back plate cutouts
      // Center hole for movement shaft
      translate([0, 0, case_bottom_z - 0.05])
        cylinder(h=case_wall_height + 0.1, r=pillar_r + 0.1);
    }
}
