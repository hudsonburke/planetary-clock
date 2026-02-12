include <../BOSL2/std.scad>
include <../BOSL2/gears.scad>
/*
Units are in mm
*/

// Show / hide
show_cover = false;
show_hour_ring = true;
show_minute_ring = false;
show_sun = true;
show_planets = true;
show_ring = true;
show_carrier = true;

// Parameters
acrylic_thickness = 3.175;
cover_radius = 50;
view_radius = 10;
$fn = 81;

helical = 0;
gear_hole = 3;
minute_hole = 3.5; // 0.137 in
hour_hole = 0; // 0.211 in
print_hole_tol = 0.5; // 0.5 mm for printing tolerance

ring_thickness = 3;
herringbone = false;

// Acrylic cover
if (show_cover) {
  translate([0, 0, 4])
    difference() {
      cylinder(h=acrylic_thickness, r=cover_radius, center=true);
      translate([cover_radius - view_radius - 1, 0, 0])
        cylinder(h=acrylic_thickness + 0.1, r=view_radius, center=true);
    }
}

// Hour ring inner
mod = 1;
if (show_hour_ring) {

  gear_data = planetary_gears(
    mod=mod,
    n=3,
    max_teeth=150,
    sun_ring=12,
    helical=helical
  );

  // Carrier
  if (show_carrier) {
    color("blue") {
      move_copies(gear_data[2][4]) cyl(h=5, r=gear_hole);
      difference() {
        down(4) linear_extrude(height=2) scale(1.2) polygon(gear_data[2][4]);
        down(4) linear_extrude(height=3) scale(0.85) polygon(gear_data[2][4]);
      }
    }
  }

  // Sun gear
  if (show_sun) {
    difference() {
      spur_gear(
        mod=mod,
        teeth=gear_data[0][1],
        profile_shift=gear_data[0][2],
        gear_spin=gear_data[0][3],
        thickness=ring_thickness,
        helical=helical,
        herringbone=herringbone
      );
      cylinder(h=ring_thickness + 0.1, r=minute_hole, center=true);
    }
  }

  // Planet gears
  num_holes = 5;
  if (show_planets) {
    move_copies(gear_data[2][4])
      difference() {
        spur_gear(
          mod=mod,
          teeth=gear_data[2][1],
          profile_shift=gear_data[2][2],
          gear_spin=gear_data[2][3][$idx],
          thickness=ring_thickness,
          helical=-helical,
          herringbone=herringbone
        );
        cylinder(h=ring_thickness + 0.1, r=gear_hole + 0.25, center=true);
        inner_radius = root_radius(mod=mod, teeth=gear_data[2][1], profile_shift=gear_data[2][2], helical=-helical);
        for (i = [0:num_holes - 1]) {
          rotate([0, 0, i * 360 / num_holes])
            translate([inner_radius * 0.6, 0, 0])
              cylinder(h=ring_thickness + 0.1, r=1.6 * inner_radius / num_holes, center=true);
        }
      }
  }

  // Ring gear
  if (show_ring) {
    difference() {
      ring_gear(
        mod=mod,
        teeth=gear_data[1][1],
        profile_shift=gear_data[1][2],
        gear_spin=gear_data[1][3],
        backing=15,
        thickness=ring_thickness,
        helical=helical,
        herringbone=herringbone
      );
      for (i = [1:12]) {
        rotate([0, 0, -30 * i])
          translate([86, 0, ring_thickness / 4])
            linear_extrude(height=ring_thickness + 0.1)
              rotate([0, 0, -90])
                text(str(i), size=12, halign="center", valign="center");
      }
    }
  }
}

if (show_minute_ring) {
  translate([0, 0, -3])
    difference() {
      for (i = [0:59]) {
        rotate([0, 0, -6 * i])
          translate([55, 0, ring_thickness / 2])
            linear_extrude(height=ring_thickness)
              rotate([0, 0, -90])
                text(str(i), size=10, halign="center", valign="center");
      }
    }
}
