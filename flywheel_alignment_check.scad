$fa=0.01;
$fs=0.2;

// flywheel
fw_dist = 43; // separation between centers of flywheels
fw_h = 14; // height of flywheel
fw_od = 35; // diameter
fw_angle = 5; // canted angle
fw_offset = 0.6; // adjust the alignment of flywheels

cage_od = 41;

barrel_d = 15;
funnel_h = 6;

fw_x = fw_dist / 2;
fw_z = -fw_h / 2;

intersection()
{
    // flywheel cylinders
    fw_xfrm = [[[-fw_x, fw_offset, fw_z],  fw_angle, [1, 0, 0]],
                 [[ fw_x, -fw_offset, fw_z], -fw_angle, [1, 0, 0]]];
    for(xfrm = fw_xfrm)
        translate(xfrm[0]) rotate(xfrm[1], xfrm[2])   
            cylinder(d = fw_od, h = fw_h);

    // carve out the barrel
    translate([0, -funnel_h - 1, 0]) rotate(90, [1, 0, 0])
        cylinder(d = barrel_d, h = cage_od + 2, center = true);
}
