main_diameter = 54;
tube_thickness = 1.2;
tube_length = 97;

ladder_rungs_thickess = 2;
ladder_rungs_count = 4;
vent_hole_diameter = 3;
vent_holes_per_ring = 3;


fit_diameter1 = 56;
fit_l1 = 3;
fit_l2 = 3;
fit_diameter3 = 60;
fit_l3 = 3;

connector_d=62;
connector_delta_d=59;
connector_delta=3;
connector_cut_th=2;

eps = 0.01;

home_diameter_1 = 110;
home_diameter_2 = 65;


module tube(do, di, th, l) {
    let(ddi=(di == undef) ? (do - th*2) : di){
        difference() {
            cylinder(h=l, d=do);
            translate([0, 0, -eps]) {
                cylinder(h=l + eps*2, d=ddi);
            };
        };
    };

}


module ladder_rung() {
    rotate_extrude(angle = 360, convexity = 200) {
        translate([
            -main_diameter/2 + ladder_rungs_thickess - (0.5 * eps * cos(30)), 0, 0]) {
            //rotate(a=90, [1, 0, 0]){
                circle(d=ladder_rungs_thickess+eps, $fn=3);
            //}
        }
    }
};

module fitting() {
    tube(do=fit_diameter1, di=main_diameter-eps, l=fit_l1);
    translate([0,0,fit_l1 + fit_l2]) {
        tube(do=fit_diameter3, di=main_diameter-eps, l=fit_l3);
    }
};

module hamster_tube() {
    difference() {
        tube(do=main_diameter, th=tube_thickness, l=tube_length, $fn=200);
        let (step_size = tube_length / (ladder_rungs_count)) {
            for(j=[0: vent_holes_per_ring]) {
                rotate(360/vent_holes_per_ring*j, [0,0,1]) {
                    for (i = [0:(ladder_rungs_count-1)]) {
                        let(z = step_size * i) {
                            echo("z: ", z);
                            translate([0,0,z]) {
                                rotate(90, [0,1,0]) {
                                    cylinder(d=vent_hole_diameter, h=main_diameter/2+eps);
                                }
                            }
                            
                        }
                    }
                }
            }
        }
    };

    let (step_size = tube_length / (ladder_rungs_count)) {
        echo("Delta: ", step_size);
        for (i = [0:(ladder_rungs_count-1)]) {
            let(z = step_size * i + step_size*0.5) {
                echo("z: ", z);
                translate([0, 0, z]) {
                    ladder_rung();
                }
            }
        }
    };
    
    fitting();
    
    translate([0,0,tube_length]) {
        mirror([0,0,1]) {
            fitting();
        }
    }
};

module hamster_home() {
    difference() {
        union() {
            scale([1,1,home_diameter_2/home_diameter_1]) {
                sphere(d=home_diameter_1, $fn=100);
            };
            
            for(i=[0,1]) {
                rotate(90*i, [0,0,1]) {
                    rotate(90, [0,1,0]) {
                        cylinder(d=main_diameter, h=home_diameter_1/2, $fn=100);
                        translate([0,0, home_diameter_1/2]) {
                            mirror([0,0,1]) {
                                fitting($fn=200);
                            }
                        }
                    };
                };
            }
        };
        union() {
            scale([1,1,(home_diameter_2-tube_thickness*2)/(home_diameter_1-tube_thickness*2)]) {
                sphere(d=home_diameter_1-tube_thickness*2, $fn=100);
            };
            
            for(i=[0,1]) {
                rotate(90*i, [0,0,1]) {
                    rotate(90, [0,1,0]) {
                        cylinder(d=main_diameter-tube_thickness*2, h=home_diameter_1/2+eps, $fn=200);
             
                    };
                };
            }

        }
        
        
    }
}

*hamster_tube();
*hamster_home();

let(connector_l=fit_l1*2 + fit_l2*2 + connector_delta) {
    difference() {
        union() {
        
            translate([0,0,-connector_l*0.5]) {
                tube(do=connector_d, di=fit_diameter1, l=connector_l);
                //mirror([0,0,1]) 
                tube(do=fit_diameter1+eps, di=main_diameter, l=fit_l1);
                
                translate([0,0,fit_l1+fit_l2]) {
                    tube(do=fit_diameter1+eps, di=main_diameter-tube_thickness*2, l=fit_l3);
                }
                
                translate([0,0,connector_l]) {
                    mirror([0,0,1]) {
                        tube(do=fit_diameter1+eps, di=main_diameter, l=fit_l1);
                    }
                }
            }
        };
    
        translate([0,0,-fit_l2*0.5]) {
            tube(do=connector_d+eps, di=connector_delta_d, l=fit_l2);
        };
        
        translate([0,0,-connector_l*0.5-eps]) {
            cube([connector_d+eps, connector_cut_th, connector_l+eps*2]);
        };
    }
}