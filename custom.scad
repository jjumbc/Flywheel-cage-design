//$fa=0.01; // Turn these on for high precision before rendering
//$fs=0.2;

use <motor_holder.scad>
use <flywheel.scad>
use <text_on.scad>

// flywheel
fw_dist = 43; // separation between centers of flywheels
fw_h = 14; // height of flywheel
fw_angle = 0; // canted angle, 5
fw_offset = 0.6; // adjust the alignment of flywheels

z_adj = 10; // how much to lift the motor mounts to get under the flywheels

holder_od = 27;
holder_h = 15;

cage_od = 41;
cage_id = 37.5;
cage_h = 24;
cage_bottom_h = 2; 

barrel_d = 15;
funnel_d1 = 22;
funnel_d2 = 14;
funnel_h = 6;

// locations of mounting screws
mount_t_xyz = [[-51/2, -44/2, 0],
               [ 51/2, -44/2, 0],
               [-51/2,  44/2, 0],
               [-51/2 + 61.5, -44/2 + 39.5, 0]];

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
    difference(){
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
            translate([-12,0,0]){
            cube([99, 100, 100], center = true);
            }
        }

        // cylinders for mounting screws
        for(xyz = mount_t_xyz) translate(xyz)
        {
            cylinder(d = 8, h = 6, center = true);
        }
        
    }
       text_on_cube("ELITE", locn_vec=[0, -0.5, fw_z + z_adj - holder_h + cage_h/2], cube_size=[fw_dist, cage_od, cage_h],size=7, center = true, face="bottom", rotate=-90, font="Avenger"); 
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
                cylinder(d = (cage_id - holder_od) / 2.5,
                         h = 100, center = true);
    }
    
    // carve out the barrel
    translate([0, -funnel_h - 1, 0]) rotate(90, [1, 0, 0])
        cylinder(d = barrel_d, h = cage_od + 15, center = true);
    
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
        cylinder(d = 4, h = 6, center = true);
        translate([0, 0, 1])
            cylinder(d1 = 6.5, d2=3.25, h = 8);
        translate([0, 0, -1]) rotate(180, [1, 0, 0])
            cylinder(d = 6.5, h = 100);
    }

    
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
