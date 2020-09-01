@echo off
set xv_path=D:\\opt\\Xilinx\\Vivado\\2017.2\\bin
call %xv_path%/xelab  -wto bebbce0ef0a842b39ba6577d2406e42d -m64 --debug typical --relax --mt 2 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip --snapshot ethercat_slave_v1_0_behav xil_defaultlib.ethercat_slave_v1_0 xil_defaultlib.glbl -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
