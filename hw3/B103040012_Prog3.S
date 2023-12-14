     section .data
 MAXSTR         db 'Function 1: maximum of ', 0x0
 MAXSTR_LEN     equ $-MAXSTR
 GCDSTR         db 'Function 2: greatest common divisor of ', 0x0
 GCDSTR_LEN     equ $-GCDSTR
 LCMSTR         db 'Function 3: least common multiply of ', 0x0
 LCMSTR_LEN     equ $-LCMSTR
 ANDSTR         db ' and ',0x0
 ANDSTR_LEN     equ $-ANDSTR
 ISSTR          db ' is ',0x0
 ISSTR_LEN      equ $-ISSTR
 DOTSTR         db '.',0x0
 DOTSTR_LEN      equ $-DOTSTR
 CHAR           db 0x0,0x0
 TESTNUMA       db '100',0x0
 TESTNUMB       db '1',0x0
 TESTOP         db '3',0x0
 STRING         times 1000 db 0
 
 STDIN          equ 0
 STDOUT         equ 1
 SYS_EXIT       equ 1
 SYS_READ       equ 3
 SYS_WRITE      equ 4
 
     section .text
 max:
 ; max(eax, edx) -> eax
        cmp     eax, edx
        cmovle  eax, edx
        ret

 gcd:
 ; gcd(eax, edx) -> eax
        push    rcx
        
        mov     ecx, edx
        xor     rdx, rdx ; clear all rdx
        cmp     ecx, 0x0
        je      GCD_B_is_ZERO
GCD_LOOP:
        cdq
        idiv    ecx
        mov     eax, edx
        xchg    ecx, eax
        cmp     ecx, 0x0
        je      GCD_B_is_ZERO
        jmp     GCD_LOOP
GCD_B_is_ZERO:
        add     eax, ecx
        
        pop     rcx
        ret
 lcm:
 ; lcm(eax, edx) -> eax
        push    rcx
        push    rax
        push    rdx
        call    gcd
        mov     ecx, eax
        pop     rdx
        mov     rax, rdx
        cdq
        idiv    ecx
        pop     rcx
        mul     ecx
        pop     rcx
        ret
         
 print_int:
 ; print_int(eax) -> void
        push    rdx
        push    rcx
        push    rbx
        push    rax
        
        xor     rdx, rdx
        xor     rcx, rcx   ; the number of digital
        mov     rbx, 10
print_int_LOOP:
        inc     ecx
        cdq
        idiv    ebx
        push    rdx        ; eax % 10
        cmp     eax, 0
        je      PRINT_INT_ZERO
        jmp     print_int_LOOP
PRINT_INT_ZERO:
        pop     rbx
        add     bl, '0'
        mov     [CHAR], bl
        mov     rsi, CHAR
        call    print_CHAR
        dec     ecx
        jz      PRINT_INT_RET
        jmp     PRINT_INT_ZERO
PRINT_INT_RET:
        pop     rax
        pop     rbx
        pop     rcx
        pop     rdx
        ret

 to_int:
 ; to_int(rsi) -> eax
        push    rcx
        push    rbx
        xor     rax, rax
        xor     rbx, rbx
        xor     rcx, rcx
TO_INT_LOOP:
        mov     cl, [rsi]
        cmp     cl, '0'
        jl      TO_INT_RET
        cmp     cl, '9'
        jg      TO_INT_RET
        inc     rsi
        sub     cl, '0'
        mov     ebx, eax
        sal     eax, 3
        sal     ebx, 1
        add     eax, ebx
        add     eax, ecx
        jmp     TO_INT_LOOP
