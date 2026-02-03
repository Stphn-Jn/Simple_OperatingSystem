@echo off
:: Set Path for DLLs
set PATH=%PATH%;C:\msys64\mingw32\bin

echo [1/4] Compiling...
C:\msys64\mingw32\bin\gcc.exe -ffreestanding -c kernel.c -o k_final.o

echo [2/4] Linking...
C:\msys64\mingw32\bin\ld.exe -o kernel.tmp -Ttext 0x1000 entry.o k_final.o

echo [3/4] Creating Binary...
C:\msys64\mingw32\bin\objcopy.exe -O binary kernel.tmp kernel.bin

echo [4/4] Joining Image...
copy /b boot.bin+kernel.bin PingOS.img
echo DONE!
pause