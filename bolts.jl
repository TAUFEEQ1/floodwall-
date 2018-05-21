type bolts
	area
	hef
	cedge
	embeddment_depth
	min_hole_depth
	hole_diameter
	spacing
	fixture_thickness
end
bolt = bolts(0,0,0,0,0,0,0,0)
type bolts_consts
	fut
	fyk
	kcr
end
bconsts=bolts_consts(0,0,0)
function tension_design(bolt,bconsts,tdata,dest,n)
	#define tensr
	coln = names(tdata)
	bolt_data = tdata[coln[n]]
	bolt.area = bolt_data[4]
	bconsts.fut = bolt_data[2]
	bconsts.fyk = bolt_data[1]
	tensr = Tensr(bolt.area,bconsts.fut)
	yms = Yms(bconsts.fut,bconsts.fyk)
	m = tensr/yms
	if m < dest
		if n==6
			println("bolts size required is beyond M20,changing flange_length")
			constants.flange_coeff = constants.flange_coeff + 1
			design_bolts(constants,barrier,bolt,bconsts)
		else
			n = n+1
			tension_design(bolt,bconsts,tdata,dest,n)
		end
	else
		return [n,coln[n]]
	end
end
function concrete_con(constants,bolt,bconsts,cdata,n,dest)
	coln = names(cdata)
	bolt_data = cdata[coln[n]]
	bolt.hef = bolt_data[1]
	bolt.cedge = bolt_data[2]
	bconsts.kcr = bolt_data[3]
	ccres = cconr(bconsts.kcr,bolt.hef,constants.cube_stren)
	m = ccres/1.5
	if m < dest
		if n==6
			println("bolts size required is beyond M20,changing flange_length")
			constants.flange_coeff = constants.flange_coeff + 1
			design_bolts(constants,barrier,bolt,bconsts)
		else
			n = n+1
			concrete_con(constants,bolt,bconsts,cdata,n,dest)
		end
	else
		return [n,coln[n],ccres]
	end
end
function shear_resistance(sdata,fst,n)
	coln =names(sdata)
	bolt_data = sdata[coln[n]]
	stren = bolt_data[1]
	stren =1000*stren
	m = stren/1.25
	if m < fst
		if n==6
			println("bolts size required is beyond M20,changing flange_length")
			constants.flange_coeff = constants.flange_coeff + 1
			design_bolts(constants,barrier,bolt,bconsts)
		else
			n= n+1
			shear_resistance(sdata,fst,n)
		end
	else
		return [n,coln[n]]
	end
end
function concrete_edge(constants,edge_data,fst,c1,n)
	coln = names(edge_data)
	bolt_data = edge_data[coln[n]]
	dnom = bolt_data[1]
	c1 = c1*304.5
	le = bolt_data[2]
	alph = 0.1*((le/c1)^0.5)
	fc = constants.cube_stren
	bet = 0.1*((dnom/c1)^0.2)
	k1 = 1.35
	Vedge = edge_res(k1,dnom,alph,le,bet,fc,c1)
	m = Vedge/1.5
	if m < fst
		if n==6
			println("bolts size required is beyond M20,changing flange_length")
			constants.flange_coeff = constants.flange_coeff + 1
			design_bolts(constants,barrier,bolt,bconsts)
		else
			n = n+1
			concrete_edge(constants,edge_data,fst,c1,n)
		end
	else 
		return [n,coln[n]]
	end
end
function pry_out_resistance(pry_data,nrc,n,fst)
	coln = names(pry_data)
	bolt_data = pry_data[coln[n]]
	k = bolt_data[1]
	pry_res = k*nrc
	if pry_res < fst
		if n==6
			println("bolts size required is beyond M20,changing flange_length")
			constants.flange_coeff = constants.flange_coeff + 1
			design_bolts(constants,barrier,bolt,bconsts)
		else
			n = n+1
			pry_out_resistance(pry_data,nrc,n,fst)
		end
	else
		return [n,coln[n]]
	end
end
function design_bolts(constants,barrier,bolt,bconsts)
	tdata = CSV.read("./bolts/tension.csv")
	l = overturning(constants,barrier)
	movert = l[2]
	movert = 0.5*1355.75*movert
	bwallt = barrier.wall_t
	dest = des_t(movert,bwallt,constants.flange_coeff)
	n=2
	answer=tension_design(bolt,bconsts,tdata,dest,n)
	boltr= answer[2]
	println("Against tensile failure: $boltr")
	n=answer[1]
	cdata = CSV.read("./bolts/concrete_cone_resistance.csv")
	answer2 = concrete_con(constants,bolt,bconsts,cdata,n,dest)
	concr= answer2[2]
	println("Against concrete cone failure: $concr")
	n = answer2[1]
	if(n == 2)
		println("establish pull out resistance")
	end
	fst=F_sta(constants.spec_water,barrier.height,barrier.span_length)
	fst = 0.25*4.45*fst
	sdata = CSV.read("./bolts/shear_resistance.csv")
	ans = shear_resistance(sdata,fst,n)
	tans = ans[2]
	n = ans[1]
	println("steel shear resistance : $tans")
	c1 = toe(barrier.base_width,barrier.wall_t)
	c1 = c1 - (0.5*constants.flange_coeff*(barrier.wall_t))
	if c1 < 0
		constants.flange_coeff = constants.flange_coeff - 1
		design_bolts(constants,barrier,bolt,bconsts)
	end
	edge_data =CSV.read("./bolts/edge.csv")
	answ = concrete_edge(constants,edge_data,fst,c1,n)
	rans = answ[2]
	n = answ[1]
	println("Against edge failure : $rans")
	pry_data = CSV.read("./bolts/pry.csv")
	ansr = pry_out_resistance(pry_data,answer2[3],n,fst)
	xans = ansr[2]
	println("Against concrete pry-out : $xans")
	r = ansr[1]
	output_bolt_data(r,bolt)
	return 0
end
function output_bolt_data(n,bolt)
	temp_data = CSV.read("./bolts/base.csv")
	coln = names(temp_data)
	bolt_data = temp_data[coln[n]]
	bolt.hole_diameter = bolt_data[1]
	bolt.embeddment_depth = bolt_data[2]
	bolt.min_hole_depth = bolt_data[3]
	bolt.cedge = bolt_data[4]
	bolt.spacing = bolt_data[5]
	bolt.fixture_thickness = bolt_data[6]
	x=[bolt.hole_diameter bolt.embeddment_depth bolt.min_hole_depth bolt.cedge bolt.spacing bolt.fixture_thickness]
	filepath ="./bolts/hole_params.csv"
	fid1 = open(filepath,"w")
	writecsv(fid1,x)
	close(fid1)
end