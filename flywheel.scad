$fa=0.01;
$fs=0.5;

flywheel();

module flywheel()
{
    fw_h = 14;
    fw_od = 37; //35
    fw_id = 30;
    fw_top_h = 1;
    fw_peg_top_h = 5;
    fw_peg_bottom_h = 0.5;
    fw_peg_od = 6;
    fw_peg_id = 2;

    fw_inner_h = fw_h - fw_top_h;
    peg_total_h = fw_peg_top_h + fw_top_h + fw_peg_bottom_h;
    peg_t_z = fw_h - fw_top_h - fw_peg_bottom_h;

    difference()
    {
        union()
        {
            difference()
            {
                cylinder(d = fw_od, h = fw_h);

                translate([0,0, -1])
                    cylinder(d = fw_id, h = fw_inner_h + 1);
            }

            translate([0, 0, peg_t_z])
                cylinder(d = fw_peg_od, h = peg_total_h);
        }

        translate([0, 0, peg_t_z - 1])
            cylinder(d = fw_peg_id, h = peg_total_h + 2);
    }
}
