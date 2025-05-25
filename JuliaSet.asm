; Arguments
; RDI: uint8_t *pixels
; RSI: int width
; RDX: int height
; XMM0: double ReC
; XMM1: double ImC
; XMM2: double radius

;;64-bit registers -> int values
;;  RDI - uint8_t *pixels
;;  RSI - int width
;;  RDX - int height
;;  R8 - width  iterator
;;  R9 - height iterator
;;  R10 - max iterations
;;  R11 - current iterations
;;  R12 - memory offset

;;128-bit registers -> double precision values
;;  XMM0 - double ReC
;;  XMM1 - double ImC
;;  XMM2 - double radius
;;  XMM3 - Re temporary
;;  XMM4 - Im temporary
;;  XMM5 - horizontal distance (delta Re)
;;  XMM6 - vertical   distance (delta Im)
;;  XMM7 - Re current column
;;  XMM8 - Im current row
;;  XMM9 - vector length
;;  XMM10 - new Re temp
;;  XMM11 - new Im temp

section .text
global JuliaSet

JuliaSet:
    ; Prologue
    push    rbp
    mov     rbp, rsp
    push    rbx

;; calculation preparation
prep:
    mov     r15, 0          ; white
    mov     r14, 0          ; black
    mov     rax, 6
    cvtsi2sd xmm7, rsi
    cvtsi2sd xmm5, rax
    divsd   xmm5, xmm7      ; xmm5 = 3 / width == h. dist.
    cvtsi2sd xmm7, rdx
    cvtsi2sd xmm6, rax
    divsd   xmm6, xmm7      ; xmm6 = 3 / height == v. dist.

    mov      rax, -3
    cvtsi2sd xmm7, rax      ; xmm7,current Re = -3
    mov      rax, 3
    cvtsi2sd xmm8, rax      ; xmm8,current Im = 3

    mov     r10, 256        ; r10,max iteration = 256
    mov     r9, rdx         ; r9 = height
    inc     r9              ; add 1 height (removed too much later)
    mov     r12, 0          ; set offset to 0

height_loop:
    dec     r9              ; height -= 1
    jz      end             ;   end program
    mov     r8, rsi         ; r8 = width
    add     r8, 1           ; fix r8 (removed too much later)
    mov     rax, -3
    cvtsi2sd xmm7, rax      ; set default real value
    subsd   xmm8, xmm6      ; go down by 1 Im unit (dst)

width_loop:
    dec     r8              ; width -= 1
    jz      height_loop     ;   go to next row
    mov     r11, r10        ; set max iterations (256)
    addsd   xmm7, xmm5      ; go right by 1 Re unit (dst)

    movsd   xmm3, xmm7      ; copy Re to temp
    movsd   xmm4, xmm8      ; copy Im to temp

calculate_pixel:
    ; Operations on imaginary numbers
    ; z = x + yi
    ; z(n+1) = z(n)^2 + c
    ; z(n+1) = x^2 - y^2 + 2xyi + c
    ; New Re = x^2 - x^2 + ReC
    ; New Im = 2xy + ImC

    ; New Re = Re^2 - Im^2 + Rec
    movsd   xmm10, xmm3     ; New Re = Re
    mulsd   xmm10, xmm10    ; New Re = Re^2
    movsd   xmm11, xmm4     ; Im
    mulsd   xmm11, xmm11    ; Im^2
    subsd   xmm10, xmm11    ; New Re = Re^2 - Im^2
    addsd   xmm10, xmm0     ; New Re = Re^2 - Im^2 + ReC
    ; New Im = 2 * Re * Im + ImC
    movsd   xmm11, xmm3     ; New Im = Re
    mulsd   xmm11, xmm4     ; New Im = Re * Im
    addsd   xmm11, xmm11    ; New Im = 2 * Re * Im
    addsd   xmm11, xmm1     ; New Im = 2 * Re * Im + ReC

    movsd   xmm3, xmm10     ; Re = New Re
    movsd   xmm4, xmm11     ; Im = New Im
    ; If vector length exceeds $(radius), the pixel will wander off to infinity
    ; |V| = sqrt(New Re^2 + New Im^2) => |V|^2 = New Re^2 + New Im^2
    movsd   xmm9, xmm3      ; |V|^2 = New Re
    mulsd   xmm9, xmm9      ; |V|^2 = New Re^2
    movsd   xmm10, xmm4     ; New Im
    mulsd   xmm10, xmm10    ; New Im^2
    addsd   xmm9, xmm10     ; |V|^2 = New Re^2 + New Im^2

    comisd  xmm2, xmm9
    jc      color_white     ; |V|^2 >= radius -> pixel no longer needed
    dec     r11             ; remvoe 1 from iterations counter
    jz      color_black     ;   color it black
    inc r14
    jmp     calculate_pixel ;   else: repeat

color_black:
    mov     byte [rdi + r12], 0
    mov     byte [rdi + r12 + 1], 0
    mov     byte [rdi + r12 + 2], 0
    add     r12, 3          ; go to next pixel
    jmp     width_loop
color_white:
    mov     byte [rdi + r12], 255
    mov     byte [rdi + r12 + 1], 255
    mov     byte [rdi + r12 + 2], 255
    add     r12, 3          ; go to next pixel
    inc r15
    jmp     width_loop
end:
    ; Epilogue
    movsd xmm0, xmm7
    pop     rbx
    mov     rsp, rbp
    pop     rbp
    ret