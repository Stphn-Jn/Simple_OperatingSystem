#include "io.c" //

void main() {
    char* vga = (char*) 0xb8000; // VGA Buffer
    char* msg = "Arch-PingOS: C-Kernel Loaded!";
    
    for (int i = 0; i < 80 * 25 * 2; i += 2) {
        vga[i] = ' ';
        vga[i+1] = 0x07; // Clear screen
    }

    for (int i = 0; msg[i] != '\0'; i++) {
        vga[i*2] = msg[i];
        vga[i*2+1] = 0x0B; // Cyan color
    }

    while(1); // Infinite loop
}