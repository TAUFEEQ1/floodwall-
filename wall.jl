type wallsp
	thickness
	height
	width
end
wall = wallsp(0,0,0)
type wcontsts
	#allowable stress
	bstress
	young
	bet
	alpha
end
wconst =wcontsts(0,0,0,0)
function bending_stress(wconst,wall,spec_water)
	#design against bending stresses
	#alpha alumina corundum,aluminium oxide
	wall_data=CSV.read("./wall_span/wall.csv")
	r=(wall.height)/(wall.width)
	coln = names(wall_data)
	col =[]
	for q = 1:9
		temp=wall_data[coln[q]]
		push!(col,temp) 
	end
	for i = 2:9
		if r < col[i][1]
			y2=col[i][1]
			x2=col[i][3]
			y1=col[i-1][1]
			x1=col[i-1][3]
			y0 = r
			wconst.bet =(((x2-x1)/(y2-y1))*(y0-y1))+x1
			break;
		end
	end
	p=Ph(spec_water,wall.height)
	t = thickness(p,wall.width,wconst.bet,wconst.bstress)
	return t
end
function deflection(wconst,wall,spec_water)
	wall_data = CSV.read("./wall_span/wall.csv")
	r = (wall.height)/(wall.width)
	coln = names(wall_data)
	col = []
	for q =1:9
		temp = wall_data[coln[q]]
		push!(col,temp)
	end
	for i = 2:9
		if r <col[i][1]
			y2 = col[i][1]
			x2 = col[i][2]
			y1 = col[i-1][1]
			x1 = col[i-1][2]
			y0 = r
			wconst.alpha = (((x2-x1)/(y2-y1))*(y0-y1))+x1
			break;
		end
	end
	P = Ph(spec_water,wall.height)
	t = thicknes(wconst.alpha,P,wall.width,wconst.young)
	return t
end
function design_wall(constants,barrier,wconst,wall)
	wall.height = 12*(barrier.height)
	wall.width = 12*(barrier.span_length)
	wconst.bstress = constants.bstress
	wconst.young = constants.young
	wconst.young = 1000*(wconst.young)
	bending_thickness = bending_stress(wconst,wall,constants.spec_water/(12*12*12))
	bending_tick = deflection(wconst,wall,constants.spec_water/(12*12*12))
	if bending_thickness < bending_tick
		return bending_tick
	else
		return bending_thickness
	end
end