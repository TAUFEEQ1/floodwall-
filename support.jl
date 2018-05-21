type Support
	height
	width
	coef
end
support = Support(0,0,3)
function sec_modulus(Ismall,support,fx_height)
	support.height = (support.coef)*(fx_height)
	y = 0.5*(support.height)
	Ibig = ibig(support.width,support.height)
	Ibal = Ibig - Ismall
	Z = Ibal/y
	return Z
end
function ch_base(support)
	support.coef = support.coef+1
end
function design_support(support,constants,barrier)
	Fsta = F_sta(constants.spec_water,barrier.height,barrier.span_length)
	w = (2*Fsta)/(barrier.height)
	l = barrier.height
	Mst = (w*(l^2))/6
	stress_yield = constants.bstress*(12*12) #Alumina 
	Z= (Mst/stress_yield)
	h = barrier.span_t
	#assume b = coef * h
	coef = 2
	h1 = 3/304.5
	Ismall = ismall(coef,h+h1)
	support.width = 3*(coef*h)
	Z1 = sec_modulus(Ismall,support,barrier.span_t)
	println(Z)
	println(Z1)
	while Z1 < Z
		ch_base(support)
		Z1 = sec_modulus(Ismall,support,barrier.span_t)
	end
	output_dimensioning(support,barrier)
	return support
end
function output_dimensioning(support,barrier)
	height = barrier.height
	sptick = support.height
	spwid = support.width
	println("support height: $height , support thickness: $sptick , support length: $spwid")
	x=[height sptick spwid barrier.span_t]
	filepath ="./wall_span/supports.csv"
	fid1 = open(filepath,"w")
	writecsv(fid1,x)
	close(fid1)
	filepath= "./wall_span/support_data.csv"
	fid2 = open(filepath,"a")
	writecsv(fid2,x)
	close(fid2)
end