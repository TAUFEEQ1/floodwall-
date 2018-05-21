for /f "usebackq tokens=1-4 delims=," %%a in ("C:\Users\user\Desktop\test.csv") do (
	echo %%a %%b %%c %%d
	)