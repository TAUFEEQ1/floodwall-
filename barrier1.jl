using ArgParse,CSV
include("formulas.jl") #formulas to be used
include("design.jl") #functions that design against sliding, overturning and settlement
include("bolts.jl") #functions that design bolts
include("wall.jl") #functions that design wall
include("support.jl") #functions that design wall supports
include("seal.jl") #functions that design seal.
function main(support,constants,barrier,args)
	#set main props
	s = ArgParseSettings(description ="Arguments passed by cli")
	@add_arg_table s begin
	    "--bheight"
	    	default = "5"
	    	help = "This flag sets the barrier height in ft"
	    "--splen"
	    	default = "4"
	    	help ="This option sets the span length in ft"
	    "--spec_soil"
	    	default = "120"
	    	help = "This option sets the specific soil weight in Ib/ft"
	    "--spec_mat"
	    	default = "175"
	    	help ="sets the wall specific weight in Ib/ft"
	    "--spec_base"
	    	default = "150"
	    	help = "This option sets the specific concrete base weight in Ib/ft"
	    "--cube_stren"
	    	default = "30"
	    	help ="Expected concrete cube strength in N/mm2"
	    "--cb"
	    	default = "0"
	    	help = "This option sets the cohesion coefficient"
	    "--kp"
	    	default = "3.7"
	    	help = "This option sets the passive soil pressure"
	    "--cf"
	    	default = "0.55"
	    	help = "This option sets the friction coefficient"
	    "--sb"
	    	default = "2000"
	    	help ="This sets the allowable bearing stress"
	    "--bstress"
	    	default="50800"
	    	help ="This sets the allowable bending stress of wall span material in Ib/in2"
	    "--young"
	    	default="49300"
	    	help="modulus of elasticity for the plate material in kIb/in2"
	    "--flange_coeff"
	    	default = "19"
	    	help ="Flange coefficient is the multiple of wall thickness used to obtain flange length."
	    "--seal_selection"
	    	default ="2"
	    	help="2 - glass microspheres\n 3 - silica\n 4 - Barium sulphate\n 5- PTFE588\n 6 - PTFE600"
	    "--concrete_cracked"
	    	default = true
	    	help ="Nature of concrete that is cracked / uncracked"
	    "--mat_shear"
	    	default = "330"
	    	help="shear strength of material in bolts, state in MPa"
	end
	data = parse_args(s)
	barrier.height = parse(Int8,data["bheight"])
	barrier.span_length = parse(Int8,data["splen"])
	constants.spec_soil=parse(Int16,data["spec_soil"])
	constants.spec_base=parse(Int16,data["spec_base"])
	constants.Cb = parse(Int16,data["cb"])
	constants.Kp = parse(Float16,data["kp"])
	constants.Cf = parse(Float16,data["cf"])
	constants.Sb = parse(Int32,data["sb"])
	constants.cube_stren= parse(Int16,data["cube_stren"])
	constants.con_stats = data["concrete_cracked"]
	constants.young = parse(Int32,data["young"])
	constants.bstress = parse(Int32,data["bstress"])
	constants.young = parse(Int32,data["young"])
	constants.spec_mat = parse(Int32,data["spec_mat"])
	constants.flange_coeff = parse(Int16,data["flange_coeff"])
	constants.seal_select = parse(Int8,data["seal_selection"])
	constants.mat_shear = parse(Int16,data["mat_shear"])
	coeff = 0.5
	barrier.base_width = coeff * barrier.height
	barrier.span_t = 2*(1/12) * design_wall(constants,barrier,wconst,wall)
	println(304.5*barrier.span_t)
	support_data = design_support(support,constants,barrier)
	barrier.wall_t = support_data.height
	b = 304.5 * barrier.wall_t
	println("barrier_thickness : $b mm")
	j=design(constants,barrier)
	while j < 1.5
		coeff = coeff + 0.05
		barrier.base_width =coeff * barrier.height
		j = design(constants,barrier)
	end
	println("sliding check finished")
	infor=overturning(constants,barrier)
	i = infor[1]
	while i < 1.5
		coeff = coeff+0.02
		barrier.base_width = coeff * barrier.height
		dat = overturning(constants,barrier)
		i = dat[1]
	end
	println("overturning check finished")
	k = Ecentricity(constants,barrier)
	while k > (barrier.base_width)/6
		coeff = coeff+0.1
		barrier.base_width = coeff * barrier.height
		k = Ecentricity(constants,barrier)
	end
	o=soil_pressure(constants,barrier,k)
	p = o[1]
	 while p > constants.Sb
	 	coeff =coeff+0.05
	 	barrier.base_width= coeff * barrier.height
	 	o = soil_pressure(constants,barrier,k)
	 	p = o[1]
	 end
	 println("settlement check finished")
	reinforcement(constants,barrier,k)
	output_dimensions(barrier)
	println("Designing steel-concrete anchor bolt")
	design_bolts(constants,barrier,bolt,bconsts)
	des_seal(seal,constants,barrier)
end
main(support,constants,barrier,ARGS)
