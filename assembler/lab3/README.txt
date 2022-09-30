u can use main.sw (rename this file for using) and pro.s
main.sw - no bugs, but i dont use small duplicate buffer
pro.s - using duplicate small buffer, but have bugs
prog13/pro.s or prog13/main.sw
make all
aarch64-run pro text.txt (text.txt is input file)
aarch64-debug prog1
or
qemu-aarch64-static pro text.txt
