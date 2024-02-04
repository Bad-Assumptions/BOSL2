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
include <../BOSL2/attachments_extras.scad>

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
// mounting_plate(size=[100,100,5], holes=holes) show_anchors();


function mounting_plate_geom(size=[100,100,5], holes=[]) =
  let (
    size = size,
    num_holes = len(holes)-1 < 0 ? 0 : len(holes) - 1,
    anchors = num_holes > 0 ? 
      [for(i = [0:num_holes]) named_anchor(str("hole_",i+1), concat(holes[i][0], holes[i][2][1]/2*holes[i][1][2]), holes[i][1])] 
    : 
      []
  )
  attachable_geom(size=size, anchors=anchors);

//*function mounting_plate_dims(size=[100, 100, 5], holes = []) = [size, [for(i = [0:len(holes)-1]) named_anchor(str("hole_",i+1), concat(holes[i][0], 0), holes[i][1])]];

module mounting_plate(size=_attach_geom_size(mounting_plate_geom()), holes = [], anchor, spin=0, orient=UP) {
  DIM_ANCHOR=8;

  module shape(size, holes) {
    epsilon=0.02;
    difference() {
      cuboid(size);
      for (h = holes) {
        p = [h[0].x, h[0].y, (size.z+epsilon)/2*h[1].z];
        translate(p) cyl(d=h[2][0], h=h[2][1]+epsilon, anchor=h[1], orient=TOP);
      }
    }
  }
  
  anchors=mounting_plate_geom(size, holes)[DIM_ANCHOR];
//  echo(holes=holes, anchors=anchors);
  
  attachable(anchor,spin,orient, size=size, anchors=anchors) {
    shape(size=size, holes=holes);
    children();
  }
}
