# Makefile for GPU Design Simulation
# Tools from OSS CAD Suite
IVERILOG = iverilog
VVP = vvp
GTKWAVE = gtkwave
FLAGS = -g2012  # SystemVerilog 2012 support

# Source files
SRC_DIR = src/
MODULES = $(SRC_DIR)command_decoder.sv $(SRC_DIR)geometry_unit.sv $(SRC_DIR)rasterizer.sv $(SRC_DIR)frame_buffer.sv
TOP = gpu_top.sv

# Testbench files
TB_DIR = tb/
CMD_DEC_TB = command_decoder_tb.sv
GEO_UNIT_TB = geometry_unit_tb.sv
RAST_TB = rasterizer_tb.sv
FRAME_TB = frame_buffer_tb.sv
TOP_TB = gpu_top_tb.sv

# Output simulation executables
CMD_DEC_SIM = cmd_dec_sim
GEO_UNIT_SIM = geo_unit_sim
RAST_SIM = rast_sim
FRAME_SIM = frame_sim
TOP_SIM = gpu_sim

# VCD output files
CMD_DEC_VCD = command_decoder_tb.vcd
GEO_UNIT_VCD = geometry_unit_tb.vcd
RAST_VCD = rasterizer_tb.vcd
FRAME_VCD = frame_buffer_tb.vcd
TOP_VCD = gpu_top_tb.vcd

# WAVE files
WAVE_DIR = tb/waves/
CMD_DEC_WAVE = cmd_dec_wave.gtkw
GEO_UNIT_WAVE = geo_unit_wave.gtkw
RAST_WAVE = rast_wave.gtkw
FRAME_WAVE = frame_wave.gtkw
TOP_WAVE = top_wave.gtkw

# Default target
all: top

# Command decoder
cmd_dec_compile: $(TB_DIR)$(CMD_DEC_TB) $(SRC_DIR)command_decoder.sv
	$(IVERILOG) $(FLAGS) -o $(CMD_DEC_SIM) $(TB_DIR)$(CMD_DEC_TB) $(SRC_DIR)command_decoder.sv

cmd_dec_sim: cmd_dec_compile
	$(VVP) $(CMD_DEC_SIM)

cmd_dec_wave: cmd_dec_sim
	$(GTKWAVE) $(CMD_DEC_VCD) &

cmd_dec: cmd_dec_compile cmd_dec_sim cmd_dec_wave

# Geometry Unit
geo_unit_compile: $(TB_DIR)$(GEO_UNIT_TB) $(SRC_DIR)geometry_unit.sv
	$(IVERILOG) $(FLAGS) -o $(GEO_UNIT_SIM) $(TB_DIR)$(GEO_UNIT_TB) $(SRC_DIR)geometry_unit.sv

geo_unit_sim: geo_unit_compile
	$(VVP) $(GEO_UNIT_SIM)

geo_unit_wave: geo_unit_sim
	$(GTKWAVE) $(GEO_UNIT_VCD) &

geo_unit: geo_unit_compile geo_unit_sim geo_unit_wave

# Frame buffer
frame_compile: $(TB_DIR)$(FRAME_TB) $(SRC_DIR)frame_buffer.sv
	$(IVERILOG) $(FLAGS) -o $(FRAME_SIM) $(TB_DIR)$(FRAME_TB) $(SRC_DIR)frame_buffer.sv

frame_sim: frame_compile
	$(VVP) $(FRAME_SIM)

frame_wave: frame_sim
	$(GTKWAVE) $(FRAME_VCD) &

frame: frame_compile frame_sim frame_wave

# Rasterizer (includes Frame Buffer)
rast_compile: $(TB_DIR)$(RAST_TB) $(SRC_DIR)rasterizer.sv $(SRC_DIR)frame_buffer.sv
	$(IVERILOG) $(FLAGS) -o $(RAST_SIM) $(TB_DIR)$(RAST_TB) $(SRC_DIR)rasterizer.sv $(SRC_DIR)frame_buffer.sv

rast_sim: rast_compile
	$(VVP) $(RAST_SIM)

rast_wave: rast_sim
	$(GTKWAVE) --save $(WAVE_DIR)$(RAST_WAVE) $(RAST_VCD) &

rast: rast_compile rast_sim rast_wave

# Top-Level GPU
top_compile: $(TB_DIR)$(TOP_TB) $(SRC_DIR)$(TOP) $(MODULES)
	$(IVERILOG) $(FLAGS) -o $(TOP_SIM) $(TB_DIR)$(TOP_TB) $(SRC_DIR)$(TOP) $(MODULES)

top_sim: top_compile
	$(VVP) $(TOP_SIM)

top_wave: top_sim
	$(GTKWAVE) $(TOP_VCD) &

top: top_compile top_sim top_wave

# Clean up
clean:
	rm -f $(CMD_DEC_SIM) $(GEO_UNIT_SIM) $(FRAME_SIM) $(RAST_SIM) $(TOP_SIM) *.vcd

# Phony targets
.PHONY:	all cmd_dec_compile cmd_dec_sim cmd_dec_wave geo_unit_compile geo_unit_sim geo_unit_wave \
		frame_compile frame_sim frame_wave rast_compile rast_sim rast_wave top_compile top_sim top_wave clean