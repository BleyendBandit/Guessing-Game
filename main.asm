.386      ;identifies minimum CPU for this program

.MODEL flat, stdcall    ;flat - protected mode program
                        ;stdcall - enables calling of MS_windows programs

;allocate memory for stack
;(default stack size for 32 bit implementation is 1MB without .STACK directive 
;  - default works for most situations)

.STACK 4096            ;allocate 4096 bytes (1000h) for stack

;*******************MACROS********************************

;Macro definition of mPrtStr
mPrtStr  MACRO arg1             ;arg1 is replaced by the name of the string to be displayed
	 push edx				;Save edx
         mov edx, offset arg1   ;Address of str to display should be in edx
         call WriteString       ;Display 0 terminated string
         pop edx				;Restore edx
ENDM

;*************************PROTOTYPES*****************************

ExitProcess PROTO, dwExitCode:DWORD  ;From Win32 api not Irvine to exit to dos with exit code

ReadChar PROTO                      ;Irvine code for getting a single char from keyboard
				    ;Character is stored in the al register.
			            ;Can be used to pause program execution until key is hit.

ReadHex PROTO                       ;Irvine code to read 32 bit hex number from console and store it into eax

WriteHex PROTO                      ;Irvine function to write a hex number in eax to the console
                                    ;Before calling WriteHex put the number to write into eax

WriteString PROTO                   ;Irvine function to write null-terminated string to the console
                                    ;edx contains the address of the string to write
                                    ;Before calling WriteString put the address of the string to write into edx
                                    ;e.g. mov edx, offset message
                                    ;address of message is copied to edx

WriteChar PROTO                     ;Irvine code for printing a single char to the console.
                                    ;Character to be printed must be in the al register.

RandomRange PROTO                   ;Returns an unsigned pseudo-random 32-bit integer in eax between 0 and n - 1.
                                    ;If n = Fh a random number in the range 0-Eh is generated.
                                    ;Input parameter: eax = n.
                                
Randomize PROTO                     ;Re-seeds the random number generator with the current time in seconds.
                    
;************************Constants********************************************************************************************
                                        
    ;Declare a constant LF to hold the ASCII value for a linefeed:
    LF             equ          0Ah                          ;A linefeed moves the cursor to the next line.
                                    
;************************DATA SEGMENT*****************************************************************************************
                                 
.data                            
                                
    strName        byte        "Program 3 by Shelby Heifetz", LF, LF, 0
    strPrompt      byte        "Guess a hex number in the range 1h - Fh.", LF, 0
    strInput       byte        "Guess: ", 0
    strHigh        byte        "High! (Guess lower)", LF, 0
    strLow         byte        "Low! (Guess higher)", LF, 0
    strWin         byte        "Correct!!", LF, LF, 0
    strEnd         byte        "Do another?('Y' or 'y' to continue. Any other character to exit)", LF, LF, 0
    num            dword       ?        ;Store the randomly generated number

;************************CODE SEGMENT******************************************************************************************
                                  
.code                             
                                  
main PROC                                
                                       
    mPrtStr strName            ;Print the string: "Program 3 by Shelby Heifetz"                                 
    call    Randomize          ;Seed the random number generator                              
                                
loop1Top:                      ;Enter the outer loop                     
    mPrtStr strPrompt          ;Print the string: "Guess a hex number in the range 1h - Fh."
                                 
    mov     eax, 0Fh           ;Range to generate random numbers 0-9
    call    RandomRange        ;Generate random number in range 0-9
                                                              
    inc     eax                ;Add 1 to the generated number (same as add eax, 1)
    mov     num, eax           ;num = eax (the generated number)     
                               
loop2Top:                      ;Enter the inner loop                               
    mPrtStr strInput           ;Print the string: "Guess: "
    call    readHex            ;Read hex number (user's guess)             
                               
    cmp     eax, num           ;Compare gu (the user's guess) to num (the generated number)                                
    jb      tooLow             ;If guess < num, jump to tooLow
    je      youWin             ;If guess = num, jump to youWin
                                   
tooHigh:                       ;Label for start of "too high" code block
    mPrtStr strHigh            ;Print the string: "High! (Guess lower)"
    jmp     loop2Top           ;Jump to loop2Top to repeat the loop
                               
tooLow:                        ;Label for start of "too low" code block
    mPrtStr strLow             ;Print the string: "Low! (Guess higher)"
    jmp     loop2Top           ;Jump to loop2Top to repeat the loop
                                
youWin:                        ;Label for start of "you win" code block
    mPrtStr strWin             ;Print the string: "Correct!!"  
    mPrtStr strEnd             ;Print the string: "Do another?('Y' or 'y' to continue. Any other character to exit)"
    call    readChar           ;Read character (user input to go again or quit)                          
    cmp     al, 'y'            ;Compare (is user input 'y'?)
    je      loop1Top           ;If al = 'y', jump to top of loop1Top (outer loop)
    cmp     al, 'Y'            ;Compare (is user input 'Y'?)
    je      loop1Top           ;If al = 'Y', jump to top of loop1Top (outer loop)
                                 
    INVOKE  ExitProcess, 0     ;Exit to dos: like C++ exit(0)

main ENDP
END main