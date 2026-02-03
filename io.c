// io.c
unsigned char inb(unsigned short port) {
    unsigned char result;
    __asm__ volatile ("inb %w1, %b0" : "=a"(result) : "Nd"(port));
    return result;
}

void outb(unsigned short port, unsigned char data) {
    __asm__ volatile ("outb %b0, %w1" : : "a"(data), "Nd"(port));
}