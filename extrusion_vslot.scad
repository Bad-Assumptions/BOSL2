// Brian Alano
// (C) Brian Alano, 2023 
// Released under the BSD 2-Clause Licensea

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
    
    module section_2d() {
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
        k5 = ( s7*0.5-s3 )*reSize;
        k6 = s6*0.5*reSize;
        k7 = ( s6*0.5+s1*0.5*sqrt(2) )*reSize;
        k8 = ( s7*0.5-s2 )*reSize;
        k9 = s5*0.5*reSize;
        k10 = s7*0.5*reSize;
    
        pnts = [
            [k0,k5],[k3,k5],
            [k6,k7],[k6,k8],[k4,k8],[k9,k10],
            [k0,k10]
        ];
        
        polygon(points=pnts);
    }
    
    module shape() {
        linear_extrude(height=height) {
            difference() {
                rect([profile,profile], rounding=profile/20.*1.5);
                rot_copies(rots=[0,90,180,270]) xflip_copy() section_2d();
                circle(r=2.5*profile/20);
            }
        }
    }
    
    attachable(anchor,spin,orient, size=size) {
        down(height/2) shape();
        children();
    }

}




