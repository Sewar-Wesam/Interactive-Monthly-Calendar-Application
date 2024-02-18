#Title : Interactive Monthly Calendar Application 
#Author: Sewar AbuEid 1200043             Rahaf Naser 1201319
#Description: MIPS code for viewing, editing and managing appointments within monthly calendar 
#Input: Calendar with its slots in a text file 
#Output: user-friendly interface to interact with the calendar functionality 

################ data segment ########################
.data
myFile: .asciiz  "C:\\FirstArchProject\\file.txt" 
buffer: .space  1024 
line: .asciiz "\n---------------------------------------------------------------------------\n" 
Welcome: .asciiz "\n Welcome to our interactive Calendar ! \n"
Menu: .asciiz "\nPlease Choose one of the following functionalities : \n1.View the Calendar \n2.View Statistics\n3.Add new appointment\n4.Delete an appointment\n5.Exit from the program\n"
View_Calendar: .asciiz "\n1.Calendar per day\n2.Calendar per set of days\n3.Calendar for a given slot in a given day\n4.Back to main Menu\n" 
daily_Calendar: .asciiz "\n Enter the number of the day that you want it's calendar\n" 
NumberOf_set_Days: .asciiz "\n How many days you want to print their Calendar?\n" 
Slot1: .asciiz "\nEnter the start time for the slot\n" 
Slot2: .asciiz "\nEnter the end time for the slot\n"  
proper1: .asciiz "\nThe Calendar of this day is \n" 
invalidInput: .asciiz "\n Invalid input! \n" 
Found: .asciiz  "\n The day is found ......................................\n"  
Statistics:"\n<<<<<<<<<<<<<<<<< Calendar Statistics >>>>>>>>>>>>>>> \n"
TotalLectures: .asciiz "\nThe Total Lectures Hours : \n" 
TotalOH: .asciiz "\nThe Total Office hours  : \n"  
TotalMeetings: .asciiz "\nThe Total Meetings Hours : \n"  
LectureAvg: .asciiz "\nAverage Lectures per day: \n" 
Ratio: .asciiz "\nThe Ratio between the Hours of Lectures and OH : \n" 
DayNumber: .asciiz "\nEnter the number of the day of your appointment:\n"  
appointmentStart: .asciiz  "\nEnter the start time of your appointment:\n"  
appointmentEnd: .asciiz "\nEnter the End time of your appointment:\n" 
Type: .asciiz "\nEnter the type of your appointment:\n"  
day_prompt_message: .asciiz "Enter the day number to delete appointment from: "
prompt_message : .asciiz "Enter the type of slot: "
user_input_buffer: .space 20   # Assuming a buffer size of 20 bytes for user input 
Confilct_Message: .asciiz "Sorry ! There is a conflict " 
NoConflictCounter: .byte 0 
Appointment_Added: .asciiz "\nThe appointment Has been Added\n" 
AppointmentType: .byte ' '
NewDay: .asciiz "\n The Day You need to add your appointment to it is already empty, So happy to say : No Conflict \n"
################ code segment ########################
 .text 
 .globl  main 
 main: 
 # print the welcome statement 
 la $a0,Welcome
 li $v0,4
 syscall
 
 
#open a file  to read calendar from 
li	$v0, 13		#open  file syscall , service number 13
la	$a0, myFile	# board file name
li	$a1, 0		# Open for reading
li	$a2, 0
syscall			# open a file (file descriptor returned in $v0)
move	$s2, $v0		# save the file descriptor  

#Now ,read from the file
li	$v0, 14		# read from file syscall , service number 14
move	$a0, $s2		# file descriptor 
la	$a1, buffer	# address of the stored file content that will be readed 
li	$a2, 1024	        # hardcoded buffer length
syscall			

# print to the file content to test  
la $a0, buffer
li $v0, 4  
syscall    

#close file
li $v0,16
move $a0,$s2
syscall




la $a0,line
li $v0,4
syscall 

j Main_Menu 
Main_Menu:
la $a0,Menu
li $v0,4
syscall 

#Get the user choice 
li $v0,5  # syscall to prompt the user
syscall 
       
#Store the result in $t0 
move $t0,$v0 
#Now, we want to handle the user choice to navigate through the menu
beq $t0,1 view_Calendar  
beq $t0,2 view_Statistics
beq $t0,3 Add_New_Appointment 
beq $t0,4 delete_appointment
beq $t0,5 exit_from_program

view_Calendar: 
la $a0,View_Calendar
li $v0,4
syscall    
#Get the user choice 
li $v0,5  # syscall to prompt the user
syscall   
move $t0,$v0
### handle view calendar choices 
beq $t0,1 CalendarDay
beq $t0,2 setOfDays
beq $t0,3 slot_in_day
beq $t0,4 Main_Menu


CalendarDay: 
la $a0,daily_Calendar
li $v0,4
syscall    
#take the specific day number from the user 
li $v0,5  # syscall to prompt the user
syscall    
move $t0,$v0       #$t0 contains the day number  
####### Now we will read the buffer line by line and extract the first digit in each line 
#initialize the pointer
# Load the address of the input string
   la $a0, buffer
   move $t1, $a0      # $t1 will point to the current character
 loop: 
 lb $t2,0($t1)            #$t2 contains the current character in the buffer
  beq $t2,':',previous_position          # 58 is the ASCII of the :  
  beq $t2,0,EOF 
  comp:
  addi $t1,$t1,1
  j loop
 
  previous_position:  
  subi $t5,$t1,2            # back $t1 to the previous position 
  lb $t3,0($t5)         # the day number now is in $t3  
   lb $t4,1($t5) 
  # convert the value from characters to integers 
 sub $t3, $t3, '0' 
 sub $t4, $t4, '0'
