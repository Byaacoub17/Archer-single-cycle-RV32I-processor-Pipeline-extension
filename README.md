# Archer RV32I Processor — Five-Stage Pipeline Extension

Archer began as a single-cycle RISC-V processor project in EECE 321 (Computer Organization) at the American University of Beirut. After the course, the datapath was extended into a five-stage pipeline in Verilog. This repository contains the pipelined core, its Vivado simulation project, and a recursive Fibonacci program for tracing instructions through the design.

## Datapath

Four pipeline registers carry data and control signals between stages: `IF/ID`, `ID/EX`, `EX/MEM`, and `MEM/WB`. The processor module retains its original name, `archer_rv32i_single_cycle`.

| Stage | What happens in the RTL |
| --- | --- |
| IF — Instruction fetch | The PC addresses instruction memory. The next-PC mux selects either PC + 4 or the target calculated in decode. |
| ID — Instruction decode | The register file supplies source operands, the immediate generator expands the immediate, and the control unit decodes the instruction. A comparator and a dedicated adder handle the branch decision and target. |
| EX — Execute | Operand muxes select the register, forwarded, immediate, or PC-derived values required by the instruction. The ALU computes an arithmetic result, logic result, or memory address. |
| MEM — Memory access | The data-memory interface uses the ALU address for loads and stores. Store data travels through the EX/MEM register. |
| WB — Writeback | Writeback muxes select the ALU result, load data, or saved PC + 4. The MEM/WB register supplies the destination register and write enable. |

### Forwarding, stalls, and flushes

- **Forwarding.** `ForwardingUnit.v` compares source register indices in decode and execute with pending destination registers in EX/MEM and MEM/WB. The operand muxes share one forwarded value. When both stages match, EX/MEM takes priority. Two operands that need different forwarding stages in the same cycle cannot both receive their respective values through this path.
- **Load-use stall.** When a load in ID/EX has a destination that matches either source field in IF/ID, `hdu.v` holds the PC and IF/ID register and inserts a bubble by clearing the control signals entering ID/EX.
- **Control-flow flush.** When decode redirects the PC, the hazard unit marks the sequentially fetched instruction for flushing. A load-use stall takes priority over the redirect in the hazard unit.

## Run the simulation

1. Clone this repository and open **12 26 2025 pipelining files.xpr** in AMD Vivado. The project was saved with **Vivado 2024.2**.
2. In **Flow Navigator**, select **Simulation → Run Simulation → Run Behavioral Simulation**. The configured simulation top is `archer_rv321_single_cycle_tb` (spelled `rv321` in the module declaration).
3. In the simulation hierarchy, expand the testbench and select the `archer` instance. Add `d_pc_out`, `IF_ID_write`, `Stage_output`, and `d_reg_file_datain` to the waveform. Use **Restart** and then **Run All** to capture the trace from reset.

The testbench instantiates the core, instruction ROM, and data SRAM. It generates a 20 ns clock period and applies an active-low reset. Check the waveform or memory contents to evaluate the run. The testbench has no automatic pass/fail check.

## Fibonacci example

[fib.s](fib.s) uses recursive calls, stack loads and stores, conditional branches, and returns to compute Fibonacci numbers for inputs 0 through 10. [fib.c.txt](fib.c.txt) gives the corresponding C algorithm. The expected result array is `0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55`.

The simulator fetches the instruction bytes initialized in `rom.v`. To try a modified assembly program, assemble it and update those bytes before rerunning the simulation. To follow the result stores, watch `tb_dmem_addr` and `tb_dmem_datain` while `tb_dmem_wen` is asserted. The recursive routine also writes to the stack, so use the destination address to distinguish stack writes from array writes.

## Source files

The [Verilog source directory](12%2026%202025%20pipelining%20files.srcs/sources_1/imports/Archer%20Processor%20Pipelining%20Improvment/) contains the core and its simulation models.

| Files | Purpose |
| --- | --- |
| `archer_rv32i_single_cycle.v` | Top-level pipeline connections and muxes |
| `IF_ID_Datapath_Register.v`, `ID_EX_Datapath_Register.v`, `EX_MEM_Datapath_Register.v`, `MEM_WB_Datapath_Register.v` | The four pipeline registers used by the Vivado project |
| `ForwardingUnit.v`, `hdu.v` | Forwarding decisions, stalls, and flush control |
| `branch_cmp.v`, `Branch_Adder.v`, `control.v` | Branch comparison, target calculation, and instruction control |
| `rom.v`, `sram.v`, `archer_rv32i_single_cycle_tb.v` | Instruction memory, data memory, and processor testbench |

## Credits

The original Archer processor was developed by the Embedded and Reconfigurable Computing Lab at the American University of Beirut. The original source headers credit Mazen A. R. Saghir and identify the hardware license as `CERN-OHL-P-2.0+`.
