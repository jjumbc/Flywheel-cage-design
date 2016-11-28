//$fa=0.01; // Turn these on for high precision before rendering
//$fs=0.2;

use <motor_holder.scad>
use <flywheel.scad>

// flywheel
fw_dist = 43; // separation between centers of flywheels
fw_h = 14; // height of flywheel
fw_angle = 5; // canted angle
fw_offset = 0.6; // adjust the alignment of flywheels

z_adj = 10; // how much to lift the motor mounts to get under the flywheels

holder_od = 27;
holder_h = 15;

cage_od = 41;
cage_id = 37.5;
cage_h = 18;
cage_bottom_h = 2;

barrel_d = 15;
funnel_d1 = 22;
funnel_d2 = 14;
funnel_h = 6;

// locations of mounting screws
mount_t_xyz = [[-51/2, -44/2, 0],
               [ 51/2, -44/2, 0],
               [-51/2,  44/2, 0],
               [-51/2 + 61, -44/2 + 39, 0]];

// flywheels (ghosts)
fw_x = fw_dist / 2;
fw_z = -fw_h / 2;
fw_xfrm = [[[-fw_x, fw_offset, fw_z],  fw_angle, [1, 0, 0]],
             [[ fw_x, -fw_offset, fw_z], -fw_angle, [1, 0, 0]]];
%for(xfrm = fw_xfrm)
    translate(xfrm[0]) rotate(xfrm[1], xfrm[2])   
        flywheel();

difference()
{
    union()
    {
        // middle of cage
        translate([0, 0, fw_z + z_adj - holder_h + cage_h/2])
            cube([fw_dist, cage_od, cage_h], center = true);
        
        intersection()
        {
            // solid cylinders to carved out
            union()
            {
                translate([-fw_x, 0, fw_z + z_adj - holder_h])
                    cylinder(d = cage_od, h = cage_h);

                translate([fw_x, 0, fw_z + z_adj - holder_h])
                    cylinder(d = cage_od, h = cage_h);
            }
            
            // limit the extent in the X direction to fit in the blaster
            cube([77, 100, 100], center = true);
        }

        // cylinders for mounting screws
        for(xyz = mount_t_xyz) translate(xyz)
        {
            cylinder(d = 8, h = 6, center = true);
        }
    }

    // for each flywheel
    for(xfrm = fw_xfrm)
        translate(xfrm[0]) rotate(xfrm[1], xfrm[2])
        translate([0, 0, z_adj])
    {
        // carve out space for the flywheel
        translate([0, 0, -holder_h + cage_bottom_h])
            cylinder(d = cage_id, h = cage_h + 100);

        // carve out the hole for the motor
        rotate(90, [0, 0, 1])
            motor_holder(holder_od, cage_h + 100, part="inside");
        
        // access holes to remove flywheels
        for(r_z = [0, 180]) rotate(r_z, [0, 0, 1])
            translate([0, (holder_od + cage_id)/4, 0])
                cylinder(d = (cage_id - holder_od) / 2,
                         h = 100, center = true);
    }
    
    // carve out the barrel
    translate([0, -funnel_h - 1, 0]) rotate(90, [1, 0, 0])
        cylinder(d = barrel_d, h = cage_od + 2, center = true);
    
    // carve out the funnel
    *translate([0, (cage_od - funnel_h)/2, 0]) rotate(90, [1, 0, 0])
        cylinder(d1 = funnel_d1, d2 = funnel_d2, h = funnel_h, center = true);
    // note - this is extra magic to avoid ambiguous bundaries
    translate([0, (cage_od - funnel_h)/2, 0]) rotate(90, [1, 0, 0])
        cylinder(
          d1 = funnel_d2 + (funnel_d1 - funnel_d2) * (funnel_h + 1) / funnel_h,
          d2 = funnel_d2 + (funnel_d1 - funnel_d2) * (-1) / funnel_h,
          h = funnel_h + 2, center = true);
    
    // carve out the holes for mounting screws
    for(xyz = mount_t_xyz) translate(xyz)
    {
        cylinder(d = 4, h = 100, center = true);
        translate([0, 0, 1])
            cylinder(d = 6.5, h = 100, $fn = 6);
        translate([0, 0, -1]) rotate(180, [1, 0, 0])
            cylinder(d = 6.5, h = 100, $fn = 6);
    }

    // carve out space for an obstruction on the front bottom of the cage
    difference()
    {
        translate([0, -43/2 + 4/2, -10])
            cube([22, 4, 10], center = true);
        rotate(90, [1, 0, 0])
            cylinder(d = 21.5, h = cage_od + 4,
                     center = true);
    }

    // carve out space for an obstruction on the cage's corner
    translate([-51/2 - 8, 43/2 - 6, 5])
        cylinder(d = 7, h = 10, center = true);
    translate([-37.5, 13, 0])
        cylinder(d = 11, h=100, center = true);
    // Ad-hoc - Remove an extra small sliver of material that remains
    translate([-38.5, 8, 5])
        cylinder(d = 2, h=4, center = true);
}

difference()
{
    // place the motor holders
    for(xfrm = fw_xfrm)
        translate(xfrm[0]) rotate(xfrm[1], xfrm[2])
        translate([0, 0, z_adj]) rotate(90, [0, 0, 1])
        motor_holder(holder_od, holder_h);
    
    // remove the rotated bits that project below the bottom of the cage
    translate([0, 0, fw_z + z_adj - holder_h - cage_h/2])
        cube([100, 100, cage_h], center = true);
}