# concatenating the two digits by multiply with 10 then adding 
   mul $t3,$t3,10 
  add $t3,$t3,$t4          #our ready day number now in $t3 as integer 
  addi $t6,$t1,0            # $t6 now points to the current character 
  move $t7,$t2              # $t7 contains the current character,, these two registers will  be used in the printing line process 
 beq $t3,$t0,properMessage
   j comp
 printline:   
 lb $t7,0($t6)   
 bne $t7,'\n',print
 j comp
 print:
 move $a0,$t7
 li $v0,11 
 syscall 
 addi $t6,$t6,1
 j printline
 
EOF:
############################################################
#after finish this task, print a day calendar , back to General view calendar Menu 

j view_Calendar 

setOfDays:
# ask the user about the number of days s/he wants to ask about
la $a0,NumberOf_set_Days
li $v0,4
syscall      
li $v0,5  # syscall to prompt the user
syscall   
# store the number of days 
move $t1,$v0                # Now, $t1 contains the number of elements (Days) in the set 
###### while loop to ask the user to enter the number of days frequently 
addi $s0,$zero,0         # $s0 contains the loop controller like i=0 in highlevel languages 
while: 
bge $s0,$t1,exit 
la $a0,daily_Calendar                    # ask the user to enter the day number
li $v0,4
syscall    
# take the day number from the user
li $v0,5  # syscall to prompt the user
syscall   
move $t0,$v0       #$t0 contains the day number  
############### searching in the buffer iterate start################ 

#initialize the pointer
# Load the address of the input string
 la $a0, buffer
 move $t2, $a0       # $t2 will point to the current character 
 
 Innerloop: 
 lb $t3,0($t2)            #$t2 contains the current character in the buffer 
  beq $t3,':',previous_position_v2          
  beq $t3,0,InnerEOF     #to increment the value of $s0 and start with the following day 
  Innercomp:          # this label to read the next letter in the buffer
  addi $t2,$t2,1
  j Innerloop 
  
  previous_position_v2:  
  subi $t6,$t2,2            # back $t1 to the previous position 
  lb $t4,0($t6)         # the day number now is in $t3  
   lb $t5,1($t6) 
  # convert the value from characters to integers 
 sub $t4, $t4, '0' 
 sub $t5, $t5, '0'
# concatenating the two digits by multiply with 10 then adding 
   mul $t4,$t4,10 
  add $t4,$t4,$t5          #our ready day number now in $t3 as integer 
  addi $t7,$t2,0            # $t6 now points to the current character 
  move $t8,$t3             # $t7 contains the current character,, these two registers will  be used in the printing line process  
  beq $t4,$t0,properMessage2 
   j Innercomp
  
  printline2:   
 lb $t8,0($t7)   
 bne $t8,'\n',print2
 j Innercomp
 print2:
 move $a0,$t8
 li $v0,11 
 syscall 
 addi $t7,$t7,1
 j printline2
 
############### The first iterate end ###################### 
InnerEOF:
addi $s0,$s0,1               # like i++ in high level languages  when finish the first day iterate, now the next day from the user to repeat
j while
exit:
# at the end of  print set of days calendar task , back to General view calendar Menu
j view_Calendar 

################# view calendar for specific day ###########################
slot_in_day:  
# take the slot information from the user
la $a0,Slot1     # the start time of the slot
li $v0,4
syscall     

li $v0,5  # syscall to prompt the user
syscall    
move $t1,$v0    # $t1 contains the start time of the slot  
beq $t1,5,invalid      # less than 8
beq $t1,6,invalid       # less than 8
beq $t1,7,invalid       # less than 8
bgt $t1,12,invalid      # not in the 12hour rate    
beq $t1,1,add12ToStart
beq $t1,2,add12ToStart  
beq $t1,3,add12ToStart 
beq $t1,4,add12ToStart  
beq $t1,5,add12ToStart 
readyStartSlot: 

la $a0,Slot2     # the End time of the slot
li $v0,4
syscall    
li $v0,5  # syscall to prompt the user
syscall    
move $t2,$v0    # $t2 contains the End time of the slot   
beq $t2,6,invalidEnd      # greater than 5
beq $t2,7,invalidEnd      # greater than 5
bgt $t2,12,invalidEnd   # not in the 12hour rate    

#addi $t2,$t2,12                 # to be able for compare when check the range of slot  
beq $t2,1,add12ToEnd
beq $t2,2,add12ToEnd  
beq $t2,3,add12ToEnd 
beq $t2,4,add12ToEnd  
beq $t2,5,add12ToEnd 
readyEndSlot:
# ask the user to enter the specific day for the given slot 
la $a0,daily_Calendar    # the Day of the slot
li $v0,4
syscall    
li $v0,5  # syscall to prompt the user
syscall      
move $t3,$v0    # $t3 contains the Day of the slot   
########### searching  for the day of the slot in the buffer #############
#initialize the pointer
# Load the address of the input string
 la $a0, buffer
move $s1, $a0      # $s1 will point to the current character 

loop3: 
 lb $s2,0($s1)            #$t2 contains the current character in the buffer
  beq $s2,':',previous_position_v3         # 58 is the ASCII of the :  
  beq $s2,0,EOF3
  comp3:
  addi $s1,$s1,1
  j loop3 
  
  previous_position_v3:  
  subi $s5,$s1,2            # back $t1 to the previous position 
  lb $s3,0($s5)         # the day number now is in $t3  
   lb $s4,1($s5) 
  # convert the value from characters to integers 
 sub $s3, $s3, '0' 
 sub $s4, $s4, '0'