TO_INT_RET:
        pop     rbx
        pop     rcx
        ret

 print_CHAR:
 ; print_CHAR(rsi) -> void
        push    rdx
        push    rcx
        push    rbx
        push    rax
        
        mov     rdx, 1
        mov     rcx, rsi
        mov     rbx, STDOUT
        mov     rax, SYS_WRITE
        int     0x80
         
        pop     rax
        pop     rbx
        pop     rcx
        pop     rdx
        ret
        
 print_STR:
 ; print_STR(rsi: str, rdi: len) -> void
        push    rdx
        push    rcx
        push    rbx
        push    rax
        
        mov     rdx, rdi
        mov     rcx, rsi
        mov     rbx, STDOUT
        mov     rax, SYS_WRITE
        int     0x80
        
        pop     rax
        pop     rbx
        pop     rcx
        pop     rdx
        ret

 read_char:
        push    rdx
        push    rcx
        push    rbx
        push    rax
        
        mov     rdx, 1
        mov     rcx, rsi
        mov     rbx, STDIN
        mov     rax, SYS_READ
        int     0x80
        
        pop     rax
        pop     rbx
        pop     rcx
        pop     rdx
        ret

 read_till_space:
 ; read_till_space(rsi: str)
 ; put string into [rsi]
        push    rdx
        push    rcx
        push    rbx
        push    rax
        xor     rax, rax
        
RS_LOOP:
        mov     rdx, 1
        mov     rcx, rsi
        mov     rbx, STDIN
        mov     rax, SYS_READ
        int     0x80
        
        mov     al, [rsi]
        cmp     al, '\0'
        je      RS_EXIT
        cmp     al, '\n'
        je      RS_EXIT
        cmp     al, ' '
        je      RS_EXIT
        add     rsi, 1
        jmp     RS_LOOP
RS_EXIT:
        mov     al, 0x0
        mov     [rsi], al
        pop     rax
        pop     rbx
        pop     rcx
        pop     rdx
        ret

 global  _start
 _start:
        ; init 
        xor     rax, rax
        xor     rbx, rbx
        xor     rcx, rcx
        xor     rdx, rdx
        ; init end
        
        ;mov     rsi, TESTNUMB
        mov     rsi, STRING
        call    read_till_space
        mov     rsi, STRING
        call    to_int
        push    rax
        
        ;mov     rsi, TESTNUMA
        mov     rsi, STRING
        call    read_till_space
        mov     rsi, STRING
        call    to_int
        pop     rdx
        xchg    rax, rdx
        
        mov     rsi, STRING
        call    read_char
        ;mov     rsi, TESTOP
        mov     bl, [rsi]
        cmp     bl, '1'
        je      MAX
        cmp     bl, '2'
        je      GCD
        jmp     LCM
MAX:
        mov     rsi, MAXSTR
        mov     rdi, MAXSTR_LEN
        call    print_STR
        
        call    print_int
        
        mov     rsi, ANDSTR
        mov     rdi, ANDSTR_LEN
        call    print_STR
        
        xchg    rax, rdx
        call    print_int
         
        mov     rsi, ISSTR
        mov     rdi, ISSTR_LEN
        call    print_STR
        
        call    max
        call    print_int
        jmp     EXIT
GCD:
        mov     rsi, GCDSTR
        mov     rdi, GCDSTR_LEN
        call    print_STR
        
        call    print_int
         
        mov     rsi, ANDSTR
        mov     rdi, ANDSTR_LEN
        call    print_STR
        
        xchg    rax, rdx
        call    print_int
         
        mov     rsi, ISSTR
        mov     rdi, ISSTR_LEN
        call    print_STR
        
        call    gcd
        call    print_int
        jmp     EXIT
LCM:
        mov     rsi, LCMSTR
        mov     rdi, LCMSTR_LEN
        call    print_STR
        
        call    print_int
         
        mov     rsi, ANDSTR
        mov     rdi, ANDSTR_LEN
        call    print_STR
        
        xchg    rax, rdx
        call    print_int
         
        mov     rsi, ISSTR
        mov     rdi, ISSTR_LEN
        call    print_STR
        
        call    lcm
        call    print_int
        jmp     EXIT
EXIT:
        mov     rsi, DOTSTR
        mov     rdi, DOTSTR_LEN
        call    print_STR
        
        mov     rbx, 0
        mov     rax, SYS_EXIT
        int     0x80