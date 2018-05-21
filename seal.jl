type Seal
	thickness
	seating_pressure
	width
	len
end
seal = Seal(0,0,0,0)
function des_bolts(wm,fst,nbolts,shear,n)
	Sp = 225*0.14503773*1000
	bolt_data = CSV.read("./seal/bolts/bolts.csv")
	cols = names(bolt_data)
	bolt_props = bolt_data[cols[n]]
	Area1 = 0.00155*bolt_props[4]
	fi = Fi(Sp,Area1)
	if fi < wm 
		n = n+1
		des_bolts(wm,fst,nbolts,shear,n)
	else
		shear = shear*0.14503773*1000
		fst1 = (fst/nbolts)/144
		Area2 = fst1/shear
		if Area1 < Area2
			n = n+1
			des_bolts(wm,fst,nbolts,shear,n)
		else
			return [n,bolt_data]
		end
	end
end
function output_screw_dimensions(m)
	bolt_data = m[2]
	n = m[1]
	cols = names(bolt_data)
	bolt_props = bolt_data[cols[n]]
	pitch = bolt_props[2]
	bolt_diameter = bolt_props[1]
	minor_diameter = bolt_props[3]
	println("Seal screw: M$bolt_diameter X $pitch")
	x = [bolt_diameter pitch minor_diameter]
	filepath ="./seal/bolts/screw_data.csv"
	fid = open(filepath,"w")
	writecsv(fid,x)
	close(fid)
	filepath ="./seal/bolts/test_screw_data.csv"
	fid = open(filepath,"a")
	writecsv(fid,x)
	close(fid)
end
function des_seal(seal,constants,barrier)
	P = Ph(constants.spec_water,barrier.height)
	P = P/(144) #convert pft to psi
	seal.width = 2*(barrier.span_t)*12 #width of seal
	seal.len = barrier.height
	n = constants.seal_select
	seal_data = CSV.read("./seal/seal_data.csv")
	cols = names(seal_data)
	seal_props = seal_data[cols[n]]
	seal.seating_pressure = seal_props[3]
	m = seal_props[2]
	seal.thickness = seal_props[1]
	if seal.width < 1/4
		b = seal.width
	else
		b = 0.5 * sqrt(seal.width)
	end
	seal.len = 12*barrier.height
	wm1 = Wm1(b,seal.len,m,P)
	wm2 = Wm2(b,12,seal.seating_pressure)
	fst = F_sta(constants.spec_water,barrier.height,barrier.span_length)
	nbolts = 2*(barrier.height)
	if wm1<wm2
		m =	des_bolts(wm2,fst,nbolts,constants.mat_shear,2)
	else
		m = des_bolts(wm1,fst,nbolts,constants.mat_shear,2)
	end
	output_screw_dimensions(m)
	x = [seal.len seal.width seal.thickness]
	filepath ="./seal/_seal_data.csv"
	fid = open(filepath,"w")
	writecsv(fid,x)
	close(fid)
	filepath ="./seal/test_seal_data.csv"
	fid = open(filepath,"a")
	writecsv(fid,x)
	close(fid)
end