# concatenating the two digits by multiply with 10 then adding 
   mul $s3,$s3,10 
  add $s3,$s3,$s4          #our ready day number now in $s3 as integer 
  addi $s6,$s1,0            # $s6 now points to the current character 
  move $s7,$s2              # $s7 contains the current character,, these two registers will  be used in the printing line process 
 beq $s3,$t3,LineFounded           # The rest of the work will be at the LineFounded  Label
   j comp3

############### The End fo Calendar slot

invalid:  
la $a0,invalidInput          # print the invalid input message and return to prompt the user again
li $v0,4
syscall  
j slot_in_day 

invalidEnd:  
la $a0,invalidInput          # print the invalid input message and return to prompt the user again
li $v0,4
syscall  
j readyStartSlot

EOF3:
#after finish the last task (for specific slot), Back to general view calendar
j view_Calendar 
########################### The End Of View Calendar functionality#################

properMessage: 
la $a0,proper1
li $v0,4
syscall
j printline 

properMessage2: 
la $a0,proper1
li $v0,4
syscall
j printline2

LineFounded: 
la $a0,Found
li $v0,4 
syscall  
comp4: 
 lb $s2,0($s1)   
beq $s2,'\n',EOF3       # if we arrive to the end of line 
###### Now we will iterate through the line and print the slot  

# Check if the readed character is digit , if yes check slot bounds, if not print it 
li  $t4,48         # The ASCII number for '0' 
li $t5,57          # Tje ASCII number for '9'
blt $s2,$t4,printdigit 
bgt $s2,$t5,printdigit 
###################### if the content of $s2 is number ######################
# copy the content of $s2 to $t8 
move $t8,$s2 
#convert the content of $t8 to integer 
sub $t8,$t8,'0' 
# check the next character if it is also number  
lb $t9,1($s1) 
bge $t9,$t4,ZeroOrMore  
beq $t9,45,OneDigit            # if the next character is the hyphen
j printdigit
TwoDigits: 
# The content of $t9 is integer
# concatinate $t8 with $t9
mul $t8,$t8,10  
sub $t9,$t9,'0'
add $t8,$t8,$t9
addi $s1,$s1,1      # to skip the character was taken   
printingCheck:
bge $t8,$t1,firstCheckDone
j continue_printing

OneDigit: 
beq $t8,1,add12 
beq $t8,2,add12  
beq $t8,3,add12 
beq $t8,4,add12  
beq $t8,5,add12 
j printingCheck           # to check if it with in the slot range

continue_printing:
addi $s1,$s1,1
j comp4 

printdigit: 
move $a0,$s2
li $v0,11
syscall 
j  continue_printing   

printInt: 
bgt $t8,12,Sub12 
cont:
move $a0,$t8
li $v0,1
syscall 
j  continue_printing  

ZeroOrMore: 
ble $t9,$t5,TwoDigits 
j OneDigit

firstCheckDone:
ble $t8,$t2,printInt 
j EOF3 

Sub12:
subi $t8,$t8,12
j cont 

add12: 
addi $t8,$t8,12
j printingCheck 

add12ToEnd: 
addi $t2,$t2,12
j readyEndSlot  

add12ToStart: 
addi $t1,$t1,12
j readyStartSlot 

################### The Second Option (View Statistics) #################### 
view_Statistics:
# Define counters for the number of 'L's and 'OH's and 'M's
  li $s0, 0              # $s0 contatins the summation of lectures in hours initialize by zero
  li $s1, 0              # $s1contatins the summation of offic hours in hours initialize by zero
  li $s2, 0               # $s2 contatins the summation of meetings in hours initialize by zero
  li $a2,1               # initialize the counter of the lines to zero
# initializ buffer 
 la $a0, buffer
  move $t1, $a0
# Loop to iterate through each line in the buffer 
Loop:
    lb $t2, 0($t1)       # Load current character
    beq $t2,0, EndLoop  # Check for end of file 
    beq $t2, 'L', CountLecture
    beq $t2, 'O', CountOH
    beq $t2,'\n',LineCounter
    j  ContinueLoop
    #################### count the lecture hours ######################## 
 LineCounter:  
  addi $a2,$a2,1  # Increment $f0 by $f1
    j  ContinueLoop  
    
 CountLecture:
  # Extract end time
    subi $t5, $t1, 1     # Move back one character 
    lb $t6, 0($t5)       # Load the end time   
    sub $t6, $t6, '0'    # Convert character to integer  
    subi $t8,$t1,2        # move back two digits
    lb $t7, 0($t8)       # Load the end time 
    
    # check the value in $t7  
    blt $t7,48,onedigit 
    bgt $t7,57,onedigit  
    # The end time is two digits  
    sub $t7, $t7, '0'    # Convert character to integer  
    mul $t7,$t7,10 
    add $t6,$t6,$t7       # Now the end time is in $t6 (Two digits) 
    j  startWithTwoDigits         # to calculate the start time when the end time is two digits
    
    onedigit: 
    beq $t6,1,Add_12 
    beq $t6,2,Add_12  
    beq $t6,3,Add_12 
    beq $t6,4,Add_12 
    beq $t6,5,Add_12 
    j StartWithOneDigit        # to calculate the start time when the end time is one digit
    
    StartWithOneDigit: 
     # the end time is one digit , we want to calculate the start time now  
    # Extract start time
    subi $t3, $t1, 3     # Move back three characters
    lb $t4, 0($t3)       # Load the first digit of start time
    sub $t4, $t4, '0'    # Convert character to integer 
    subi $t5, $t1, 4     # Move back  four characters 
     lb $s5, 0($t5)       # Load the first digit of start time
    blt $s5,48,calculateLectureTime    
    bgt $s5,57,calculateLectureTime  
    # The start time is two digit 
     sub $s5, $s5, '0'    # Convert character to integer  
     mul $s5,$s5,10 
     add $t4,$t4,$s5 
     j     calculateLectureTime
    
    startWithTwoDigits: 
    # the end time is two digits , we want to calculate the start time now  
    subi $t3, $t1, 4     # Move back three characters
     lb $t4, 0($t3)       # Load the first digit of start time
     sub $t4, $t4, '0'    # Convert character to integer  
     subi $t5, $t1, 5     # Move back  four characters 
     lb $s5, 0($t5)       # Load the first digit of start time 
     blt $s5,48,calculateLectureTime  # Case2: the end time two digits and the start time one digit
    bgt $s5,57,calculateLectureTime     # Case2: the end time two digits and the start time one digit 
    # the start and the end time are both two digits 
    sub $s5, $s5, '0'    # Convert character to integer   
    mul $s5,$s5,10     
     add $t4,$t4,$s5 
     j  calculateLectureTime 
     
     calculateLectureTime:  
     beq $t4,1,add12ToStartingL 
     beq $t4,2,add12ToStartingL
    beq $t4,3,add12ToStartingL
    beq $t4,4,add12ToStartingL

