import os,csv
import Part,Arch,Draft
from FreeCAD import Base

def design_base(wall_t,wall_width,base_width,base_thickness,base_length,span_length,key_depth,folder_path):
	x=span_length/2 + base_length
	s =base_width-wall_width
	y=s/3
	y=y+(wall_width/2)
	point=[]
	point.append(Base.Vector(-x,y,0))
	point.append(Base.Vector(-x+base_length,y,0))
	point.append(Base.Vector(-x+base_length,wall_width/2,0))
	point.append(Base.Vector(-x+base_length+span_length,wall_width/2,0))
	point.append(Base.Vector(-x+base_length+span_length,y,0))
	point.append(Base.Vector(x,y,0))
	point.append(Base.Vector(x,y-base_width,0))
	point.append(Base.Vector(x-base_length,y-base_width,0))
	point.append(Base.Vector(x-base_length,-wall_width/2,0))
	point.append(Base.Vector(x-base_length-span_length,-wall_width/2,0))
	point.append(Base.Vector(x-base_length-span_length,y-base_width,0))
	point.append(Base.Vector(x-base_length-span_length-base_length,y-base_width,0))
	edg = list()
	for i in range(0,11):
		edg.append(Part.makeLine(point[i],point[i+1]))
	edg.append(Part.makeLine(point[11],point[0]))
	w=Part.Wire(edg)
	f=Part.Face(w)
	P=f.extrude(FreeCAD.Vector(0,0,base_thickness))
	nsolid=P
	cylinders = bolt_holes(wall_t,span_length,base_length,base_width,base_thickness)
	for i in cylinders:
		nsolid = nsolid.cut(i)
	filepath = folder_path + "/barrier_base.stp"
	nsolid.exportStep(filepath)
	keys = design_key(span_length,base_length,base_width,key_depth,wall_width,wall_t)
	compound = Part.makeCompound([keys[0],nsolid])
	compound  = Part.makeCompound([compound,keys[1]])
	compound.exportStep(folder_path+"/barrier_foundation.stp")

def design_key(span_length,base_length,base_width,key_depth,wall_width,wall_t):
	x = span_length/2
	y2 = (base_width - wall_t)
	y2 = y2/3.8
	y = (wall_width/2) + y2
	points = []
	points.append(Base.Vector(x,y,0))
	points.append(Base.Vector(x+(base_length),y,0))
	points.append(Base.Vector(x+(base_length),y-wall_width,0))
	points.append(Base.Vector(x,y-wall_width,0))
	edges = []
	for i in range(0,3):
		edges.append(Part.makeLine(points[i],points[i+1]))
	edges.append(Part.makeLine(points[3],points[0]))
	w = Part.Wire(edges)
	f = Part.Face(w)
	key = f.extrude(FreeCAD.Vector(0,0,-key_depth))
	keys = []
	keys.append(key)
	key = key.mirror(Base.Vector(0,0,0),Base.Vector(1,0,0))
	keys.append(key)
	return keys

def bolt_holes(wall_t,span_length,base_length,base_width,base_thickness):
	bolt_d = file("./bolts/hole_params.csv","r")
	bolt_data = csv.reader(bolt_d)
	cylinders = []
	for row in bolt_data:
		bolt_diam = float(row[0])
		bolt_depth = float(row[2])
		bolt_spacing = float(row[4])
	x = (span_length/2)+(base_length/2)-(bolt_spacing/2)
	y = (0.5*wall_t)+(4*wall_t)
	pos  = Base.Vector(x,y,base_thickness)
	des_cyl(bolt_diam,bolt_depth,pos,cylinders)
	x = (span_length/2)+(base_length/2)+(bolt_spacing/2)
	pos = Base.Vector(x,y,base_thickness)
	des_cyl(bolt_diam,bolt_depth,pos,cylinders)
	pos = Base.Vector(x,-y,base_thickness)
	des_cyl(bolt_diam,bolt_depth,pos,cylinders)
	x = x - (bolt_spacing)
	pos = Base.Vector(x,-y,base_thickness)
	des_cyl(bolt_diam,bolt_depth,pos,cylinders)
	return cylinders

def design_shield(span_length,span_t,swidth,bheight,folder_path,bthick):
	points = []
	x = 0
	y = 0.5*span_t
	z = bthick
	points.append(Base.Vector(0,y,z))
	x = (0.5*span_length) -(swidth+5)
	points.append(Base.Vector(x,y,z))
	y = y+(3*span_t)
	points.append(Base.Vector(x,y,z))
	x = x+5
	points.append(Base.Vector(x,y,z))
	y = y-(3*span_t)
	points.append(Base.Vector(x,y,z))
	x = x+swidth
	points.append(Base.Vector(x,y,z))
	points.append(Base.Vector(x,-y,z))
	x = x - swidth
	points.append(Base.Vector(x,-y,z))
	y = -(y+(3*span_t))
	points.append(Base.Vector(x,y,z))
	x = x - 5
	points.append(Base.Vector(x,y,z))
	y = y+(2*span_t)
	points.append(Base.Vector(x,y,z))
	x = 0
	points.append(Base.Vector(x,y,z))
	edges = []
	for i in range(0,11):
		edges.append(Part.makeLine(points[i],points[i+1]))
	edges.append(Part.makeLine(points[11],points[0]))
	w = Part.Wire(edges)
	f = Part.Face(w)
	height = 304.5*bheight
	P = f.extrude(Base.Vector(0,0,height))
	P1 = P.mirror(Base.Vector(0,0,0),Base.Vector(1,0,0))
	cpd = Part.makeCompound([P,P1])
	cpd.exportStep(folder_path+"/wall_span.stp")
	screw_dat = file("./seal/bolts/screw_data.csv")
	screw_data = csv.reader(screw_dat)
	for row in screw_data:
		diameter = float(row[0])
		pitch = float(row[1])
		minor_diam = float(row[2])
	#to be finished.

