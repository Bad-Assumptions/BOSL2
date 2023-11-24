//include <BOSL2/std.scad>
//include <BOSL2/lists.scad>

// parameters to power_supply_generic for specific models
// list is [model, size, terminals, cuts, holes]
ps_models = [
	["JOYLIT S-120-24", 
		[98, 198, 42], // size
		[[9.5, 16, 16], 7, [10.5, 0, 7.5]], // terminals
		[[[96.83, 14.94, 35], [-0.02, -0.02, 7.5]]], // cuts
		[ // holes
			[[3.5, 3/2], [8.84, 61.68, -0.01], UP],
			[[3.5, 3/2], [8.84+80, 61.68, -0.01], UP],
			[[3.5, 3/2], [8.84, 61.68+120, -0.01], UP],
			[[3.5, 3/2], [8.84+80, 61.68+120, -0.01], UP],
		]
	]
];

function _downcase_if_str(s) = is_string(s) ? downcase(s) : s;

// Function&Module: power_supply_generic
// Function: returns the VNF of the overall rectangular prismatic shape (i.e. of the basic cube)
// Anchor points:
//   In addition to the standard cube anchor point, there is an anchor point for each hole, named "holeN", where N is the nth terminal.
//    Note: position() is working, but attach() gives "ERROR: Assertion '(is_undef(from) == is_undef(to))' failed: "from and to must be specified together." in file BOSL2/transforms.scad, line 541 "
// Arguments:
//   size = The overal size of the power supply.
//   terminals = vector defining the terminal block. It assumes each terminal is identical and all are in a row.
//      terminals[0] =  size argument to a cube defining the shape of a single terminale
//      terminals[1] = number of terminals
//      terminals[2] = offset - positional offset from the power supply origin to the rear left bottom corner of the leftmost terminal
//      Example: terminals = [ [[9.5,16,16]], 7, [10.5, 16.8, 7.5]] defines 7 terminals each sized 9.5x16x16 whose left rear bottom is offset 10.5 x 16.8 x 7.5 from the power supply origin
//   cuts = a vector of cubic cuts to make in the cuboid power supply. Each cut is tuple. 
//       Each cut tuple is a size argument to the cube module and a positional offset from the power supply origin
//	     Example cuts = [[2,3,4], [0,0,0]] is a 2 x 3 x 4 cut whose bottom rear left corner is on the origin
//   holes = a vector defining cylindrical holes in the power supply, such as mounting holes. Each hole is a tuple.
//       Each hole tuple is vector of arguments to the cylinder module and a position offset from the power supply origin
//	 ---
//   center = If given, overrides `anchor`.  A true value sets `anchor=CENTER`, false sets `anchor=FRONT+LEFT+BOTTOM`.
//   anchor = Translate so anchor point is at origin (0,0,0).  See [anchor](attachments.scad#subsection-anchor).  Default: `CENTER`
//   spin = Rotate this many degrees around the Z axis after anchor.  See [spin](attachments.scad#subsection-spin).  Default: `0`
//   orient = Vector to rotate top towards, after spin.  See [orient](attachments.scad#subsection-orient).  Default: `UP`
// example	
/*	
size=[98, 198, 42];
psg = power_supply_generic(size);
terminals= [[9.5, 16, 16], 7, [10.5, 0, 7.5]];
cuts=[[[96.83, 14.94, 35], [-0.01, -0.01, 7.5]]];
holes= [
		[[3.5, 3/2], [8.84, 61.68, -0.01]],
		[[3.5, 3/2], [8.84+80, 61.68, -0.01]],
		[[3.5, 3/2], [8.84, 61.68+120, -0.01]],
		[[3.5, 3/2], [8.84+80, 61.68+120, -0.01]]
	];
// power_supply_generic(size=size, terminals = terminals, cuts = cuts, holes = holes);
*/
function power_supply_generic(size=1, 
	terminals,
	cuts,
	holes,
	center, anchor, spin=0, orient=UP) = 
     cube(size=size, center=center, anchor=anchor, spin=spin, orient=orient);

// cuts and terminals and holes as children?
module power_supply_generic(size=1, 
	terminals = [],
	cuts = [], 
	holes = [],
	center, anchor, spin=0, orient=UP) {
	
	module shape() {
		translate(-size/2) {
			difference() {
				// basic shape
				cube(size);
				// cuts
				for(c = cuts) {
					translate(c[1]) cube(c[0]); 
				}
				// holes
				for(h = holes) {
					translate(h[1]) cyl(h[0][0], h[0][1], anchor=BOTTOM, orient=h[2]);
				}
			}
			// terminals
			echo(terminals=terminals);
			translate(terminals[2]) cube(size=[terminals[0].x*terminals[1], terminals[0].y, terminals[0].z]);
		}
	}

	anchors = [
		for (i = [0:len(holes)-1])
			let( ) each [
            	named_anchor(str("hole",i), holes[i][1]-size/2, holes[i][2], 0)
        	]
	];
	echo(anchors=anchors);
   	anchor = get_anchor(anchor, center, -[1,1,1], -[1,1,1]);
    echo(anchor=anchor);
    size = scalar_vec3(size);
    attachable(anchor,spin,orient, size=size, anchors=anchors) {
        shape();
        children();
    }
}

function power_supply_model(model, center, anchor, spin, orient) = let(mod = power_supply_model_params(model))
    power_supply_generic(mod[1], mod[2], mod[3], mod[4], center, anchor, spin, orient) ;

function power_supply_model_params(model) = [for (m = ps_models) each
	if (_downcase_if_str(m[0]) == _downcase_if_str(model)) m];
    
module power_supply_model(model, center, anchor, spin, orient) {
	mod = [for (m = ps_models) each
		if (_downcase_if_str(m[0]) == _downcase_if_str(model)) m];
	echo(mod=mod);
	power_supply_generic(mod[1], mod[2], mod[3], mod[4], center, anchor, spin, orient) 
	children();
}

//echo("power_supply_model vfd", power_supply_model("JOYLIT S-120-24", spin=90 , anchor=CENTER, orient=UP));
//power_supply_model("JOYLIT S-120-24", spin=90 , anchor=CENTER, orient=UP)
//position("hole1") 
//anchor_arrow(orient=DOWN); 