continueCalculatingL:
     
     sub $t6, $t6, $t4    # Calculate lecture duration 
     add $s0, $s0, $t6    # Add the duration to the counter for 'L's 
     j ContinueLoop
     
   ContinueLoop:
    addi $t1, $t1, 1    # Move to the next character
    j Loop
################################# The end of counting lecture hours #################### 
######## Count the office hours 
CountOH: 
# Extract end time
  subi $t5, $t1, 1     # Move back one character 
  lb $s6, 0($t5)       # Load the end time   
   sub $s6, $s6, '0'    # Convert character to integer  
   subi $s7,$t1,2        # move back two digits
    lb $a1, 0($s7)       # Load the end time 
    
    # check the value in $t7  
    blt $a1,48,onedigitOH 
    bgt $a1,57,onedigitOH 
     # The end time is two digits  
    sub $a1, $a1, '0'    # Convert character to integer  
    mul $a1,$a1,10 
    add $s6,$s6,$a1      # Now the end time is in $s6 (Two digits) 
    j  startWithTwoDigitsOH         # to calculate the start time when the end time is two digits 
    
    onedigitOH: 
# end time is one digit
    beq $s6,1,Add_12_OH          # $s6 contains the end time of the office hour slot
    beq $s6,2,Add_12_OH
    beq $s6,3,Add_12_OH
    beq $s6,4,Add_12_OH
    beq $s6,5,Add_12_OH
    j StartWithOneDigit_OH       # to calculate the start time when the end time is one digit
    
    startWithTwoDigitsOH: 
    # the end time is two digits , we want to calculate the start time now  
    subi $s3, $t1, 4     # Move back  four characters
     lb $s4, 0($s3)       # Load the first digit of start time
     sub $s4, $s4, '0'    # Convert character to integer  
     subi $t9, $t1, 5     # Move back  five characters 
     lb $a3, 0($t9)       # Load the first digit of start time 
     blt $a3,48,calculateOHTime  # Case2: the end time two digits and the start time one digit
    bgt $a3,57,calculateOHTime     # Case2: the end time two digits and the start time one digit 
    # the start and the end time are both two digits 
    sub $a3, $a3, '0'    # Convert character to integer   
    #combine the two digits in one 
    mul $a3,$a3,10     
     add $s4,$s4,$a3         
     j  calculateOHTime 

StartWithOneDigit_OH: 
# now we will find the start time when the end time is one digit 
    
    # Extract start time
    subi $s3, $t1, 3     # Move back three characters
    lb $s4, 0($s3)       # Load the first digit of start time
    sub $s4, $s4, '0'    # Convert character to integer 
    subi $t9, $t1, 4     # Move back  four characters 
     lb $a3, 0($t9)       # Load the first digit of start time
    blt $a3,48,calculateOHTime    
    bgt $a3,57,calculateOHTime  
    # The start time is two digit 
     sub $a3, $a3, '0'    # Convert character to integer  
     mul $a3,$a3,10 
     add $s4,$s4,$a3
     j     calculateOHTime 
   
calculateOHTime:    
# in the case that the start time is one digit and  its :1,2,3,4 it should be added to 12
beq $s4,1,add12ToStarting 
beq $s4,2,add12ToStarting 
beq $s4,3,add12ToStarting 
beq $s4,4,add12ToStarting 

continueCalculating:
 sub $s6, $s6, $s4    # Calculate Office Hour duration 
 add $s1, $s1, $s6    # Add the duration to the counter for 'OH's 
  j ContinueLoop 
###################################################
 EndLoop: 
 #### Print the results: 
 la $a0,Statistics 
 li $v0,4
 syscall
  # Print the total number of 'L's found 
  la $a0,TotalLectures
 li $v0,4
 syscall 
 
  li $v0, 1         
  move $a0, $s0     
  syscall

la $a0,line
li $v0,4
syscall 

  # Print the total number of 'OH's found 
  la $a0,TotalOH 
  li $v0,4
  syscall
  
  li $v0, 1         
  move $a0, $s1     
  syscall

la $a0,line
li $v0,4
syscall 
############## Print the avarage and the ratio ##################### 

###############avarage########## 
la $a0,LectureAvg 
li $v0,4
syscall 
    
    # Convert integers to single precision floating-point
    mtc1 $s0, $f0   # Load integer in $s0 to $f0 (dividend)
    mtc1 $a2, $f4   # Load integer in $a2 to $f1 (divisor)

    # Divide $f0 by $f1, result in $f2
    div.s $f2, $f0, $f4

   
    # Print the result in $f2
    li $v0, 2
    mov.s $f12, $f2
    syscall  
    ################## 
    la $a0,line
