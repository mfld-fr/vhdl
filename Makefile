
GHDL=/usr/src/ghdl/ghdl_mcode

ANALYZE=$(GHDL) -a
ELABORATE=$(GHDL) -e
RUN=$(GHDL) -r

ARGS=--stop-time=100ms --vcd=test.vcd

.PHONY: all analyse run

all: analyse run

analyse:
	$(ANALYZE) latch-sr-nand.vhd
	$(ANALYZE) test-latch-sr-nand.vhd
	$(ANALYZE) latch-sr-nor.vhd
	$(ANALYZE) test-latch-sr-nor.vhd
	$(ANALYZE) latch-sre-nand.vhd
	$(ANALYZE) test-latch-sre-nand.vhd
	$(ANALYZE) latch-sre-nor.vhd
	$(ANALYZE) test-latch-sre-nor.vhd
	$(ANALYZE) latch-sre.vhd
	$(ANALYZE) test-latch-sre.vhd
	$(ANALYZE) flip-flop-sr-nand.vhd
	$(ANALYZE) test-flip-flop-sr-nand.vhd
	$(ANALYZE) flip-flop-sr-nor.vhd
	$(ANALYZE) test-flip-flop-sr-nor.vhd
	$(ANALYZE) flip-flop-sr.vhd
	$(ANALYZE) test-flip-flop-sr.vhd
	$(ANALYZE) flip-flop-d.vhd
	$(ANALYZE) test-flip-flop-d.vhd

run:
	$(RUN) test_latch_sr_nand $(ARGS)
	$(RUN) test_latch_sr_nor $(ARGS)
	$(RUN) test_latch_sre_nand $(ARGS)
	$(RUN) test_latch_sre_nor $(ARGS)
	$(RUN) test_latch_sre $(ARGS)
	$(RUN) test_flip_flop_sr_nand $(ARGS)
	$(RUN) test_flip_flop_sr_nor $(ARGS)
	$(RUN) test_flip_flop_sr $(ARGS)
	$(RUN) test_flip_flop_d $(ARGS)
