// Brian Alano
// (C) Brian Alano, 2024
// Released under the BSD 2-Clause Licensea

include <../BOSL2/std.scad>
include <../BOSL2/attachments_extras.scad>


// Module: _vslot_section_2d
// Arguments:
// height, thickness, width
// Example:
// extrusion_angle(height=10, thickness=1/16*25.4, width=1.25*25.4, anchor=CENTER) attach(RIGHT) anchor_arrow();
// Requires: <BOSL2/std.scad>
// Requires: <BOSL2/attachments_extras.scad>

module _angle_section_2d(thickness, width) {
  x0=0;
  y0=0;
  x1=thickness;
  y1=width;
  x2=width;
  y2=thickness;
  pnts = [
      [x0,y0],[x0,y1],[x1,y1],[x1,y2],[x2,y2],[x2,y0]
  ];
  translate([-width/2, -width/2]) polygon(points=pnts);
}

function extrusion_angle_geom(height, width) = 
  let (
    size = scalar_vec3([width, width, height])
    //anchor = get_anchor(anchor, center, -[1,1,1], -[1,1,1])
  )
  attachable_geom(size=size);

// Module: extrusion_angle
// Arguments:
// height = height of the extrusion, default 10
// width = width of each side, default 10
// thickness = material thickness, default 1
// Example:
// extrusion_angle(height=100, width=25, anchor=CENTER) attach(RIGHT) anchor_arrow();
// Requires: <BOSL2/std.scad>
// Requires: <BOSL2/attachments_extras.scad>
module extrusion_angle(height=10, thickness=1, width=10, center, anchor, spin=0, orient=UP) {
    geom = extrusion_angle_geom(height=height, width=width);
    echo(geom=geom);
    module shape() {
        linear_extrude(height=height) {
            _angle_section_2d(thickness, width);
        }
    }
    
    attachable(anchor,spin,orient, geom=geom) {
        down(height/2) shape();
        children();
    }

}