li $v0,4
syscall 
    
    ########## print the ratio####################  
    la $a0,Ratio 
li $v0,4
syscall 
    
     # Convert integers to single precision floating-point
    mtc1 $s0, $f0   # Load integer in $s0 to $f0 (dividend)
    mtc1 $s1, $f4   # Load integer in $a2 to $f1 (divisor)

    # Divide $f0 by $f1, result in $f2
    div.s $f2, $f0, $f4

   
    # Print the result in $f2
    li $v0, 2
    mov.s $f12, $f2
    syscall 
 
#################################

la $a0,line
li $v0,4
syscall 


# Now, instead of printing the number of Meetings Here, we will start from zero to use registers again
j NewBeginning 

NewBeginning:           # to calculate the number of Meetings Hours 
# clean the registers contents to use them again  
li $a0,0 
li $t1,0 
li $t2,0 
li $t5,0 
li $t6,0 
li $t8,0 
li $t7,0 
li $t3,0 
li $t4,0 
li $s5,0  
# the registers have be cleaned and ready to start the new mission  

# Now initialize the buffer
la $a0, buffer
 move $t1, $a0 
  LoopM:
    lb $t2, 0($t1)       # Load current character
    beq $t2,0, EndLoopM  # Check for end of file   
    beq $t2, 'M', CountM 
    j  ContinueLoopM
    
   CountM:
  # Extract end time
    subi $t5, $t1, 1     # Move back one character 
    lb $t6, 0($t5)       # Load the end time   
    sub $t6, $t6, '0'    # Convert character to integer  
    subi $t8,$t1,2        # move back two digits
    lb $t7, 0($t8)       # Load the end time 
    
    # check the value in $t7  
    blt $t7,48,onedigitM
    bgt $t7,57,onedigitM 
    
    # The end time is two digits  
    sub $t7, $t7, '0'    # Convert character to integer  
    mul $t7,$t7,10 
    add $t6,$t6,$t7       # Now the end time is in $t6 (Two digits) 
    j  startWithTwoDigitsM       # to calculate the start time when the end time is two digits
    
    
      onedigitM: 
    beq $t6,1,Add_12M
    beq $t6,2,Add_12M
    beq $t6,3,Add_12M
    beq $t6,4,Add_12M
    beq $t6,5,Add_12M
    j StartWithOneDigitM       # to calculate the start time when the end time is one digit 
    
    StartWithOneDigitM: 
     # the end time is one digit , we want to calculate the start time now  
    # Extract start time
    subi $t3, $t1, 3     # Move back three characters
    lb $t4, 0($t3)       # Load the first digit of start time
    sub $t4, $t4, '0'    # Convert character to integer 
    subi $t5, $t1, 4     # Move back  four characters 
     lb $s5, 0($t5)       # Load the first digit of start time
    blt $s5,48,calculateLectureTimeM
    bgt $s5,57,calculateLectureTimeM  
    # The start time is two digit 
     sub $s5, $s5, '0'    # Convert character to integer  
     mul $s5,$s5,10 
     add $t4,$t4,$s5 
     j  calculateLectureTimeM
    
    startWithTwoDigitsM: 
    # the end time is two digits , we want to calculate the start time now  
    subi $t3, $t1, 4     # Move back  four characters
     lb $t4, 0($t3)       # Load the first digit of start time
     sub $t4, $t4, '0'    # Convert character to integer  
     subi $t5, $t1, 5     # Move back  five characters 
     lb $s5, 0($t5)       # Load the first digit of start time 
     blt $s5,48,calculateLectureTimeM  # Case2: the end time two digits and the start time one digit
    bgt $s5,57,calculateLectureTimeM     # Case2: the end time two digits and the start time one digit 
    # the start and the end time are both two digits 
    sub $s5, $s5, '0'    # Convert character to integer   
    mul $s5,$s5,10     
     add $t4,$t4,$s5 
     j  calculateLectureTimeM 
     
     calculateLectureTimeM:  
     beq $t4,1,add12ToStartingM
    beq $t4,2,add12ToStartingM
    beq $t4,3,add12ToStartingM
    beq $t4,4,add12ToStartingM

continueCalculatingM:
     sub $t6, $t6, $t4    # Calculate Meeting duration 
     add $s2, $s2, $t6    # Add the duration to the counter for 'M's 
     j ContinueLoopM
     
    ContinueLoopM:
    addi $t1, $t1, 1    # Move to the next character
    j LoopM 
    
EndLoopM: 
  # Print the total number of 'M's found 
  la $a0,TotalMeetings 
  li $v0,4
  syscall
  
  li $v0,1         
  move $a0, $s2    
  syscall
j  EOF3         # back to print the menu
  
# add 12 to the end time of the slot if needed   (1<=$t6<=5)
Add_12 : 
addi $t6,$t6,12 
j StartWithOneDigit 

# add 12 to the end time of the slot if needed   (1<=$s6<=5)
Add_12_OH:  
addi $s6,$s6,12 
j StartWithOneDigit_OH

# add 12 to the start time of the slot of OH  if needed   (1<=$s4<=4)
add12ToStarting: 
addi $s4,$s4,12
j  continueCalculating 

# add 12 to the start time of the slot of L  if needed   (1<=$t4<=4)
add12ToStartingL: 
addi $t4,$t4,12
j  continueCalculatingL 

# add 12 to the end time of the slot of M  if needed   (1<=$t4<=5)
Add_12M: 
addi $t6,$t6,12 
j StartWithOneDigitM 

