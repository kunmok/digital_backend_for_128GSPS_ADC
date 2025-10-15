//==============================================================================
// Author: Sunjin Choi
// Description: 
// Signals:
// Note: 
// Variable naming conventions:
//    signals => snake_case
//    Parameters (aliasing signal values) => SNAKE_CASE with all caps
//    Parameters (not aliasing signal values) => CamelCase
//==============================================================================

// verilog_format: off
`timescale 1ns/1ps
`default_nettype none
// verilog_format: on


interface scan_if;

  // TODO: verify post-syn/par netlist
  typedef struct packed {
    logic sclkp;
    logic sclkn;
    logic senable;
    logic supdate;
    logic sreset;
  } scan_ctrl_t;

  logic sdata;
  scan_ctrl_t sctrl;

  modport send(output sdata, output sctrl);
  modport recv(input sdata, input sctrl);

  /*  logic sclkp;
 *  logic sclkn;
 *  logic senable;
 *  logic supdate;
 *  logic sreset;
 *
 *  modport send(
 *      output sdata,
 *      output sclkp,
 *      output sclkn,
 *      output senable,
 *      output supdate,
 *      output sreset
 *  );
 *
 *  modport recv(input sdata, input sclkp, input sclkn, input senable, input supdate, input sreset);*/

endinterface

`default_nettype wire

