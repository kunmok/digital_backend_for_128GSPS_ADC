
prbs_7_1.length = 7;
prbs_7_1.bits = 1;
prbs_7_1.coefficients = '03';

prbs_7_7.length = 7;
prbs_7_7.bits = 7;
prbs_7_7.coefficients = '03';

prbs_31_1.length = 31;
prbs_31_1.bits = 1;
prbs_31_1.coefficients = '00000009';

prbs_31_4.length = 31;
prbs_31_4.bits = 4;
prbs_31_4.coefficients = '00000009';

prbs_31_8.length = 31;
prbs_31_8.bits = 8;
prbs_31_8.coefficients = '00000009';

prbs_31_16.length = 31;
prbs_31_16.bits = 16;
prbs_31_16.coefficients = '00000009';

prbs_31_32.length = 31;
prbs_31_32.bits = 32;
prbs_31_32.coefficients = '00000009';

prbs_stuff = {prbs_7_1 prbs_7_7 prbs_31_1 prbs_31_4 prbs_31_8 prbs_31_16 prbs_31_32};
gen_prbs_verilog(prbs_stuff, 'test.v');