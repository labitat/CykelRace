// indlæg til kopper i home trainer, til at centrere bolte i home trainer

difference() {
	color ([1,0,0]) cylinder (r=9,h=6);
	translate([0,0,-1]) {	color ([1,0,0]) cylinder (r=2.5,h=3);	}

	translate([0,0,1]) {
		color ([1,0,0]) cylinder (r2=7, r1=4,h=5.01);
	}
}