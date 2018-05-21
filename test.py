import csv
design_data = csv.reader("./barrier/barrier.csv")
for row in design_data:
	type(row)