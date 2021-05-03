# Assembly Calculator
### Step by step calculator with 6 operations
The calculator shows step by step of solving through the input. Supports the following operations:
Summation`+`, Subtraction`-`, Multiplication`*`, Division`/`, Power`^` and Logarithm`\`.

Every operation must be in a parenthesis; So in every parenthesis, there's at most one operation.
You can use the previous answer by character 'a' or 'A'.
Use the dollar sign character `$` to quit the calculator.

### Operation symbols
1. `A+B`: `A` plus `B`
1. `A-B`: `A` minus `B`
1. `A*B`: `A` times `B`
1. `A/B`: `A` divided by `B`
1. `A^B`: `A` to the power of `B`
1. `A\B`: Logarithm of `A` in base `B`

### Compile & Run
To compile and run, execute the command `nasm -f elf64 ./a.asm && ld -o ./a -e _start ./a.o&& ./a`

### Input sample:

1. `((4*5)^2)`
1. `((a\2)^((3+4)/2))`
1. `(((-3)^a)*-1)`
1. `$`
