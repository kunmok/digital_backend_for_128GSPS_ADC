

// EQ parameters
`define ALU_PRE_PP_DEPTH 3
`define ALU_PST_PP_DEPTH 1
`define FILT_PRE_PP_DEPTH 3
`define FILT_PST_PP_DEPTH 2
`define DEC_PRE_PP_DEPTH 3
`define DEC_PST_PP_DEPTH 1


// BERT parameters
// Note that each should be precisely matching with the corresponding
// rx_bert local parameters since they dictate the width of the connecting
// signals
// TODO: double check the consistency during synthesis, since it will manifest
// as corresponding width mismatch

// SNAP_LENGTH == SnapLength in rx_bert (32)
`define SNAP_LENGTH 32

// PATT_LENGTH == PattLength in rx_bert (32)
`define PATT_LENGTH 32

// BERT_WAY_WIDTH == Ways in rx_bert (16)
`define BERT_WAY_WIDTH 16

// TOT_SNAP_LENGTH == TotSnapLength in rx_bert
// TotSnapLength = Ways * SnapLength = 16 * 32 = 512
`define TOT_SNAP_LENGTH ( `BERT_WAY_WIDTH * `SNAP_LENGTH )

// TOT_PGEN_CFG_LENGTH == TotPgenCfgLength in rx_bert
// TotPgenCfgLength = Ways * PgenCfgLength = 16 * (4 + SeedLength)
// = 16 * (4 + max(PattLength, PrbsLength)) = 16 * (4 + 32)
// = 16 * 36 = 576
`define TOT_PGEN_CFG_LENGTH ( `BERT_WAY_WIDTH * ( 4 + `PATT_LENGTH ) )

// SHUTOFF_SEL_WIDTH == ShutoffSelWidth in rx_bert (4)
`define SHUTOFF_SEL_WIDTH 4

// BER_COUNT_WIDTH == BerCountWidth in rx_bert (41)
`define BER_COUNT_WIDTH 41

// TOT_BER_COUNT_WIDTH == TotBerCountWidth in rx_bert which is 16 * 41 = 656
`define TOT_BER_COUNT_WIDTH ( `BERT_WAY_WIDTH * `BER_COUNT_WIDTH )