# add 12 to the start time of the slot of M  if needed   (1<=$t4<=4)
add12ToStartingM: 
addi $t4,$t4,12
j  continueCalculatingM  




###################### Add New Appointment ############################## 
Add_New_Appointment:  
li $t1,0      # clean the value of the register 
li $s0,0     # clean the value of  the register  
li $s1,0     # clean the value of  the register 
li $s2,0     # clean the value of the register
li $s3,0      # clean the value of the register
li $s4,0       # clean the value of the register
li $s5,0       # clean the value of the register
li $s6,0        # clean the value of the register
li $s7,0         # clean the value of the register
li $t0,0          # clean the value of the register
li $t2,0         # clean the value of the register
li $t3,0         # clean the value of the register
li $t4,0         # clean the value of the register
li $t5,0           # clean the value of the register
li $t6,0          # clean the value of the register
li $t7,0      # set the value of the register to 1 to catch the non found day. 
li $t8,0           # clean the value of the register
li $t9,0            # clean the value of the register
li $a3,0          # clean the value of the register
li $a2,0            # clean the value of the register 
li $a1,0            # clean the value of the register 

# ask the user to Enter the number of the day
la $a0,DayNumber
li $v0,4 
syscall 

li $v0,5  # syscall to prompt the user
syscall 
move $t1,$v0    # $t1 contains the day number to add the appointment in 

# ask the user to enter the start time of the appointment  
checkStarted:
la $a0,appointmentStart
li $v0,4
syscall  

li $v0,5# syscall to prompt the user
syscall    

move $s0,$v0    # $s0 contains the start time of the appointment  

# check if the start time is valid 
beq $s0,5,InvalidStart
beq $s0,6,InvalidStart
beq $s0,7,InvalidStart  
bgt $s0,12,InvalidStart 
# so the start time now is valid, and stored in $s0
# Now if the start time is 1 or 2 or 3 or 4 should be added to 12 
beq $s0,1,Addition_12
beq $s0,2,Addition_12 
beq $s0,3,Addition_12 
beq $s0,4,Addition_12 

startTimeConvertedTo24_Sys: 

####### The appointment start time Now is ready and checked under all tests 

# ask the user to enter the End time of the appointment   
checkEnd:
la $a0,appointmentEnd
li $v0,4
syscall  

li $v0,5  # syscall to prompt the user
syscall   
move $s1,$v0    # $s1 contains the End time of the appointment
 
# Now, check if the appointment end time is valid or not  
beq $s1,6,InvalidEnd
beq $s1,7,InvalidEnd 
beq $s1,8,InvalidEnd 
bgt $s1,12,InvalidEnd 

# Now , if the End time is 1 or 2 or 3 or 4 or 5 should be converted to 24-hour system  
beq $s1,1,Addition12ToEnd 
beq $s1,2,Addition12ToEnd  
beq $s1,3,Addition12ToEnd  
beq $s1,4,Addition12ToEnd  
beq $s1,5,Addition12ToEnd  

endTimeConvertedTo24_Sys: 
# Now the end time is ready and checked under all tests  

# ask the user to enter the type of the appointment
la $a0,Type
li $v0,4
syscall  

li $v0,12
syscall 
la $s2,AppointmentType
#move $s2,$v0  
sb $v0,AppointmentType

# the appointment type is in $s2


### Now start read the file line by line until find the appointment day 
# initializ buffer 
 la $a0, buffer
  move $t0, $a0
# Loop to iterate through each line in the buffer 
Appoint_Loop:
     
    lb $t2, 0($t0)       # Load current character 
    beq $t2,':',DayNumber2
    beq $t2,0,EOF4
    j compLoop 
    
compLoop: 
addi $t0,$t0,1 
j Appoint_Loop 


EOF4:  
j Main_Menu  


la $a0,Appointment_Added 
li $v0,4
syscall 
#### print the appointment to unexist day 

j Main_Menu  
DayNumber2: 

subi $t3,$t0,2            # back $t1 to the previous position 
  lb $t4,0($t3)         # the day number now is in $t3  
   lb $t5,1($t3) 
  # convert the value from characters to integers 
 sub $t4, $t4, '0' 
 sub $t5, $t5, '0'
# concatenating the two digits by multiply with 10 then adding 
   mul $t4,$t4,10 
  add $t4,$t4,$t5          #our ready day number now in $t3 as integer 
  
  # if the day founded :
  beq $t1,$t4,DayFounded 
  addi $t7,$t7,1
   j compLoop 

DayFounded:  
li $t4,0  
li $t7,0   # clean it because it was a counter 
move $t6,$t0 
# count the HYPHENS 
countHyphen: 
lb $t7,0($t6)  
beq $t7,'-',incCount    
beq $t7,'\n',contLine    
contH:
addi $t6,$t6,1 
j countHyphen
################## the end of hyphen counting 
contLine:
move $t6,$t0 
li $t7,0

foundDay2:  
lb $t7,0($t6) 
beq $t7,'\n',compLoop 
beq $t7,'-',HyphenFound  
 
 cont4:
addi $t6,$t6,1 
j foundDay2


HyphenFound: 
li $t7,0 
move $t8,$t6      # current position in t8  
subi $s5,$t8,1    # previous position 
lb $t9,0($s5)      # contains the digit before hyphen  
subi $t9,$t9,'0'   # convert to integer 
subi $s4,$t8,2   # previous position   
lb $s3,0($s4) 
bge $s3,48,GTZ       # Greater Than Zero or equal


 
OneDigitApp:
#### one digit OneDigitApp: 
beq $t9,1,Add12App
beq $t9,2,Add12App
beq $t9,3,Add12App
beq $t9,4,Add12App 
continueAppStart: 
# Now the start of the slot is in $t9  
# Now, we will work to find the End Time 

