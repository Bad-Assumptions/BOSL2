//////////////////////////////////////////////////////////////////////
// LibFile: mounting_plate.scad
//   The modules in this file create flat mounting plates with the hole patterns you specify
// Includes:
//   include <BOSL2/std.scad>
// FileGroup: [TBD]
// FileSummary: create flat mounting plates with the specified hole patterns
//////////////////////////////////////////////////////////////////////
// TODO validiate size is vec3
// TEST holes on FRONT, BACK. LEFT and RIGHT
// TODO add offset to hole at surface
include <../BOSL2/std.scad>

// Function: monting_plate_dims(size, [holes])
// Synopsis: returns [size, anchors]
// Module: mounting_plate()
// Synopsis: creates a mounting plate with the specified hole patterns
// SynTags: 
// Topics: 
// Usage:
//   mounting_plate(size, [holes], ...) CHILDREN;
// Description:
//   Creates a plate of size [size] with holes specified by the rows in [holes]
// Arguments:
//   size = a 3D vector that contains the XY size of the bottom of the cuboidal volume, and the Z height
//   holes = list of hole definitions:
//    [position, orientation, size] where
//      position = is a vec2, x and y distance from CENTER
//      orientation = one of the standard orientations (e.g. TOP, RIGHT, TOP+RIGHT)
//      size = [diameter, depth], where depth is in the direction opposite of orientation
//   ---
//   anchor = Translate so anchor point is at origin (0,0,0).  See [anchor](attachments.scad#subsection-anchor).  Default: `CENTER`
//   spin = Rotate this many degrees around the Z axis after anchor.  See [spin](attachments.scad#subsection-spin).  Default: `0`
//   orient = Vector to rotate top towards, after spin.  See [orient](attachments.scad#subsection-orient).  Default: `UP`
// Side Effects:
// Example: 
function mounting_plate_dims(size=[100, 100, 5], holes = []) = [size, [for(i = [0:len(holes)-1]) named_anchor(str("hole_",i+1), concat(holes[i][0], 0), holes[i][1])]];

module mounting_plate(size=[100, 100, 5], holes = [], anchor, spin=0, orient=UP) {
  DIM_ANCHOR=1;
  
  module shape(size, holes) {
    difference() {
      cuboid(size);
      #for (h = holes) {
        p = [h[0].x, h[0].y, size.z/2*h[1].z];
        translate(p) cyl(d=h[2][0], h=h[2][1], anchor=h[1], orient=TOP);
      }
    }
  }
  
  anchors=mounting_plate_dims(size, holes)[DIM_ANCHOR];
  echo(holes=holes, anchors=anchors);
  
  attachable(anchor,spin,orient, size=size, anchors=anchors) {
    shape(size=size, holes=holes);
    children();
  }
}

//TESTS
holes=[
[[-45, -45], TOP, [5,2]],
[[-45, -45], TOP, [3,6]],
[[-45, 45], BOTTOM, [5,2]],
];

mounting_plate(size=[100,100,5], holes=holes) show_anchors();
//module basic_mounting_plate(width=10, slot_length=90,slot_d=3, text, center, anchor, spin=0, orient=UP) {
//    slot_total_length = slot_length + slot_d;
//    txt = is_def(text) ? text : "";
//
//    anchor = get_anchor(anchor, center, -[1,1,1], -[1,1,1]);
//    size = scalar_vec3([width,frame_width,thick_plate_t]);
//	anchors = [
//		named_anchor("hole_back_top", [0,vslot_distance/2,thick_plate_t/2], TOP, 0),
//		named_anchor("hole_front_top", [0,-vslot_distance/2,thick_plate_t/2], TOP, 0),
//		named_anchor("hole_back_bottom", [0,vslot_distance/2,-thick_plate_t/2], BOTTOM, 0),
//		named_anchor("hole_front_bottom", [0,-vslot_distance/2,-thick_plate_t/2], BOTTOM, 0),
//		named_anchor("slot_front_top", [0,slot_length/2,thick_plate_t/2], TOP, 0),
//        
//	];
//        
//    module shape() {
//        difference() {
//            union() {
//              // plate
//              linear_extrude(thick_plate_t, center=true) rect([width, frame_width], rounding = default_fillet);
//              // vslot tongue
//              yflip_copy() back(vslot_distance/2) down(thick_plate_t/2) vslot_tongue(offset=0.4, anchor=BOTTOM, orient=BOTTOM, spin=90);
//            }
//          
//            yflip_copy() back(vslot_distance/2) {
//              // vslot tap holes
//              cyl(d = M4_tap_hole_d, h = thick_plate_t+40 + 2*epsilon, anchor=CENTER);
//              // vslot counterbore holes
//              up(thick_plate_t/2+epsilon) cyl(d = M4_head_d, h = M4_head_d + 2*epsilon, anchor=TOP);
//            }
//            // power supply through-slot
//            linear_extrude(thick_plate_t+2*epsilon, center=true) rect([M3_through_hole_d, slot_total_length], rounding = M3_through_hole_d/2);
//            // part number
//            right(width*.5) down(thick_plate_t/2) rotate([0,180,-90]) linear_extrude(1, center=true) text(text=txt, size=M3_through_hole_d, halign="center", valign="top");        }
//        
//    }
//    
//    attachable(anchor,spin,orient, size=size, anchors=anchors) {
//        shape();
//        children();
//    }
//}
