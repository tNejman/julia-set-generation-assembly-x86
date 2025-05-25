cmake_minimum_required(VERSION 3.12)
project(Julia C ASM)

set(CMAKE_C_STANDARD 11)

enable_language(ASM_NASM)
set(CMAKE_ASM_NASM_LINK_EXECUTABLE "ld <FLAGS> <CMAKE_ASM_NASM_LINK_FLAGS> <LINK_FLAGS> <OBJECTS>  -o <TARGET> <LINK_LIBRARIES>")

set(ALLEGRO_INCLUDE_DIR "usr/include/x86_64-linux-gnu")
set(ALLEGRO_LIBRARIES "-lallegro_font -lallegro")

add_executable(JuliaSet main.c JuliaSet.h JuliaSet.asm)
target_include_directories(JuliaSet PRIVATE ${ALLEGRO_INCLUDE_DIR})
target_link_libraries(JuliaSet PRIVATE ${ALLEGRO_LIBRARIES})