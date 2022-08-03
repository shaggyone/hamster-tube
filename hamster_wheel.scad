$fn=50;

bearing_d = 22.6;
bearing_h = 7;

wheel_axis_d = 40;
wheel_axis_l = 17;
wheel_axis_spacer_d = 18;

wheel_diameter = 150;
wheel_width = 70;
wheel_ellipsoidicity = 0.8;
wheel_body_thickness = 1.6;

wheel_ladder_stairs_count = 30;
wheel_ladder_stairs_count_phi = 360 / wheel_ladder_stairs_count;
wheel_ladder_stair_th = 2.4;
wheel_ladder_stair_len = 4.8;

wheel_wall_thickness = 3.2;
wheel_spokes_d_out = 120;
wheel_spokes_d_in = 50;
wheel_spokes_phi = 20;
wheel_spokes_alpha = 40;
wheel_spokes_count = 360 / wheel_spokes_alpha;

wheel_spokes_twist = 30;

eps = 0.01;

union() {
    difference() {
        union() {
            translate([0, wheel_width/2, 0])
            difference($fn=50) {
                scale([1, 1/wheel_ellipsoidicity, 1])
                    union() {
                        for(i=[1:1:wheel_ladder_stairs_count])
                            rotate(i*wheel_ladder_stairs_count_phi, [0, 1, 0])
                                difference() {
                                    rotate_extrude()
                                        translate([wheel_diameter/2-wheel_body_thickness, 0, 0])
                                        scale([1, wheel_ladder_stair_len/wheel_ladder_stair_th])
                                            circle(d=wheel_ladder_stair_th);
                            translate([wheel_diameter, 0, 0])
                                cube([wheel_diameter*2, wheel_diameter*2, wheel_diameter*2], center=true);
                        }

                        difference() {
                            sphere(d=wheel_diameter);
                            sphere(d=wheel_diameter-wheel_body_thickness*2);
                        }

                        intersection() {
                            sphere(d=wheel_diameter);
                            translate([0, (-wheel_width/2+wheel_wall_thickness*2/wheel_ellipsoidicity), 0])
                            cube([wheel_diameter*2, wheel_wall_thickness/wheel_ellipsoidicity, wheel_diameter*2], center=true);
                        }
                    };

                translate([0, wheel_diameter/2+wheel_width/2, 0])
                    cube([wheel_diameter, wheel_diameter + eps, wheel_diameter + eps], center=true);
                translate([0, -wheel_diameter/2-wheel_width/2, 0])
                    cube([wheel_diameter, wheel_diameter + eps, wheel_diameter + eps], center=true);

                rotate(90, [1, 0, 0], $fn=20)
                    linear_extrude(height=wheel_diameter*2/wheel_ellipsoidicity, center=true)
                        for (i=[1:wheel_spokes_alpha]) {
                            rotate(wheel_spokes_alpha*i, [0,0,1]) projection()
                                intersection() {
                                    difference() {
                                        cylinder(d1=wheel_spokes_d_in, d2=wheel_spokes_d_out, h=wheel_spokes_d_out);
                                        translate([0,0,-eps])
                                        cylinder(d1=wheel_spokes_d_in-1, d2=wheel_spokes_d_out-1, h=wheel_spokes_d_out+eps*2);
                                    }

                                    linear_extrude(height=wheel_spokes_d_out, center=false, twist=wheel_spokes_twist)
                                        intersection() {
                                            difference() {
                                                circle(d=wheel_spokes_d_out);
                                                circle(d=wheel_spokes_d_in);
                                            };

                                            polygon([
                                                [0, 0],
                                                [wheel_spokes_d_out/2, wheel_spokes_d_out*tan(wheel_spokes_phi/2)/2],
                                                [wheel_spokes_d_out/2, -wheel_spokes_d_out*tan(wheel_spokes_phi/2)/2]
                                            ]);
                                        }
                                }
                            }
            }


            rotate(90, [1, 0, 0])
                translate([0, 0, -wheel_axis_l])
                    cylinder(d=wheel_axis_d, h=wheel_axis_l*wheel_ellipsoidicity);
        }

        rotate(90, [1, 0, 0])
            translate([0, 0, 0])
                cylinder(d=bearing_d, h=wheel_diameter, center=true);
    }
    translate([0, bearing_h, 0])
        rotate(-90, [1, 0, 0])
            difference() {
                cylinder(d=bearing_d+eps, h=wheel_axis_l-bearing_h*2);
                translate([0,0,-eps])
                    cylinder(d=wheel_axis_spacer_d, h=wheel_axis_l-bearing_h*2+eps*2);
            }
}