#include <allegro5/allegro5.h>
#include <allegro5/allegro_font.h>
#include "JuliaSet.h"
#define WIDTH 600
#define HEIGHT 600


void displayRGBPixels(uint8_t *pixelArray, int width, int height) {
    for (int row = 0; row < height; row++) {
        for (int col = 0; col < width; col++) {
            int pixelIdx = 3 * (row * width + col);
            al_draw_pixel(col, row, al_map_rgb(
                    pixelArray[pixelIdx],
                    pixelArray[pixelIdx + 1],
                    pixelArray[pixelIdx + 2]
            ));
        }
    }
}


int main() {
    al_init();
    al_install_keyboard();

    ALLEGRO_TIMER *timer = al_create_timer(1.0 / 30.0);
    ALLEGRO_EVENT_QUEUE *queue = al_create_event_queue();
    ALLEGRO_DISPLAY *disp = al_create_display(WIDTH, HEIGHT);
    ALLEGRO_FONT *font = al_create_builtin_font();

    al_register_event_source(queue, al_get_keyboard_event_source());
    al_register_event_source(queue, al_get_timer_event_source(timer));

    bool redraw = true;
    ALLEGRO_EVENT event;

    uint8_t *pixels = malloc(WIDTH * HEIGHT * 3);
    double ReC = 0;
    double ImC = 0;
    double radius = 2.0;
    double deltaC = 0.025;
    JuliaSet(pixels, WIDTH, HEIGHT, ReC, ImC, radius);
    displayRGBPixels(pixels, WIDTH, HEIGHT);

    al_start_timer(timer);
    while (true) {
        al_wait_for_event(queue, &event);

        if (event.type == ALLEGRO_EVENT_KEY_CHAR) {
            if (event.keyboard.keycode == ALLEGRO_KEY_ESCAPE) {
                break;
            }

            if (event.keyboard.keycode == ALLEGRO_KEY_LEFT) {
                ReC -= deltaC;
            } else if (event.keyboard.keycode == ALLEGRO_KEY_RIGHT) {
                ReC += deltaC;
            } else if (event.keyboard.keycode == ALLEGRO_KEY_UP) {
                ImC += deltaC;
            } else if (event.keyboard.keycode == ALLEGRO_KEY_DOWN) {
                ImC -= deltaC;
            }
            redraw = true;

        } else if (event.type == ALLEGRO_EVENT_DISPLAY_CLOSE) {
            break;
        }

        if (redraw && al_is_event_queue_empty(queue)) {
            JuliaSet(pixels, WIDTH, HEIGHT, ReC, ImC, radius);
            displayRGBPixels(pixels, WIDTH, HEIGHT);
            al_flip_display();

            redraw = false;
        }
    }

    al_destroy_font(font);
    al_destroy_display(disp);
    al_destroy_timer(timer);
    al_destroy_event_queue(queue);

    free(pixels);
    return 0;
}