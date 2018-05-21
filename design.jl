type Barrier
	height
	base_width
	base_thickness
	base_length
	span_length
	key_depth
	wall_t
	span_t
end
barrier=Barrier(0,0,0,0,0,0,0,0)
type Constants
	spec_water
	spec_base
	spec_soil
	mat_shear
	spec_mat
	Cb
	Cf
	Kp
	Sb
	cube_stren
	con_stats
	young
	bstress
	flange_coeff
	seal_select
end
constants=Constants(64,0,0,0,0,0,0,0,0,0,true,0,0,0,2)
function fvertical(constants,barrier)
	#wall_con= weight(constants.spec_mat,barrier.wall_t,barrier.height,barrier.span_length)
	wall_con = 0
	basew=weight(constants.spec_base,barrier.base_length,barrier.base_width,barrier.base_thickness)
	Wwat=weight(constants.spec_water,heel(barrier.base_width,barrier.wall_t),barrier.base_length,barrier.height)
	fb=Fbuoy(constants.spec_water,barrier.base_width,barrier.base_length,barrier.base_thickness)
	fv=Fv(basew,Wwat,wall_con,fb)
	return fv
end
function Fres(constants,barrier)
	friction=Fr(constants.Cf,fvertical(constants,barrier))
	fc=Fc(constants.Cb,barrier.base_width)
	fp=Fp(constants.Kp,constants.spec_soil,constants.spec_water,barrier.base_thickness,barrier.base_length)
	barrier.key_depth = 1.2 * barrier.base_thickness
	tkey = barrier.key_depth + barrier.base_thickness
	fkey= Fkey(constants.Kp,constants.spec_soil,constants.spec_water,tkey,barrier.base_length)
	fwall = Fwall(constants.Kp,constants.spec_soil,constants.spec_water,barrier.base_thickness,barrier.span_length,barrier.base_length)
	resf=friction+fc+fp+fkey+fwall
	return resf
end
function design(constants,barrier)
	#for redesign of barrier
	barrier.base_length=base_len(barrier.base_width)
	barrier.base_thickness=base_thick(barrier.base_width)
	Fst=F_sta(constants.spec_water,barrier.height,tst(barrier.span_length,barrier.wall_t))
	Fresist=Fres(constants,barrier)
	ans=Fresist/Fst
	return ans
end
function output_dimensions(barrier)
	height=barrier.height
	bwd=barrier.base_width
	blen=barrier.base_length
	bthick=barrier.base_thickness
	wallt = barrier.wall_t
	wallh = barrier.height
	println("barrier height: $height , base width: $bwd , base length: $blen")
	println("base thickness: $bthick")
	x=[barrier.height barrier.wall_t barrier.base_width barrier.base_thickness barrier.base_length barrier.span_length barrier.key_depth barrier.span_t]
	filepath ="./barrier/barrier.csv"
	fid1 = open(filepath,"w")
	writecsv(fid1,x)
	close(fid1)
end
function Mres(constants,barrier)
	Mbase = Mbse(weight(constants.spec_base,barrier.base_width,barrier.base_length,barrier.base_thickness),barrier.base_width)
	wallwt=0.5*weight(constants.spec_mat,barrier.wall_t,barrier.span_length,barrier.height)
	Mwwt = Mwallwt(wallwt,toe(barrier.base_width,barrier.wall_t),barrier.wall_t)
	wh =weight(constants.spec_water,heel(barrier.base_width,barrier.wall_t),barrier.base_length,barrier.height)
	Mwheel=Mwh(wh,barrier.base_width,heel(barrier.base_width,barrier.wall_t))
	fp=Fp(constants.Kp,constants.spec_soil,constants.spec_water,barrier.base_thickness,barrier.base_length)
	Mfp = M_fp(fp,barrier.base_thickness)
	fwall = Fwall(constants.Kp,constants.spec_soil,constants.spec_water,barrier.base_thickness,barrier.span_length,barrier.base_length)
	Mwall =Mfwall(fwall,barrier.base_thickness)
	fkey = Fkey(constants.Kp,constants.spec_soil,constants.spec_water,barrier.key_depth,barrier.base_length)
	Mkey =Mfkey(fkey,barrier.key_depth)
	Mresisting=Mfp+Mwwt+Mbase+Mwheel+Mwall+Mkey
	return Mresisting
end
function overturning(constants,barrier)
	#barrier.base_thickness = base_thick(barrier.base_width)
	barrier.base_length = base_len(barrier.base_width)
	fst=F_sta(constants.spec_water,barrier.height,tst(barrier.span_length,barrier.wall_t))
	Mst=M_sta(fst,barrier.height,barrier.base_thickness)
	hel=heel(barrier.base_width,barrier.wall_t)
	toy=toe(barrier.base_width,barrier.wall_t)
	fbuoy1=fboy1(constants.spec_water,barrier.height,barrier.wall_t,hel,barrier.base_thickness,barrier.base_length)
	fbuoy2=fboy2(constants.spec_water,toy,barrier.wall_t,barrier.base_thickness,barrier.base_length)
	Mbouy=M_bouy(fbuoy1,fbuoy2,barrier.base_width)
	Mov=Mst+Mbouy
	Mresist=Mres(constants,barrier)
	ans=Mresist/Mov
	return [ans,Mov]
end
function Ecentricity(constants,barrier)
	Mr=Mres(constants,barrier)
	Mover=overturning(constants,barrier)
	fv =fvertical(constants,barrier)
	ece = ecentricity(barrier.base_width,Mr,Mover[2],fv)
	return ece
end
function soil_pressure(constants,barrier,k)
	o = []
	fv = fvertical(constants,barrier)
	o1 = soil_p(fv,barrier.base_length,barrier.base_width,k)
	o2 = soil_p1(fv,barrier.base_length,barrier.base_width,k)
	o = [o1,o2]
	return o
end
function reinforcement(constants,barrier,k)
	l = soil_pressure(constants,barrier,k)
	qmin = l[2]
	qmax = l[1]
	x = heel(barrier.base_width,barrier.wall_t)+ barrier.wall_t
	q =(((qmin-qmax)/barrier.base_width)*x)+qmax
	C = toe(barrier.base_width,barrier.wall_t)
	Mb = (q+(2*qmax))*((C^2)/6)
	df = 12*0.10*(barrier.base_thickness)
	A1 = Are_a(Mb,df)
	println("Area in inch2 : $A1")
	water_w = weight(constants.spec_water,heel(barrier.base_width,barrier.wall_t),barrier.base_length,barrier.height)
	Ah = 0.5*heel(barrier.base_width,barrier.wall_t)
	Mb = water_w*Ah
	A2 = Are_a(Mb,df)
	println("Area in inch2 : $A2")
end