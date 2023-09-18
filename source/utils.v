
`ifndef UTILS_H
`define UTILS_H



`define S_WIDTH 24  // sample width in bits
`define C_WIDTH 27  // coefficient width in bis
`define R_WIDTH 32  // result width in bits
`define N_TAPS 29   // number of taps in the filter
`define N_TAPS_HALF ((`N_TAPS+1)/2) // half the number of taps, including the center one when odd, 15
`define PAIRS 3
`define S_PAIR_SIZE ((`N_TAPS+`PAIRS-1)/`PAIRS) // nmber of samples in one pair, 10
`define C_PAIR_SIZE ((`N_TAPS_HALF+`PAIRS-1)/`PAIRS) // number of coeffs in one pair, 5
// unpack 
//  'arr' is the reg/wire name
//  'idx' is the starting index of slice (0 is first)
//  'width' is the size of slice
`define SLICE(arr, idx, width) arr[((idx+1)*width)-1:(idx*width)]



`endif

