SCRIPT = $(wildcard *.tcl)

all: clean
	vivado -mode batch -source ${SCRIPT}

clean:
	rm -rf ip_*  vivado*.* *.xml xgui/ .Xil* *.*~ *.zip webtalk*
