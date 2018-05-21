using ArgParse
function main(args)
	#set main props
	s = ArgParseSettings(description ="Test run for arg parse")
	@add_arg_table s begin
	    "--opt1"
	    "--opt2"
	    "--arg1"
	end
	parsed_args= parse_args(s)
	for(key,val) in parsed_args
		println(" $key => $(repr(val))")
	end
end
main(ARGS)