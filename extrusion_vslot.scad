// Brian Alano
// (C) Brian Alano, 2023 
// Released under the BSD 2-Clause Licensea

include <std.scad>

// Module: _vslot_section_2d
// Arguments:
// profile = profile side length in mm. Default 20
// Example:
// extrusion_vslot(profile=20, height=10, anchor=CENTER) attach(RIGHT) anchor_arrow();
// Requires: <BOSL2/std.scad>
module _vslot_section_2d(profile) {
  s1 = 1.8;
  s2 = 2;
  s3 = 6;
  s4 = 6.2;
  s5 = 9.5;
  s6 = 10.6;
  s7 = 20;

  reSize = profile/20; // Scaling

  k0 = 0;
  k3 = ( (s7*0.5-s3)-s1*0.5*sqrt(2) )*reSize;
  k4 = s4*0.5*reSize;
  k5 = ( s7*0.5-s3 )*reSize; //10*profile/20 - (4)*(profile/20) = 6*profile/20
  k6 = s6*0.5*reSize;
  k7 = ( s6*0.5+s1*0.5*sqrt(2) )*reSize;
  k8 = ( s7*0.5-s2 )*reSize;
  k9 = s5*0.5*reSize;
  k10 = s7*0.5*reSize;
//echo(k3=k3,k6=k6,k4=k4,k9=k9);
  pnts = [
      [k0,k5],[k3,k5],
      [k6,k7],[k6,k8],[k4,k8],[k9,k10], [k0,k10],
  ];
  polygon(points=pnts);
}

// Module: extrusion_vslot
// Arguments:
// profile = profile side length in mm. Default 20
// height = height of the extrusion, default 10
// Example:
// extrusion_vslot(profile=20, height=10, anchor=CENTER) attach(RIGHT) anchor_arrow();
// Requires: <BOSL2/std.scad>
module extrusion_vslot(profile=20, height=10, center, anchor, spin=0, orient=UP) {
    anchor = get_anchor(anchor, center, -[1,1,1], -[1,1,1]);
    size = scalar_vec3([profile,profile,height]);
        
    module shape() {
        linear_extrude(height=height) {
            difference() {
                rect([profile,profile], rounding=profile/20.*1.5);
                rot_copies(rots=[0,90,180,270]) xflip_copy() _vslot_section_2d(profile=profile);
                circle(r=2.5*profile/20);
            }
        }
    }
    
    attachable(anchor,spin,orient, size=size) {
        down(height/2) shape();
        children();
    }

}

// Module: vslot_tongue
// Description: 
//    Primitive to create a tongue to fit in the vslot groove.
// Topics: Parts, Power Supplies
// See also: extrusion_vslot()
// Usage: As Module
//		power_supply_generic([profile], [height], [offset], 	[center], [anchor], [spin], [orient]) [ATTACHMENTS]);
// Arguments:
// ---
//   profile = profile side length in mm. Default 20
//   height = height of the tongue, default 10
//   offset = inward offset so the tongue can slide easily in the groove, default 02
//	 center = If given, overrides `anchor`.  A true value sets `anchor=CENTER`, false sets `anchor=FRONT+LEFT+BOTTOM`.
//   anchor = Translate so anchor point is at origin (0,0,0).  See [anchor](attachments.scad#subsection-anchor).  Default: `CENTER`
//   spin = Rotate this many degrees around the Z axis after anchor.  See [spin](attachments.scad#subsection-spin).  Default: `0`
//   orient = Vector to rotate top towards, after spin.  See [orient](attachments.scad#subsection-orient).  Default: `UP`
//  Side Effects:
//  Known Issues:
//    The left and right edge anchors are not on the body.
//    The left and right face anchors are not be on the body if offset >~2.
//  Example:
//    vslot_tongue(profile=20, height=10, anchor=CENTER) attach(RIGHT) anchor_arrow();
//  Requires: <BOSL2/std.scad>

module vslot_tongue(profile=20, height=10, offset=0.2, center, anchor, spin=0, orient=UP) {
  anchor = get_anchor(anchor, center, -[1,1,1], -[1,1,1]);
  size = scalar_vec3([((10.6/20*profile)-offset*2), height, 6/20*profile-offset]);
  module shape() {
    linear_extrude(height=height) {
      difference() {
        offset(r=-offset) {
          xflip_copy() fwd(profile/2) _vslot_section_2d(profile=profile); 
          // attach a base to cover the gap left otherwise left by the offset
          base_size = (profile-1)/2;
          back(base_size/2) square(base_size, center=true);
        }
        // trim the excess
        back(profile/2) square(profile, center=true);
      }
    }
  }
    
  attachable(anchor,spin,orient, size=size) {
    translate([0,-size.y/2, -size.z/2]) rotate([-90,0]) shape();
      children();
  }
}

//vslot_tongue(profile=20, offset=0.2, anchor=BOTTOM+LEFT);
//left(20) vslot_tongue(profile=30, offset=0);
//_vslot_section_2d(profile=40);
//vslot_tongue(offset=1, anchor=BOTTOM) show_anchors();
