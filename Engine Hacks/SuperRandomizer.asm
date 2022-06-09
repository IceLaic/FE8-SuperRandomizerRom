.thumb
.global	RunSuperRandomizer

@called from 080153B8
@r2 = chapter data pointer
.equ	Get_Char_Data,0x08019430
.equ	Get_Class_Data,0x08019444
.equ	Next_RN_N,0x08000C80
.equ	GetUnitByCharId,0x801829C
.equ	AutolevelUnitWeaponRanks,0x8017F20
.macro blh to, reg=r3
  ldr \reg, =\to
  mov lr, \reg
  .short 0xf800
.endm

push	{r14}
push	{r4-r7}
push	{r2}

@;EXISTING CODE. May be axed in favor of a different entry point... NOT ANYMORE HAHA
movs	r0,#0x0			@;load 0 into r0 (phase data)
strb	r0,[r2,#0x0F]	@;store phase data r0 (r2 contains chapter data)
ldrh	r1,[r2,#0x10]	@;load turn count into r1 (still r2)
ldr		r0,=#0x3E6		@;load 998d/3E6h into r0
cmp		r1,r0
bhi		SkipIncrement	@;compare r1>r0 and if turn count <= 998d (3E6h)
add		r0,r1,#1 		@;turn count (r1) ++ into r0
strh	r0,[r2,#0x10] 	@;store turn count (r0) (still referencing r2)

SkipIncrement:
ldr		r0,=#0x1		@;start with Seth and it's all downhill from there...
mov		r7,r0			@;we need this later I guess... this is the character index number

RandomizeNextCharacter:
blh		GetUnitByCharId	@;I think this one will be better? Let's find out lol
mov		r4,r0			@;r4 is unit data pointer

@;here we want to subtract the class bases from the character's stats
ldr		r6,[r4,#0x4]
add		r6,r6,#0x11		@;r6 = current class ptr plus class stat ptr
ldr		r0,=#0x14
add		r5,r4,r0		@;r5 = current unit ptr plus unit stat ptr
ldr		r1,=#0x0		@;r1 = 0

StatSubLoop:			@;do :
ldrb	r0,[r6,r1]		@;r0 = value from [class stat ptr(r6) plus r1]
ldrb	r2,[r5,r1]		@;r2 = value from [unit stat ptr(r5) plus r1]
sub		r0,r2,r0		@;r0 = r2 - r0
strb	r0,[r5,r1]		@;write value of r0 to [unit stat ptr(r5) plus r1]
add		r1,r1,#1		@;r1++
cmp		r1,#0x6
blt		StatSubLoop		@;while r1 < 6

ldr		r0,=#0x4A
blh		Next_RN_N
add		r0,r0,#1
cmp		r0,#0x0E		@;if greater than or equal to 0x0E, increment rn by one
blt		DoNotIncrement
add		r0,r0,#1
cmp		r0,#0x34		@;if greater than or equal to 0x34, increment rn by one
blt		DoNotIncrement
add		r0,r0,#1
cmp		r0,#0x3B		@;if greater than or equal to 0x3B, increment rn by two
blt		DoNotIncrement
add		r0,r0,#2

DoNotIncrement:
mov		r5,r0			@;r5 is class index
blh		Get_Class_Data
mov		r6,r0			@;r6 is class data pointer
strh	r6,[r4,#0x04]	@;store class pointer data we generated into the class pointer data of this character
ldr		r1,=0x0			@;zero out the value of r1 for use as a weapon type index

SetWeaponRank:
ldr		r0,=#0x2C
add		r0,r1,r0
ldrb	r5,[r6,r0]		@;load into r5 the value of the weapon rank of the class
ldr		r0,=#0x28
add		r0,r1,r0
strb	r5,[r4,r0]		@;store the weapon rank into the weapon rank of the character
add		r1,r1,#1
cmp		r1,#0x8
blt		SetWeaponRank

@;and here we want to add the new class bases to the character's stats
ldr		r6,[r4,#0x4]
add		r6,r6,#0x11		@;r6 = current class ptr plus class stat ptr
ldr		r0,=#0x14
add		r5,r4,r0		@;r5 = current unit ptr plus unit stat ptr
ldr		r1,=#0x0		@;r1 = 0

StatAddLoop:			@;do :
ldrb	r0,[r6,r1]		@;r0 = value from [class stat ptr(r6) plus r1]
ldrb	r2,[r5,r1]		@;r2 = value from [unit stat ptr(r5) plus r1]
add		r0,r2,r0		@;r0 = r2 - r0
strb	r0,[r5,r1]		@;write value of r0 to [unit stat ptr(r5) plus r1]
add		r1,r1,#1		@;r1++
cmp		r1,#0x6
blt		StatAddLoop		@;while r1 < 6

@;Exit the goddamn loop and finish this shit off
add		r7,r7,#1		@;here is where we needed that damn character index number
mov		r0,r7
cmp		r0,#0x23
blt		RandomizeNextCharacter

ExitFunction:
pop		{r2}
pop		{r4-r7}
pop		{r0}
bx		r0