def design_plate(span_length,base_length,base_width,wall_t,base_thickness,folder_path):
	bolt_d = file("./bolts/hole_params.csv","r")
	bolt_data = csv.reader(bolt_d)
	for row in bolt_data:
		bolt_diam = float(row[0])
		bolt_spacing = float(row[4])
		bolt_fixture = float(row[5])
	x = (span_length/2)+(base_length/2)
	y = (0.5*wall_t)+(4.8*wall_t)
	x2 = 0.6*bolt_spacing
	z = base_thickness
	points = []
	points.append(Base.Vector(x-x2,y,z))
	points.append(Base.Vector(x+x2,y,z))
	points.append(Base.Vector(x+x2,-y,z))
	points.append(Base.Vector(x-x2,-y,z))
	edges = []
	for i in range(0,3):
		edges.append(Part.makeLine(points[i],points[i+1]))
	edges.append(Part.makeLine(points[3],points[0]))
	w = Part.Wire(edges)
	f = Part.Face(w)
	P = f.extrude(Base.Vector(0,0,bolt_fixture))
	plate = Part.makeSolid(P)
	cylinders = bolt_holes(wall_t,span_length,base_length,base_width,base_thickness+bolt_fixture)
	for i in cylinders:
		plate = plate.cut(i)
	plate1 = plate.mirror(Base.Vector(0,0,0),Base.Vector(1,0,0))
	cpd = Part.makeCompound([plate1,plate])
	cpd.exportStep(folder_path+"/flange.stp")
	return bolt_fixture

def des_cyl(bolt_diam,bolt_depth,pos,cylinders):
	cylinda = Part.makeCylinder(bolt_diam/2,bolt_depth,pos,Base.Vector(0,0,1),360)
	cylinda = Part.makeSolid(cylinda)
	cylinders.append(cylinda)
	cylinda = cylinda.mirror(Base.Vector(0,0,0),Base.Vector(1,0,0))
	cylinders.append(cylinda)

def design_frame(span_length,base_length,folder_path,bthick):
	pos = Base.Vector(0,0,0)
	support_data = file("./wall_span/supports.csv")
	support_data = csv.reader(support_data)
	for row in support_data:
		sheight = 304.5*int(row[0])
		sthick = 304.5*float(row[1])
		swidth = 304.5*float(row[2])
		hthick = 304.5*float(row[3])
	hwidth = 2*hthick
	points = []
	x = (0.5*span_length)+(0.5*base_length) - (0.5*swidth)
	y = (0.5*sthick)
	z = bthick
	points.append(Base.Vector(x,y,z))
	points.append(Base.Vector(x+swidth,y,z))
	points.append(Base.Vector(x+swidth,-y,z))
	points.append(Base.Vector(x,-y,z))
	locs = []
	y = (0.5*hthick)
	locs.append(Base.Vector(x,y,z))
	locs.append(Base.Vector(x+hwidth,y,z))
	locs.append(Base.Vector(x+hwidth,-y,z))
	locs.append(Base.Vector(x,-y,z))
	edges = []
	for i in range(0,3):
		edges.append(Part.makeLine(points[i],points[i+1]))
	edges.append(Part.makeLine(points[3],points[0]))
	w = Part.Wire(edges)
	f = Part.Face(w)
	P = f.extrude(Base.Vector(0,0,sheight))
	edges = []
	for i in range(0,3):
		edges.append(Part.makeLine(locs[i],locs[i+1]))
	edges.append(Part.makeLine(locs[3],locs[0]))
	c = Part.Wire(edges)
	cf = Part.Face(c)
	cd = cf.extrude(Base.Vector(0,0,sheight))
	x = (0.5*span_length)+(0.5*base_length)
	cd1 = cd.mirror(Base.Vector(x,0,0),Base.Vector(1,0,0))
	P = P.cut(cd)
	P = P.cut(cd1)
	P1 = P.mirror(Base.Vector(0,0,0),Base.Vector(1,0,0))
	cpd = Part.makeCompound([P1,P])
	cpd.exportStep(folder_path+"/frames.stp")
	return swidth
	# to be finished

def main():
	barrier_data = file("F:/usb/barrier/barrier.csv","r")
	des_data = csv.reader(barrier_data)
	for row in des_data:
		wall_height = int(row[0])
		wall_t = float(row[1])
		wall_t = 304.5*wall_t
		wall_width= 304.5*1
		base_width = float(row[2])
		base_width = 304.5*base_width
		base_thickness = float(row[3])
		base_thickness = 304.5*base_thickness
		base_length = float(row[4])
		base_length = 304.5*base_length
		span_length = float(row[5])
		span_length = (304.5*span_length) - base_length
		key_depth = float(row[6])
		key_depth = 304.5*key_depth
		span_thickness = 304.5*(float(row[7]))
	folder_path = "F:/usb/simulations/"+ str(wall_height)
	if not os.path.exists(folder_path):
		os.mkdir(folder_path)
	design_base(wall_t,wall_width,base_width,base_thickness,base_length,span_length,key_depth,folder_path)
	plate_thickness=design_plate(span_length,base_length,base_width,wall_t,base_thickness,folder_path)
	swidth = design_frame(span_length,base_length,folder_path,base_thickness+plate_thickness)
	design_shield(span_length+base_length,span_thickness,swidth,wall_height,folder_path,base_thickness)
main()