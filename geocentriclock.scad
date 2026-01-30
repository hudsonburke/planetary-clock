include <gears/gears.scad>

// Hour ring inner
thickness = 2;
difference() {
  planetary_gear(
    modul=1,
    sun_teeth=32,
    planet_teeth=32,
    number_planets=4,
    width=thickness,
    rim_width=12.5,
    bore=5.6,
    pressure_angle=20,
    helix_angle=0,
    together_built=true,
    optimized=true
  );

  for (i = [1:12]) {
    rotate([0, 0, -30 * i])
      translate([55, 0, thickness / 2])
        linear_extrude(height=thickness)
          rotate([0, 0, -90])
            text(str(i), size=10, halign="center", valign="center");
  }
}

translate([0, 0, -3])
  difference() {
    planetary_gear(
      modul=1,
      sun_teeth=48,
      planet_teeth=48,
      number_planets=3,
      width=thickness,
      rim_width=12.5,
      bore=3.75,
      pressure_angle=20,
      helix_angle=0,
      together_built=true,
      optimized=true
    );

    for (i = [1:12]) {
      rotate([0, 0, -30 * i])
        translate([55, 0, thickness / 2])
          linear_extrude(height=thickness)
            rotate([0, 0, -90])
              text(str(i), size=10, halign="center", valign="center");
    }
  }