addi $s6,$t8,1    # next position 
lb $s7,0($s6)      # contains the digit after hyphen  
subi $s7,$s7,'0'   # convert to integer 
addi $a3,$t8,2   # next next position   
lb $a2,0($a3)  
bge $a2,48,GTZ2     

OneDigitEndApp: 
beq $s7,1,Add12EndApp
beq $s7,2,Add12EndApp
beq $s7,3,Add12EndApp
beq $s7,4,Add12EndApp  
beq $s7,5,Add12EndApp

continueAppEnd: 
 # Now , the slot end is in $s7  , and the start slot is in $t9 
 
 # The first Case of conflict is : if the appointment start equals the slot start 
 beq $t9,$s0,Conflict 
 # The Second Case of conflict is : if the appointment end  equals the slot end  
 beq $s7,$s1,Conflict   
 
 bgt $s0,$t9,MayConflict        # The Third  May Case of conflict is : if the start time of the appointment is greater than start of app
 blt $s1,$s7,MayConflict2        # The Third  May Case of conflict is : if the end time of the appointment is less than start of app
 
 NoConflict:  
 addi $a1,$a1,1         # increment the counter of the noConflicts 
# Now if the value of $a1 is 3 , the appointment will be added   
# value of start appointment $s0, end $s1, type $s2  

 beq $a1,$t4,findEndOfLine
 j cont4  
 
 findEndOfLine: 
 li $t9,0      # clean the value of the buffer 
 li $t8,0 
  li $s5,0   
  li $t1,0 
  li $s4,0 
  li $s3,0 
  li $t4,0 
  li $t5,0 
  li $t7,0  
  li $t8,0
  
 move $t8,$t6      # current position in t8  
addi $s5,$t8,1  
   
continueEndLine: 
lb $t9,0($s5)  # Load the character at the current position 
beq $t9,'\n',insertNewAppointment 

# print $t9 to check 
add  $s5,$s5,1
j  continueEndLine 


insertNewAppointment: 
li $t1, ','  # ASCII value of space 
OneDigitSure:
 sb $t1, 3($t6)
continueWritting:    
li $t3,'-' 
li $t5,'\n'    

beq $s0,12,writting_10 
beq $s0,10,writting_10  
beq $s0,11,writting_10  
 

# Now if the start appointment is 1,2,3,4 we will subtract 12 
beq $s0,13,subtraction12 
beq $s0,14,subtraction12  
beq $s0,15,subtraction12  
beq $s0,16,subtraction12  

checkEndAppointment:
# if the end appointment is 1,2,3,4,5 we will subtract 12 
 
beq $s1,13,subtraction12End 
beq $s1,14,subtraction12End 
beq $s1,15,subtraction12End  
beq $s1,16,subtraction12End   
beq $s1,17,subtraction12End 

ContPrintingAfterChecking: 
add $s0,$s0,'0' 
sb $s0,4($t6)  
sb $t3,5($t6) 
   
cont_print:
beq $s1,12,writting_10End
beq $s1,10,writting_10End 
beq $s1,11,writting_10End


add $s1,$s1,'0'
sb $s1,6($t6)


lb $a0,AppointmentType 
li $v0,11
syscall
sb $a0,7($t6)  
sb $t5,8($t6)  


la $a0,Appointment_Added
li $v0,4
syscall 

 j EOF4
 
                                           
 
writting_10End:   
li $s5,'1' 
subi $s1,$s1,10 
addi $s1,$s1,'0' 
sb $s5,6($t6)   
sb $s1,7($t6)    
lb $a0,AppointmentType 
li $v0,11
syscall
sb $a0,8($t6)  
sb $t5,9($t6)   

la $a0,Appointment_Added
li $v0,4
syscall 

 # Output buffer content after adding  for testing
   la $a0, buffer
   li $v0, 4
    syscall
 j EOF7
 

 
writting_10:
li $s4,'1' 
subi $s0,$s0,10 
addi $s0,$s0,'0' 
sb $s4,4($t6)   
sb $s0,5($t6)    
sb $t3,6($t6)     
## if the End is also 2 Digit 
beq $s1,12,writting_10EndV2
beq $s1,10,writting_10EndV2
beq $s1,11,writting_10EndV2

j cont_print  

writting_10EndV2:  
sb $t3,6($t6)    
li $s5,'1' 
subi $s1,$s1,10 
addi $s1,$s1,'0' 
sb $s5,7($t6)   
sb $s1,8($t6)   
  
lb $a0,AppointmentType 
li $v0,11
syscall
sb $a0,9($t6)   
sb $t5,10($t6) 


la $a0,Appointment_Added
li $v0,4
syscall 

 # Output buffer content after deletion for testing
   la $a0, buffer
   li $v0, 4
    syscall
 j EOF4



subtraction12: 
subi $s0,$s0,12  
j checkEndAppointment 

subtraction12End:  
subi $s1,$s1,12
j ContPrintingAfterChecking
 
 mayTwoDigit:  
 ble $s3,57,TwoDigitSure 
 j OneDigitSure 
 
 TwoDigitSure:
 sb $t1, 4($t6)
 j  continueWritting
 
TwoDigitEndApp:      
sub $a2,$a2,'0' 
mul $s7,$s7,10
add $s7,$a2,$s7 
j  continueAppEnd

MayConflict: 
blt $s1,$s7,Conflict  
blt $s0,$s7,Conflict
j NoConflict 

MayConflict2: 
bgt $s1,$t9,Conflict 
j NoConflict 


