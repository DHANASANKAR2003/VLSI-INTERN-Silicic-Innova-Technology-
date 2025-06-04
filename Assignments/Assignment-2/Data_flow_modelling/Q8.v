8. What will be displayed in the console mode for the below snippet? 

reg [13*8:1] s; 
initial begin 
    s = "hello world"; 
    $display("Value of s= %s", s[104:65]); 
end 

Answer: 

The variable s is declared as a 104-bit wide register (13 * 8 = 104 bits), indexed from bit 104 down to 1. 
The string "hello world" is 11 characters long, each character occupying 8 bits (1 byte), so it fits into bits [88:1] of s. The rest of the bits [104:89] are uninitialized or zeros. 

The expression s[104:65] extracts bits from 104 down to 65, which is 40 bits total (104 - 65 + 1 = 40). 
Since each ASCII character is 8 bits, 40 bits correspond to 5 characters. 
But the original string is stored from bits 88 downwards, so bits [104:89] are outside the string's defined range (most likely zeros), and bits [88:65] correspond to the first 3 characters of the string. 

Value of s= hel 
