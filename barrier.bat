@echo off
echo ---------Welcome-----
rem %julia% "F:\usb\barrier1.jl" --bheight="5" --splen="4" --spec_soil="120" ^
rem --cb="0" --kp="3.7" --cf="0.55" --sb=2000 --cube_stren=30 --concrete_cracked="true" ^
rem --bstress="35286" --young="49300" --flange_coeff="13"
rem %freecadcmd% "F:\usb\barrier.py"
rem echo ---Finish---
for /l %%i in (3,1,4) do (
echo ----Starting test-----
%julia% "F:\usb\barrier1.jl" --bheight=%%i --splen="4" --spec_soil="120" ^
--cb="0" --kp="3.7" --cf="0.55" --sb=2000 --cube_stren=30 --concrete_cracked="true" ^
--bstress="35286" --young="49300" --flange_coeff="7"
%freecadcmd% -l "F:\usb\barrier.py"
echo ---Finish test---
)
echo ----Simulation done---
