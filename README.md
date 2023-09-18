# Resource Constrained FIR Filter Design (CDC)

![FIR-Page-3 drawio](https://github.com/bhavinpt/fir-cdc/assets/117598876/1c28d470-60b6-474b-9485-59eed21b0191)

This project involves implementing a resource-constrained FIR filter using fixed-point arithmetic with only 5 complex multipliers. The FIR filter has 29 taps, is symmetric, and operates at a frequency of 300MHz. The design incorporates DFT techniques to efficiently process signals with limited hardware resources. 

#### These are the design constraints:

- Only 5 complex multipliers can be used in the design.
- Samples and coefficients must use fixed-point representation.
- 300MHz Operating Frequency

## Design
### Architecture
The FIFOs are used to synchronize between fast input domain and slow processing architecture. 
Every input is processed in 3 processing cycles. Due to only 5 complex multipliers, only 1/3 samples are multiplied and accumulated to the final output on each processing cycle.
Muxes are used to select 3 different sets of inputs and coefficients on 3 different processing cycles.
The design uses fixed-point numbers and preserves precision during intermediate additions and multiplications.
![FIR-Page-2 drawio](https://github.com/bhavinpt/fir-cdc/assets/117598876/bf1599fd-e8a7-4b65-a314-11bf98564a87)

### RTL Implementation
![FIR-Page-1 drawio](https://github.com/bhavinpt/fir-cdc/assets/117598876/153e90db-74e8-4aee-a860-cfbf3ee11af0)
