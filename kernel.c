/* kernel.c - Bare Metal C Kernel */

/**
 * MINGW STUB:
 * MinGW's GCC automatically inserts a call to __main for constructor initialization.
 * Since we have no standard library, we must define it as an empty function to 
 * satisfy the linker.
 */
void __main() {}

/**
 * VGA PRINTING:
 * 0xb8000 is the memory-mapped address for the VGA text buffer.
 * Each character on screen takes 2 bytes: [ASCII Code][Attribute/Color]
 */
void main() {
    char* vga = (char*) 0xb8000; 
    char* msg = "Arch-PingOS: C-Kernel Loaded!";
    
    // 1. Clear the screen (fills with space characters and light gray color)
    // 80 columns * 25 rows * 2 bytes per character
    for (int i = 0; i < 80 * 25 * 2; i += 2) {
        vga[i] = ' ';      // Blank character
        vga[i+1] = 0x07;   // Light Gray attribute
    }

    // 2. Print the welcome message
    for (int i = 0; msg[i] != '\0'; i++) {
        vga[i*2] = msg[i];     // Set the character
        vga[i*2+1] = 0x0B;     // Set attribute to Cyan
    }

    // 3. Infinite loop to prevent the CPU from executing random memory
    while(1); 
}