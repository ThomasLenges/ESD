## Profiling Results and Performance Analysis

### Profiling Values (Without Code Modifications):
- **Execution Cycles**: ~39,000,000 cycles
- **Stall Cycles**: ~17,680,000 cycles
- **Bus Idle Cycles**: ~23,840,000 cycles
- **Active Execution Cycles** (Execution - Stall): ~21,320,000 cycles

### Profiling Values (With Acceleration):
- **Execution Cycles**: ~29,110,000 cycles
- **Stall Cycles**: ~17,080,000 cycles
- **Bus Idle Cycles**: ~15,170,000 cycles
- **Active Execution Cycles** (Execution - Stall): ~13,940,000 cycles

### Performance Improvement Analysis
From the above metrics, we can assess the impact of acceleration using the following formulas:

#### Formulas Used:
- **Speedup**:

\[
\text{Speedup} = \frac{\text{Original number of cycles}}{\text{Accelerated number of cycles}}
\]

- **Percentage Gain**:

\[
\text{Percentage Gain} = \left( \frac{\text{Original number of cycles} - \text{Accelerated number of cycles}}{\text{Original number of cycles}} \right) \times 100
\]

#### Computed Results:
- **Execution Speedup** = 1.34
- **Execution Gain (%)** = 25.35%


- **Stall Speedup** = 1.04
- **Stall Gain (%)** = 3.39%


- **Bus Idle Speedup** = 1.57
- **Bus Idle Gain (%)** = 36.37%


- **Active Execution Speedup** = 1.53
- **Active Execution Gain (%)** = 34.62% 
