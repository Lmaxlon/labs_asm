#include <inttypes.h>
#include <string.h>
#include <stdio.h>
#include <time.h>
#include <unistd.h>
#define STB_IMAGE_WRITE_IMPLEMENTATION
#define STB_IMAGE_IMPLEMENTATION
#define STBI_FAILURE_USERMSG
#include "stb_image.h"
#include "stb_image_write.h"

uint8_t* extending(uint8_t *img, uint32_t width, uint32_t height);
int work(char *input, char *output);
void process_asm(uint8_t *img, uint8_t *copy, uint32_t width, uint32_t height);
void process(uint8_t *img, uint8_t *copy, uint32_t width, uint32_t height);

int main(int argc, char **argv) {
    if(argc < 3) {
        printf("Please enter input and output files\n");
        return 0;
    }

    if(access(argv[1], R_OK) != 0) {
        printf("Opening input file error %s\n", argv[1]);
        return 0;
    }

    int ret = work(argv[1], argv[2]);
    return ret;
}

int work(char *input, char *output) {
    int w, h;
    unsigned char *data = stbi_load(input, &w, &h, NULL, 3);

    if (data == NULL) {
        puts(stbi_failure_reason());
        return 1;
    }

    size_t size = w * h * 3;
    uint8_t *extens = extending(data, w, h);
    uint8_t *copy = malloc((w + 2) * (h + 2) * 3);

    clock_t begin = clock();

    #ifdef ASM
        process_asm(extens, copy, w + 2, h + 2);
    #else
        process(extens, copy, w + 2, h + 2);
    #endif

    clock_t end = clock();
    // printf("processing time: %lf\n", time_spent);
    printf("%lf", (double)(end - begin) / CLOCKS_PER_SEC);
    fflush(stdout);

    if (stbi_write_png(output, w, h, 3, copy + (w+2)*3+3, (w+2)*3) == 0) {
    // if (stbi_write_png(output, w + 2, h + 2, 3, copy, 0) == 0) {
        puts("Some png writing error\n");
        return 1;
    }

    free(copy);
    free(extens);
    stbi_image_free(data);
    return 0;
}

uint8_t* extending(uint8_t *img, uint32_t w, uint32_t h) {
    uint8_t *extens = malloc((w + 2) * (h + 2) * 3);

    int line1 = w * 3;
    int line2 = (w + 2) * 3;

    register int i1 = 0;
    register int i2 = line2 + 1 * 3;

    for (register int y = 0; y < h; ++y) {
        for (register int x = 0; x < w; ++x) {
            extens[i2] = img[i1];
            extens[i2+1] = img[i1+1];
            extens[i2+2] = img[i1+2];
            i1 += 3;
            i2 += 3;
        }
        i2 += 2 * 3;
    }

    i1 = line2;
    for (register int y = 1; y <= h; ++y) {
        extens[i1] = extens[i1+3];
        extens[i1+1] = extens[i1+4];
        extens[i1+2] = extens[i1+5];
        i1 += line2;
        extens[i1-3] = extens[i1-6];
        extens[i1-2] = extens[i1-5];
        extens[i1-1] = extens[i1-4];
    }

    memcpy(extens, extens + line2, line2);
    memcpy(extens + line2 * (h + 1), extens + line2 * h, line2);

    return extens;
}

static inline int process_one(uint8_t *img, int index, int line) {
    return (
        36*(int)img[index]
        + 24*(int)img[index - 3]
        + 24*(int)img[index + 3]
        + 24*(int)img[index - line]
        + 24*(int)img[index + line]
        + 16*(int)img[index - line -3]
        + 16*(int)img[index - line + 3]
        + 16*(int)img[index + line - 3]
        + 16*(int)img[index + line + 3]
        + 6*(int)img[index + 6]
        + 6*(int)img[index - 6]
        + 6*(int)img[(index - line) - line]
        + 6*(int)img[(index + line) + line]
        + 4*(int)img[index + line + line - 3]
        + 4*(int)img[index + line + line + 3]
        + 4*(int)img[index + 6 - line]
        + 4*(int)img[index + 6 + line]
        + 4*(int)img[index - 6 + line]
        + 4*(int)img[index -6 - line]
        + (int)img[index + line + line - 6]
        + (int)img[index + line + line + 6]
        + (int)img[index - line - line - 6]
        + (int)img[index - line - line +6]
    ) / 256;
}

void process(uint8_t *img, uint8_t *copy, uint32_t w, uint32_t h) {
    int line = w * 3;

    register int i = line + 3;

    for (register int y = 1; y < h - 1; ++y) {
        for (register int x = 1; x < w - 1; ++x, i += 3) {
            copy[i] = process_one(img, i, line);
            copy[i+1] = process_one(img, i+1, line);
            copy[i+2] = process_one(img, i+2, line);
        }
    }
}