Conflict: 
la $a0,Confilct_Message 
li $v0,4
syscall
j  EOF4


################################# 
GTZ: 
ble $s3,57,TwoDigitApp  
j OneDigitApp  

GTZ2: 
ble $a2,57,TwoDigitEndApp 
j OneDigitEndApp

TwoDigitApp: 
# the slot start is two digit  
sub $s3,$s3,'0'      # convert to int 
mul $s3,$s3,10 
add $t9,$t9,$s3 
j  continueAppStart 

incCount: 
addi $t4,$t4,1
j  contH
################################################

InvalidStart: 
la $a0,invalidInput 
li $v0,4
syscall
j  checkStarted 


Addition_12: 
addi $s0,$s0,12
j   startTimeConvertedTo24_Sys 

InvalidEnd:  
la $a0,invalidInput 
li $v0,4
syscall
j  checkEnd 

Addition12ToEnd: 
addi $s1,$s1,12 
j  endTimeConvertedTo24_Sys 

Add12App: 
addi $t9,$t9,12
j continueAppStart

Add12EndApp: 
addi $s7,$s7,12 
j  continueAppEnd


EOF7:
la $a0,Appointment_Added
li $v0,4
syscall 

#open a file  to read calendar from 
li	$v0, 13		#open  file syscall , service number 13
la	$a0, myFile	# board file name
li	$a1, 1	
li	$a2, 0
syscall			# open a file (file descriptor returned in $v0)
move	$s1, $v0		# save the file descriptor  


#Now ,read from the file
li	$v0, 15	# read from file syscall , service number 14
move	$a0, $s1	# file descriptor 
la	$a1, buffer	# address of the stored file content that will be readed 
li	$a2, 1024	        # hardcoded buffer length
syscall	

#close file
li $v0,16
move $a0,$s1
syscall
j Main_Menu         # Return to the main menu or your desired execution point







################### Delete Appointment ####################### 
delete_appointment: 
li $v0, 4          #  print string of day number
la $a0, day_prompt_message
syscall

# Get user input for the day number
li $v0, 5          # read day number
syscall

move $t0, $v0      # Store the day number in $t0

  # Searching for the day number in the buffer
  la $t1, buffer     # pointer to the buffer start
  
  search_loop:
  lb $t2, 0($t1)      # load a character from the buffer
  
  
  # Check for the day number (first two digits before ':')
  # Extract the day number from the buffer
   lb $t3, 0($t1)
   lb $t4, 1($t1)
   
  sub $t3, $t3, '0'   # convert character to integer
   sub $t4, $t4, '0'   # convert character to integer
    mul $t3, $t3, 10    # multiply by 10
    add $t3, $t3, $t4   # combine two digits to form the day number
    
    # Check if the day number matches the user input
   beq $t3, $t0, found_day
   
   # Move to the next line in the buffer
   addi $t1, $t1, 1
   j search_loop

found_day:

la $a0,Slot1     # the start time of the slot
li $v0,4
syscall  

 li $v0, 8    
 la $a0, user_input_buffer   
 li $a1, 10         
 syscall


la $a0,Slot2     # the end time of the slot
li $v0,4
syscall  

li $v0, 8 
la $a0, user_input_buffer         
 li $a1, 10         
 syscall


    # Ask user for the appointment type to delete
  li $v0, 4          # syscall to print string
  la $a0, prompt_message
  syscall

    # Get user input for the appointment type
  li $v0, 8          
  la $a0, user_input_buffer  # buffer to store user input
  li $a1, 10         
   syscall

    # Extract the appointment type from the user input
   lb $t5, 0($a0)     # Load the first character from user_input_buffer


    # Search for the appointment in the line
   search_appointment:
   lb $t6, 0($t1)    

   # Check if the appointment type matches
    beq $t6, $t5, delete_appointment_type
    addi $t1, $t1, 1
     j search_appointment

  delete_appointment_type:
  lb $t7, 0($t1)
  beq $t7, ',', exit_delete  
  beq $t7, ':', exit_delete
  # Replace character with a space (delete the character)
  li $t7, ' '  #  value of space
  sb $t7, 0($t1)

   # If the deleted character is 'O', also delete the digit after 'O'
    beq $t5, 'O', check_next_char

  addi $t1, $t1, -1  # Move back one position in the buffer
     j delete_appointment_type

  check_next_char:
  lb $t8, 1($t1)  # Load the next character after 'O'
   beq $t8, 'H', delete_next_digit  # If the next character is 'H', delete it
   addi $t1, $t1, -1  # Move back one position in the buffer
   j delete_appointment_type

   delete_next_digit:
      # Replace the digit after 'O' with a space 
      li $t9, ' '  # ASCII value of space
      sb $t9, 1($t1)
       j delete_appointment_type

exit_delete:
  # Output buffer content after deletion for testing
   la $a0, buffer
   li $v0, 4
    syscall
  j EOF5   
    
    
    
 EOF5:
#open a file  to read calendar from 
li	$v0, 13		#open  file syscall , service number 13
la	$a0, myFile	# board file name
li	$a1, 1	
li	$a2, 0
syscall			# open a file (file descriptor returned in $v0)
move	$s1, $v0		# save the file descriptor  


#Now ,read from the file
li	$v0, 15	# read from file syscall , service number 14 
move	$a0, $s1	# file descriptor 
la	$a1, buffer	# address of the stored file content that will be readed 
li	$a2, 1024	        # hardcoded buffer length
syscall	

#close file
li $v0,16
move $a0,$s1
syscall
j Main_Menu         # Return to the main menu or your desired execution point

exit_from_program:
    li $v0, 10     
    syscall          
    
