//$fa=0.01;
//$fs=0.2;

// flat_head_screw_hole - Approximate shape of a flat head screw
// The head is centered at the origin and the screw points up.
//
// screw_d = shaft diameter
// screw_h = overall length of screw
// head_d = screw head diameter
// head_h = thickness of screw head
// head_extra = extra thickness on top of the screw head
//     (This extra thickness is not part of the screw.)
//
// Example:
//   flat_head_screw_hole(2.5, 10, 4.5, 1.5, 1);
module flat_head_screw_hole(screw_d, screw_h, head_d, head_h, head_extra = 0)
{
    cylinder(d = screw_d, h = screw_h);
    cylinder(d1 = head_d, d2 = screw_d, h = head_h);
    translate([0, 0, -head_extra]) cylinder(d = head_d, h = head_extra);
}

// flattened_cylinder - Cylinder with flattened sides
// Example:
//   flattened_cylinder(20, 15, 12);
module flattened_cylinder(d, w, h)
{
    intersection()
    {
        cylinder(d = d, h = h);
        
        translate([0, 0, h * 0.5])
            cube([d + 1, w, h + 2], center = true);
    }
}

// motor_holder - Holder for a 180 size motor.
// part="all" creates the entire motor holder
// part="inside" creates the inner hole where the motor goes
// Example:
motor_holder(27, 12);
%color("red", 0.5) motor_holder(27, 12, part = "inside");

module motor_holder(holder_od, holder_h, part="all")
{
    // size of a 180 motor
    motor_d = 20;
    motor_w = 15;

    // margin to allow the motor to fit in the holder
    motor_d_margin = 1.75;

    // size of the motor collar
    // This is the part at the front of the motor, where the shaft comes out.
    collar_d = 6;
    collar_h = 1.6;

    // margin to allow the collar to fit in the holder
    collar_d_margin = 1;

    // location of the motor mounting screws
    screw_offsets = [[6, 0, 0], [-6, 0, 0]];

    // size of the screw holes to mount the motor (including margin)
    screw_hole_d = 2.5;
    head_d = 4.5;
    head_h = 1.5;

    // access notches to help remove support material after 3D printing
    notch_x = (holder_od - (motor_d + motor_d_margin)) * 0.5 + 1; // length
    notch_y = 2; // width
    notch_z = collar_h + 1; // depth
    notch_offset_x = holder_od * 0.5 - notch_x * 0.5;
    notch_offset_z = notch_z * 0.5 - collar_h;
    notch_r_z = [30, -30, 150, -150];

    if (part == "inside")
    {
        // hole for the motor body
        translate([0, 0, -holder_h])
            flattened_cylinder(motor_d + motor_d_margin,
                               motor_w + motor_d_margin,
                               holder_h - collar_h);
    }
    else difference()
    {
        // outer cylinder for the motor holder
        translate([0, 0, -holder_h * 0.5])
            cylinder(d = holder_od, h = holder_h, center = true);
        
        // hole for the motor body
        translate([0, 0, -holder_h - collar_h])
            flattened_cylinder(motor_d + motor_d_margin,
                               motor_w + motor_d_margin,
                               holder_h);
        
        // hole for the motor collar
        translate([0, 0, -collar_h - 1])
            cylinder(d = collar_d + collar_d_margin, h = collar_h + 2);

        // holes for the mounting screws
        for(xyz = screw_offsets) translate(xyz)
        {
            rotate(180, [1,0,0])
                flat_head_screw_hole(screw_hole_d, collar_h + 1,
                                     head_d, head_h, 1);
        }

        // holes for access notches
        for(r_z = notch_r_z)
        {
            rotate(r_z, [0, 0, 1])
            translate([notch_offset_x + 1, 0,
                       1 - notch_offset_z - collar_h])
                cube([notch_x + 2, notch_y, notch_z + 2],
                    center=true);    
        }
    }
}
