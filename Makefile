# nano-gpu Makefile
# Tools from OSS CAD Suite
IVERILOG = iverilog
VVP = vvp
GTKWAVE = gtkwave
YOSYS = yosys
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

# Synthesized output files
SYN_DIR = syn/
CMD_DEC_SYNTH = command_decoder_synth.v
GEO_UNIT_SYNTH = geometry_unit_synth.v
RAST_SYNTH = rasterizer_synth.v
FRAME_SYNTH = frame_buffer_synth.v
TOP_SYNTH = gpu_top_synth.v

# RTL output files
DOT_DIR = img/dot/
CMD_DEC_RTL_DOT = cmd_dec_rtl_view.dot
GEO_UNIT_RTL_DOT = geo_unit_rtl_view.dot
FRAME_RTL_DOT = frame_rtl_view.dot
RAST_RTL_DOT = rast_rtl_view.dot
TOP_RTL_DOT = gpu_top_rtl_view.dot

# RTL PNG files
PNG_DIR = img/png/
CMD_DEC_RTL_PNG = cmd_dec_rtl_view.png
GEO_UNIT_RTL_PNG = geo_unit_rtl_view.png
FRAME_RTL_PNG = frame_rtl_view.png
RAST_RTL_PNG = rast_rtl_view.png
TOP_RTL_PNG = gpu_top_rtl_view.png

# ----- Simulation Rules ----

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

# ----- Synthesis Rules ----

# Command decoder synthesis
cmd_dec_synth:$(SRC_DIR)command_decoder.sv
	$(YOSYS) -p "read_verilog -sv $(SRC_DIR)command_decoder.sv; synth; write_verilog $(SYN_DIR)$(CMD_DEC_SYNTH)"

# Geometry unit synthesis
geo_unit_synth: $(SRC_DIR)geometry_unit.sv
	$(YOSYS) -p "read_verilog -sv $(SRC_DIR)geometry_unit.sv; synth; write_verilog $(SYN_DIR)$(GEO_UNIT_SYNTH)"

# Frame buffer synthesis
frame_synth: $(SRC_DIR)frame_buffer.sv
	$(YOSYS) -p "read_verilog -sv $(SRC_DIR)frame_buffer.sv; synth; write_verilog $(SYN_DIR)$(FRAME_SYNTH)"

# Rasterizer synthesis (includes frame buffer dependency)
rast_synth: $(SRC_DIR)rasterizer.sv $(SRC_DIR)frame_buffer.sv
	$(YOSYS) -p "read_verilog -sv $(SRC_DIR)rasterizer.sv $(SRC_DIR)frame_buffer.sv; synth; write_verilog $(SYN_DIR)$(RAST_SYNTH)"

# Top-level GPU synthesis
top_synth: $(SRC_DIR)$(TOP) $(MODULES)
	$(YOSYS) -p "read_verilog -sv $(SRC_DIR)$(TOP) $(MODULES); synth; write_verilog $(SYN_DIR)$(TOP_SYNTH)"

# Combined synthesis target
synth_all: cmd_dec_synth geo_unit_synth frame_synth rast_synth top_synth

# ----- RTL View Rules ----

# Command decoder RTL view
cmd_dec_rtl_view: $(SRC_DIR)command_decoder.sv
	$(YOSYS) -p "read_verilog -sv $(SRC_DIR)command_decoder.sv; show -format dot -prefix $(DOT_DIR)cmd_dec_rtl_view"
	dot -Tpng $(DOT_DIR)$(CMD_DEC_RTL_DOT) -o $(PNG_DIR)$(CMD_DEC_RTL_PNG)

# Geometry unit RTL view
geo_unit_rtl_view: $(SRC_DIR)geometry_unit.sv
	$(YOSYS) -p "read_verilog -sv $(SRC_DIR)geometry_unit.sv; show -format dot -prefix $(DOT_DIR)geo_unit_rtl_view"
	dot -Tpng $(DOT_DIR)$(GEO_UNIT_RTL_DOT) -o $(PNG_DIR)$(GEO_UNIT_RTL_PNG)

# Frame buffer RTL view
frame_rtl_view: $(SRC_DIR)frame_buffer.sv
	$(YOSYS) -p "read_verilog -sv $(SRC_DIR)frame_buffer.sv; show -format dot -prefix $(DOT_DIR)frame_rtl_view"
	dot -Tpng $(DOT_DIR)$(FRAME_RTL_DOT) -o $(PNG_DIR)$(FRAME_RTL_PNG)

# Rasterizer RTL view
rast_rtl_view: $(SRC_DIR)rasterizer.sv $(SRC_DIR)frame_buffer.sv
	$(YOSYS) -p "read_verilog -sv $(SRC_DIR)rasterizer.sv $(SRC_DIR)frame_buffer.sv; show -format dot -prefix $(DOT_DIR)rast_rtl_view"
	dot -Tpng $(DOT_DIR)$(RAST_RTL_DOT) -o $(PNG_DIR)$(RAST_RTL_PNG)

# Top-level GPU RTL view
top_rtl_view: $(SRC_DIR)$(TOP) $(MODULES)
	$(YOSYS) -p "read_verilog -sv $(SRC_DIR)$(TOP) $(MODULES); show -format dot -prefix $(DOT_DIR)gpu_top_rtl_view"
	dot -Tpng $(DOT_DIR)$(TOP_RTL_DOT) -o $(PNG_DIR)$(TOP_RTL_PNG)

# ----- Miscellaneous Rules ----

# Clean up
clean:
	rm -f $(CMD_DEC_SIM) $(GEO_UNIT_SIM) $(FRAME_SIM) $(RAST_SIM) $(TOP_SIM) *.vcd \
	$(CMD_DEC_SYNTH) $(GEO_UNIT_SYNTH) $(FRAME_SYNTH) $(RAST_SYNTH) $(TOP_SYNTH) \
	*.dot *.png

# Phony targets
.PHONY: all cmd_dec_view geo_unit_view frame_view rast_view top_view \
		cmd_dec_compile cmd_dec_sim cmd_dec_wave cmd_dec_synth \
		geo_unit_compile geo_unit_sim geo_unit_wave geo_unit_synth \
		frame_compile frame_sim frame_wave frame_synth \
		rast_compile rast_sim rast_wave rast_synth \
		top_compile top_sim top_wave top_synth synth_all clean