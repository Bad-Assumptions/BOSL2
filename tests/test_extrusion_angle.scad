include <../extrusion_angle.scad>
//TESTS
//vslot_tongue(profile=20, offset=0.2, anchor=BOTTOM+LEFT);
//left(20) vslot_tongue(profile=30, offset=0);
//_vslot_section_2d(profile=40);
//vslot_tongue(offset=1, anchor=BOTTOM) show_anchors();
//*extrusion_angle();
*extrusion_angle() show_anchors();
extrusion_angle(height=20, thickness=1/16*25.4, width=1.5*25.4, anchor=BOTTOM+LEFT+FRONT);