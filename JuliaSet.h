#ifndef JULIA_SET_H
#define JULIA_SET_H

#include <stdio.h>
#include <stdint.h>

    double JuliaSet(
        uint8_t *pixels,
        int width,
        int height,
        double ReC,
        double ImC,
        double radius
        );

#endif //JULIA_SET_H