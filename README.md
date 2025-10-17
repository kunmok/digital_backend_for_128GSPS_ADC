# Digital Backend for a 128 GS/s ADC

This repository hosts the register-transfer level (RTL) implementation and
simulation collateral for the digital backend of a 128 GS/s ADC-based SERDES
receiver. The design targets a 16-lane, 6-bit front-end with scan-accessible
control, on-chip memory, and a maximum-likelihood sequence estimation (MLSE)
backend with optional bit-error-rate tester (BERT) support.

The codebase is intended to be shared publicly so that other teams can study,
reuse, and verify the architecture. Sensitive IP (certain scan cells and BERT
macros) is not bundled; see the notes in `pdmlse_top/rtl/library/README.md` for
how to request those blocks.

## Highlights

- 16 deserializer lanes feeding a configurable LUT-based front-end.
- Scan-controlled DSP memory subsystem with frame-synchronization support.
- MLSE-based backend including pattern filter, ALU, decoder, and BERT hooks.
- Parameter packages (`pdmlse_top/rtl/params/*.svh`) centralize widths and
  pipeline depths for synthesis and simulation.
- Verification collateral includes modular bus-functional models (BFMs),
  monitors, and reusable tests, plus targeted “basic” benches for quick bring-up.
- Scan-chain definition files and generator scripts to regenerate the scan RTL
  from configuration files.

## Repository Layout

- `pdmlse_top/rtl/chip_top/` – top-level integration (`ChipTop.v`, `dsp_top.sv`,
  scan wrappers, and an analog co-simulation shell).
- `pdmlse_top/rtl/dsp_frontend/` – deserializer lanes, LUT glue logic, clock
  spine, and re-ordering stages (with matching scan variants).
- `pdmlse_top/rtl/dsp_memory/` – high-speed sample buffering, frame sync logic,
  and scan instrumentation for the memory banks.
- `pdmlse_top/rtl/dsp_backend/` – MLSE equalizer, decoder pipeline, and BERT
  integration (scan-enabled).
- `pdmlse_top/rtl/dsp_bridge/` – utility synchronizers and bridge structures
  between sub-blocks.
- `pdmlse_top/rtl/library/common/` – reusable IP (clock dividers, reset
  synchronizer, 1:2 and 2:4 deserializers).
- `pdmlse_top/rtl/library/scan_cell/`, `pdmlse_top/rtl/library/bert/` – place
  holders for proprietary IP. Reach out to the authors if you need access.
- `pdmlse_top/rtl/scan_gen/` – scan-chain configuration files (`*.cfg`) and
  helper scripts to regenerate the scan RTL and definition headers.
- `pdmlse_top/rtl/params/` – shared `\`define` packages for widths, depths,
  and default LUT contents used across the design and testbench.
- `pdmlse_top/tb/verif/` – feature-rich SystemVerilog testbench with BFMs,
  monitors, test registry, and parameter packages.
- `pdmlse_top/tb/basic/` – focused benches for individual blocks (e.g., BERT,
  scan test, memory write/read) with simple stimulus and plusargs.
- `pdmlse_top/tb/utils/` – clock generator and PRBS/pattern generators used by
  both verification environments.

## RTL Block Overview

### Chip Integration (`pdmlse_top/rtl/chip_top`)

- `ChipTop.v` exposes analog and digital scan control, memory scan ports, and
  optional simulation-only stimulus hooks (`SIMULATION` define).
- `dsp_top.sv` stitches the front-end, memory, and backend while routing the
  two-phase scan chains through each block in sequence.
- `ScanTop.v` and `Scan_reset_cell.v` provide top-level scan orchestration for
  full-chip verification and gate-level sign-off.

### DSP Front-End (`pdmlse_top/rtl/dsp_frontend`)

Implements the 16-lane deserializer interface, LUT-based calibration, and
reordering stages before handing data to the memory subsystem. Key files:

- `dsp_fe_core.sv`, `dsp_fe_lane.sv`, `dsp_fe_lane_des.sv`, and
  `dsp_fe_reorder.sv` implement the datapath.
- `dsp_fe_clkspine.sv` distributes the high-speed clock with scan-configurable
  enables.
- `scan/` contains generated scan-chain RTL (`*_scan.v`) and definition headers
  (`*_scan_defs.v`) for lane, deserializer, clock spine, and rod control logic.

### DSP Memory (`pdmlse_top/rtl/dsp_memory`)

Provides sample capture, banked memory, and frame-alignment logic. The scan
variants mirror the front-end structure to allow non-intrusive configuration
and observation.

