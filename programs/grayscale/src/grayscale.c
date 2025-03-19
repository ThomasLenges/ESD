#include <stdio.h>
#include <ov7670.h>     // Library for the OV7670 camera module
#include <swap.h>       // Library for byte swapping operations (to communicate between peripherals using little/big endian)
#include <vga.h>        // Library for VGA display operations

#define PROFILING 1
#define ACCELERATING 1

int main () {
  // Buffers to store image data
  volatile uint16_t rgb565[640*480];
  volatile uint8_t grayscale[640*480];

  // Variables for profiling or debugging
  volatile uint32_t result, cycles, stall, idle;
  
  // Pointer to VGA memory-mapped register at address 0x50000020
  volatile unsigned int *vga = (unsigned int *) 0X50000020;
  // Structure to hold camera parameters (resolution, FPS, etc.)
  camParameters camParams;
  vga_clear();
  
  // Initialize the camera module
  printf("Initialising camera (this takes up to 3 seconds)!\n" );
  camParams = initOv7670(VGA);
  printf("Done!\n" );

  // Prepare for VGA display and display camera information
  printf("NrOfPixels : %d\n", camParams.nrOfPixelsPerLine );
  result = (camParams.nrOfPixelsPerLine <= 320) ? camParams.nrOfPixelsPerLine | 0x80000000 : camParams.nrOfPixelsPerLine;
  vga[0] = swap_u32(result);
  printf("NrOfLines  : %d\n", camParams.nrOfLinesPerImage );
  result =  (camParams.nrOfLinesPerImage <= 240) ? camParams.nrOfLinesPerImage | 0x80000000 : camParams.nrOfLinesPerImage;
  vga[1] = swap_u32(result);
  printf("PCLK (kHz) : %d\n", camParams.pixelClockInkHz );
  printf("FPS        : %d\n", camParams.framesPerSecond );

  // Configure VGA for grayscale mode
  uint32_t * rgb = (uint32_t *) &rgb565[0];
  uint32_t grayPixels;
  vga[2] = swap_u32(2);
  vga[3] = swap_u32((uint32_t) &grayscale[0]);


#if PROFILING
  // Reset profiling counters before measuring
  // Gives valueB (in2) the indicated value ==> Reset of counters
  asm volatile ("l.nios_rrr r0, r0, %[in2], 0x8" :: [in2] "r" (0xF << 8));
#endif

  while(1) {
    printf("I'm in a loop");

#if PROFILING
    // Enable profiling counters
    // Gives valueB (in2) the indicated value ==> enable counters
    asm volatile ("l.nios_rrr r0, r0, %[in2], 0x8" :: [in2] "r" (0xF));
#endif


    uint32_t * gray = (uint32_t *) &grayscale[0];
    takeSingleImageBlocking((uint32_t) &rgb565[0]);

    // Convert captured image from RGB565 format to grayscale
    for (int line = 0; line < camParams.nrOfLinesPerImage; line++) {
      for (int pixel = 0; pixel < camParams.nrOfPixelsPerLine; pixel++) {

        // Extract 16-bit RGB565 pixel from buffer with swapped bytes
        uint16_t rgb = swap_u16(rgb565[line*camParams.nrOfPixelsPerLine+pixel]);

#if ACCELERATING
        uint32_t gray;
        asm volatile("l.nios_rrr %[out1], %[in1], r0, 0x9"
                      : [out1] "=r" (gray)
                      : [in1] "r" (rgb));

#else
        // Extract individual color components from RGB565 format
        uint32_t red1 = ((rgb >> 11) & 0x1F) << 3;
        uint32_t green1 = ((rgb >> 5) & 0x3F) << 2;
        uint32_t blue1 = (rgb & 0x1F) << 3;
        uint32_t gray = ((red1*54+green1*183+blue1*19) >> 8)&0xFF;

#endif
        // Store grayscale pixel in buffer
        grayscale[line*camParams.nrOfPixelsPerLine+pixel] = gray;
      }
    }

#if PROFILING
    // Disable profiling counters (see above)
    asm volatile ("l.nios_rrr r0, r0, %[in2], 0x8" :: [in2] "r" (0xF << 4));
    uint32_t counter_id;

    // Number of µC execution cycles
    counter_id = 0;
    asm volatile ("l.nios_rrr %[out1], %[in1], r0, 0x8" 
                  : [out1] "=r" (cycles) 
                  : [in1] "r" (counter_id));
    printf("Execution cycles: %d\n", cycles);

    // Number of µC stall cycles
    counter_id = 1;
    asm volatile ("l.nios_rrr %[out1], %[in1], r0, 0x8" 
                  : [out1] "=r" (stall) 
                  : [in1] "r" (counter_id));
    printf("Stall cycles: %d\n", stall);

    // Number of bus-idle cycles
    counter_id = 2;
    asm volatile ("l.nios_rrr %[out1], %[in1], r0, 0x8" 
                  : [out1] "=r" (idle) 
                  : [in1] "r" (counter_id));
    printf("Bus-idle cycles: %d\n", idle);


    // Resetting counters
    asm volatile ("l.nios_rrr r0, r0, %[in2], 0x8" :: [in2] "r" (0xF << 8));

#endif
  }
}

/*
Profiling values (without code modifications):
Execution cycles: ~39000000 cycles
Stall cycles: ~17680000 cycles
Bus idle cycles: ~23840000 cycles
Active execution cycles (execution - stall): ~21320000

Profiling values (with acceleration):
Execution cycles: ~29110000 cycles
Stall cycles: ~17080000 cycles
Bus idle cycles: ~15170000 cycles
Active execution cycles (execution - stall): ~13940000

Drawn conclusions (also provided in README):
  From the above metrics, we can assess that our acceleration as such impact:
    Speedup = (Original nb. cycles)/(Accelerated nb. cycles) 
    Percentage gain = (Original nb. cycles - Accelerated nb. cycles)/(Original nb. cycles)
      Execution Speedup = 1.34
      Execution Gain (%) = 25.35%

      Stall Speedup = 1.04
      Stall Gain (%) = 3.39%

      Bus idle Speedup = 1.57
      Bus idle Gain (%) = 36.37%

      Active Speedup = 1.53
      Active Gain (%) = 34.62%

*/