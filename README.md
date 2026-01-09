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

For design details, please refer to [design documentation](DESIGN.md) and inline comments.

## License

This project is licensed under the BSD 3-Clause License. See the [LICENSE](LICENSE) file for details.

## Contact

For questions or access to proprietary IP, please reach out to the authors:

- Sunjin Choi - <sunjin_choi@berkeley.edu>
- Kunmo Kim - <kunmok@berkeley.edu>