### DSP Backend (`pdmlse_top/rtl/dsp_backend`)

Implements a scan-controlled MLSE equalizer plus optional BERT readout:

- `dsp_be_*.sv` files cover the pattern filter, ALU, decoder, and top-level
  block.
- Parameters such as pipeline depths, pattern lengths, and BERT widths are
  defined in `params/dsp_be.svh`.
- Scan-chain RTL lives under `dsp_backend/scan/` and can be regenerated from
  the configuration file in `rtl/scan_gen/scan_defines/dsp_be_scan.cfg`.

### Common IP Library (`pdmlse_top/rtl/library`)

Reusable primitives for clocking, reset, deserialization, and future BERT or
scan-cell integration. The bundled README documents how to request the
proprietary cells when needed.

### Scan Generation (`pdmlse_top/rtl/scan_gen`)

Each sub-block’s scan-chain definition resides in `scan_defines/*.cfg`. The
`generate_scan_chain.sh` scripts expect `gen-scan-chain.pl` to be present on
your `PATH` and will emit the corresponding `*_scan.v` and `*_scan_defs.v`
files. Re-run these scripts whenever the scan definition changes.

## Verification Environment

### Structured Testbench (`pdmlse_top/tb/verif`)

- Top-level benches `tb_dsp_fe.sv` and `tb_dsp_mem.sv` instantiate BFMs for
  scan control, analog-front-end stimulus, and memory read/write interfaces.
- Tests are registered via the `*_test_registry` classes. Select a scenario by
  editing the `selected_test` string in the bench (e.g., `fe_smoke_test`,
  `fe_reset_test`, `fe_des_test`, `fe_lut_seedmode_test`,
  `fe_lut_loadmode_test`, `mem_smoke_test`). Extend the registry to add new
  sequences.
- BFMs live in `verif/bfm/` (e.g., `fe_scan_bfm_pkg.sv`,
  `mem_rw_bfm_pkg.sv`); monitors are in `verif/monitor/` and expose lane-level
  or memory observability.
- `tb_cfg_pkg.sv` centralizes scan timing (`\`SCAN_CYCLE`), clock-to-data
  delays, and message macros. Adjust these values to explore different scan
  frequencies.
- `tb_params.sv` and the RTL parameter packages share LUT defaults and frame
  synchronization patterns to keep stimulus consistent.

Waveform dumps (`$fsdbDumpfile`) are optional; remove or adjust the relevant
lines if your simulator does not support FSDB.

### Basic Benches (`pdmlse_top/tb/basic`)

Small, self-contained modules for directed stimulus:

- `tb_be_testvec.sv` and `tb_be_eq_testvec.sv` drive captured vectors through
  the MLSE backend. Use plusargs like `+TARGET_BER=<value>` and
  `+TESTVECTOR_DIR=<path>` to point at datasets.
- `tb_be_bert.sv`, `tb_be_patt`, and `tb_top_scantest.sv` focus on specific
  scan or BERT flows.
- Memory benches (`tb_mem_wr.sv`, `tb_mem_bank.sv`) exercise write/read paths.

These are useful for quick sanity checks or when you need to debug a block in
isolation from the full BFMs.

### Utility Modules (`pdmlse_top/tb/utils`)

Contains scan clock generators, PRBS sources, and pattern generator wrappers
used in both verification environments. Include these files when compiling the
testbenches.

### Caution

Automated verification of memory (`dsp_mem`) in SystemVerilog is under 
construction. Memory block has been verified in raw Verilog style testbench,
and post-silicon bringup. We welcome contributions to extending SystemVerilog
testbenches to fuzz-test various operational modes for `dsp_mem`!


## Configuration & Parameters

- Common widths (`LANE_WIDTH`, `ADC_WIDTH`, `DES_OUT_WIDTH`, etc.) live in
  `rtl/params/dsp_common.svh`.
- Front-end configuration (LUT defaults, lane order, pipeline depths) is in
  `rtl/params/dsp_fe.svh`.
- Memory dimensions and frame lengths are set in `rtl/params/dsp_mem.svh`.
- Backend pipeline depths, MLSE settings, and BERT dimensions are controlled by
  `rtl/params/dsp_be.svh`.
- Simulation-only constants such as scan timing, LUT contents for tests, and
  frame sync patterns reside in `tb/verif/tb_cfg_pkg.sv` and `tb/verif/tb_params.sv`.

Adjust these definitions carefully; many modules and BFMs share the same
`define` values, so changes should be validated across RTL and testbench.

## Citation

TODO
