@echo off
REM /*********************************************************************************************************//**
REM * @file    _CreateProject.bat
REM * @version $Rev:: 1342         $
REM * @date    $Date:: 2018-08-01 #$
REM * @brief   Main program.
REM *************************************************************************************************************
REM * @attention
REM *
REM * Firmware Disclaimer Information
REM *
REM * 1. The customer hereby acknowledges and agrees that the program technical documentation, including the
REM *    code, which is supplied by Holtek Semiconductor Inc., (hereinafter referred to as "HOLTEK") is the
REM *    proprietary and confidential intellectual property of HOLTEK, and is protected by copyright law and
REM *    other intellectual property laws.
REM *
REM * 2. The customer hereby acknowledges and agrees that the program technical documentation, including the
REM *    code, is confidential information belonging to HOLTEK, and must not be disclosed to any third parties
REM *    other than HOLTEK and the customer.
REM *
REM * 3. The program technical documentation, including the code, is provided "as is" and for customer reference
REM *    only. After delivery by HOLTEK, the customer shall use the program technical documentation, including
REM *    the code, at their own risk. HOLTEK disclaims any expressed, implied or statutory warranties, including
REM *    the warranties of merchantability, satisfactory quality and fitness for a particular purpose.
REM *
REM * <h2><center>Copyright (C) Holtek Semiconductor Inc. All rights reserved</center></h2>
REM ************************************************************************************************************/

title Creat Project

set "CoIDE_DIR=%cd%"
:1
set "CoIDE_DIR=%CoIDE_DIR:*\=%"&set "b=%CoIDE_DIR:\=%"
if "%b%" neq "%CoIDE_DIR%" goto 1
set "CoIDE_DIR=CoIDE_%CoIDE_DIR%"


xcopy /S "..\..\..\project_template\IP\Template\*"  "."
rename "CoIDE_Template\CoIDE_Template.cob" "%CoIDE_DIR%.cob"
rename CoIDE_Template %CoIDE_DIR%

copy "..\..\..\gsar.e_x_e" "."
rename gsar.e_x_e gsar.exe


IF EXIST _ProjectConfig.bat GOTO PROJECT_CONFIG
GOTO CREATE_PROJECT_END

:PROJECT_CONFIG
call _ProjectConfig.bat


REM Change RO, RW Based address
REM  ===========================================================================
IF %HT_CHANGE_RO_RW%==1 GOTO BaseSET
GOTO BaseSET_End
:BaseSET
gsar.exe -s"<TextAddressRange>0x00000000</TextAddressRange>" -r"<TextAddressRange>%HT_RO_ADDR%</TextAddressRange>" MDK_ARM\*.uvproj -o
gsar.exe -s"<TextAddressRange>0x00000000</TextAddressRange>" -r"<TextAddressRange>%HT_RO_ADDR%</TextAddressRange>" MDK_ARMv5\*.uvprojx -o

gsar.exe -s"<DataAddressRange>0x20000000</DataAddressRange>" -r"<DataAddressRange>%HT_RW_ADDR%</DataAddressRange>" MDK_ARM\*.uvproj -o
gsar.exe -s"<DataAddressRange>0x20000000</DataAddressRange>" -r"<DataAddressRange>%HT_RW_ADDR%</DataAddressRange>" MDK_ARMv5\*.uvprojx -o

gsar.exe -s"define symbol __ICFEDIT_region_ROM_start__ = 0x00000000;" -r"define symbol __ICFEDIT_region_ROM_start__ = %HT_RO_ADDR%;" EWARM\*.icf -o
gsar.exe -s"define symbol __ICFEDIT_region_ROM_start__ = 0x00000000;" -r"define symbol __ICFEDIT_region_ROM_start__ = %HT_RO_ADDR%;" EWARMv8\*.icf -o

gsar.exe -s"define symbol __ICFEDIT_region_RAM_start__ = 0x20000000;" -r"define symbol __ICFEDIT_region_RAM_start__ = %HT_RW_ADDR%;" EWARM\*.icf -o
gsar.exe -s"define symbol __ICFEDIT_region_RAM_start__ = 0x20000000;" -r"define symbol __ICFEDIT_region_RAM_start__ = %HT_RW_ADDR%;" EWARMv8\*.icf -o

gsar.exe -s"ORIGIN = 0x00000000" -r"ORIGIN = %HT_RO_ADDR%" GNU_ARM\*.ld -o
gsar.exe -s"ORIGIN = 0x00000000" -r"ORIGIN = %HT_RO_ADDR%" SourceryG++Lite\*.ld -o

gsar.exe -s"ORIGIN = 0x20000000" -r"ORIGIN = %HT_RW_ADDR%" GNU_ARM\*.ld -o
gsar.exe -s"ORIGIN = 0x20000000" -r"ORIGIN = %HT_RW_ADDR%" SourceryG++Lite\*.ld -o
:BaseSET_End


REM Change Stack, Heap size
REM  ===========================================================================
IF %HT_CHANGE_STACK_HEAP%==1 GOTO MemSET
GOTO MemSET_End
:MemSET
gsar.exe -s"Stack_Size          EQU     512" -r"Stack_Size          EQU     %HT_STACK_SIZE%" MDK_ARM\startup_ht32f1xxxx_01.s -o
gsar.exe -s"Heap_Size           EQU     0"   -r"Heap_Size           EQU     %HT_HEAP_SIZE%"  MDK_ARM\startup_ht32f1xxxx_01.s -o

gsar.exe -s"Stack_Size          EQU     512" -r"Stack_Size          EQU     %HT_STACK_SIZE%" MDK_ARMv5\startup_ht32f1xxxx_01.s -o
gsar.exe -s"Heap_Size           EQU     0"   -r"Heap_Size           EQU     %HT_HEAP_SIZE%"  MDK_ARMv5\startup_ht32f1xxxx_01.s -o

gsar.exe -s"define symbol __ICFEDIT_size_cstack__ = 0x200;" -r"define symbol __ICFEDIT_size_cstack__ = %HT_STACK_SIZE%;" EWARM\linker.icf -o
gsar.exe -s"define symbol __ICFEDIT_size_cstack__ = 0x200;" -r"define symbol __ICFEDIT_size_cstack__ = %HT_STACK_SIZE%;" EWARMv8\linker.icf -o
gsar.exe -s"define symbol __ICFEDIT_size_heap__   = 0x0;" -r"define symbol __ICFEDIT_size_heap__   = %HT_HEAP_SIZE%;" EWARM\linker.icf -o
gsar.exe -s"define symbol __ICFEDIT_size_heap__   = 0x0;" -r"define symbol __ICFEDIT_size_heap__   = %HT_HEAP_SIZE%;" EWARMv8\linker.icf -o

gsar.exe -s".equ    Stack_Size, 512" -r".equ    Stack_Size, %HT_STACK_SIZE%"    GNU_ARM\startup_ht32f1xxxx_gcc_01.s -o
gsar.exe -s".equ    Heap_Size, 0"    -r".equ    Heap_Size, %HT_HEAP_SIZE%"      GNU_ARM\startup_ht32f1xxxx_gcc_01.s -o

gsar.exe -s".equ    Stack_Size, 512" -r".equ    Stack_Size, %HT_STACK_SIZE%"    SourceryG++Lite\startup_ht32f1xxxx_cs3_01.s -o
gsar.exe -s".equ    Heap_Size, 0"    -r".equ    Heap_Size, %HT_HEAP_SIZE%"      SourceryG++Lite\startup_ht32f1xxxx_cs3_01.s -o
:MemSET_End


REM Change include path
REM  ===========================================================================
IF %HT_CHANGE_INCLUDE%==1 GOTO IncludeSET
GOTO IncludeSET_End
:IncludeSET
gsar.exe -s"..\..\..\..\utilities</IncludePath>" -r"..\..\..\..\utilities;%HT_EXTRA_INCLUDE%</IncludePath>" MDK_ARM\*.uvproj -o
gsar.exe -s"..\..\..\..\utilities</IncludePath>" -r"..\..\..\..\utilities;%HT_EXTRA_INCLUDE%</IncludePath>" MDK_ARMv5\*.uvprojx -o
gsar.exe -s"<name>CCIncludePath2</name>" -r"<name>CCIncludePath2</name>:x0d:x0a          <state>$PROJ_DIR$\%HT_EXTRA_INCLUDE_IAR5%</state>" EWARM\*.ewp -o
gsar.exe -s"<name>CCIncludePath2</name>" -r"<name>CCIncludePath2</name>:x0d:x0a          <state>$PROJ_DIR$\%HT_EXTRA_INCLUDE_IAR4%</state>" EWARM\*.ewp -o
gsar.exe -s"<name>CCIncludePath2</name>" -r"<name>CCIncludePath2</name>:x0d:x0a          <state>$PROJ_DIR$\%HT_EXTRA_INCLUDE_IAR3%</state>" EWARM\*.ewp -o
gsar.exe -s"<name>CCIncludePath2</name>" -r"<name>CCIncludePath2</name>:x0d:x0a          <state>$PROJ_DIR$\%HT_EXTRA_INCLUDE_IAR2%</state>" EWARM\*.ewp -o
gsar.exe -s"<name>CCIncludePath2</name>" -r"<name>CCIncludePath2</name>:x0d:x0a          <state>$PROJ_DIR$\%HT_EXTRA_INCLUDE_IAR1%</state>" EWARM\*.ewp -o
gsar.exe -s"<name>CCIncludePath2</name>" -r"<name>CCIncludePath2</name>:x0d:x0a                    <state>$PROJ_DIR$\%HT_EXTRA_INCLUDE_IAR5%</state>" EWARMv8\*.ewp -o
gsar.exe -s"<name>CCIncludePath2</name>" -r"<name>CCIncludePath2</name>:x0d:x0a                    <state>$PROJ_DIR$\%HT_EXTRA_INCLUDE_IAR4%</state>" EWARMv8\*.ewp -o
gsar.exe -s"<name>CCIncludePath2</name>" -r"<name>CCIncludePath2</name>:x0d:x0a                    <state>$PROJ_DIR$\%HT_EXTRA_INCLUDE_IAR3%</state>" EWARMv8\*.ewp -o
gsar.exe -s"<name>CCIncludePath2</name>" -r"<name>CCIncludePath2</name>:x0d:x0a                    <state>$PROJ_DIR$\%HT_EXTRA_INCLUDE_IAR2%</state>" EWARMv8\*.ewp -o
gsar.exe -s"<name>CCIncludePath2</name>" -r"<name>CCIncludePath2</name>:x0d:x0a                    <state>$PROJ_DIR$\%HT_EXTRA_INCLUDE_IAR1%</state>" EWARMv8\*.ewp -o
gsar.exe -s"..\..\..\..\utilities</IncludePath>" -r"..\..\..\..\utilities;%HT_EXTRA_INCLUDE%</IncludePath>" GNU_ARM\*.uvprojx -o
gsar.exe -s"..\..\..\..\utilities</IncludePath>" -r"..\..\..\..\utilities;%HT_EXTRA_INCLUDE%</IncludePath>" SourceryG++Lite\*.uvprojx -o
:IncludeSET_End


REM Change C define
REM  ===========================================================================
IF %HT_CHANGE_CDEFINE%==1 GOTO CdefineSET
GOTO CdefineSET_End
:CdefineSET
gsar.exe -s"<Define>USE_HT32_DRIVER," -r"<Define>USE_HT32_DRIVER, %HT_EXTRA_CDEFINE% " MDK_ARM\*.uvproj -o
gsar.exe -s"<Define>USE_HT32_DRIVER," -r"<Define>USE_HT32_DRIVER, %HT_EXTRA_CDEFINE% " MDK_ARMv5\*.uvprojx -o
gsar.exe -s"<name>CCDefines</name>" -r"<name>CCDefines</name>:x0d:x0a          <state>%HT_EXTRA_CDEFINE_IAR5%</state>" EWARM\*.ewp -o
gsar.exe -s"<name>CCDefines</name>" -r"<name>CCDefines</name>:x0d:x0a          <state>%HT_EXTRA_CDEFINE_IAR4%</state>" EWARM\*.ewp -o
gsar.exe -s"<name>CCDefines</name>" -r"<name>CCDefines</name>:x0d:x0a          <state>%HT_EXTRA_CDEFINE_IAR3%</state>" EWARM\*.ewp -o
gsar.exe -s"<name>CCDefines</name>" -r"<name>CCDefines</name>:x0d:x0a          <state>%HT_EXTRA_CDEFINE_IAR2%</state>" EWARM\*.ewp -o
gsar.exe -s"<name>CCDefines</name>" -r"<name>CCDefines</name>:x0d:x0a          <state>%HT_EXTRA_CDEFINE_IAR1%</state>" EWARM\*.ewp -o
gsar.exe -s"<name>CCDefines</name>" -r"<name>CCDefines</name>:x0d:x0a                    <state>%HT_EXTRA_CDEFINE_IAR5%</state>" EWARMv8\*.ewp -o
gsar.exe -s"<name>CCDefines</name>" -r"<name>CCDefines</name>:x0d:x0a                    <state>%HT_EXTRA_CDEFINE_IAR4%</state>" EWARMv8\*.ewp -o
gsar.exe -s"<name>CCDefines</name>" -r"<name>CCDefines</name>:x0d:x0a                    <state>%HT_EXTRA_CDEFINE_IAR3%</state>" EWARMv8\*.ewp -o
gsar.exe -s"<name>CCDefines</name>" -r"<name>CCDefines</name>:x0d:x0a                    <state>%HT_EXTRA_CDEFINE_IAR2%</state>" EWARMv8\*.ewp -o
gsar.exe -s"<name>CCDefines</name>" -r"<name>CCDefines</name>:x0d:x0a                    <state>%HT_EXTRA_CDEFINE_IAR1%</state>" EWARMv8\*.ewp -o
gsar.exe -s"<Define>USE_HT32_DRIVER," -r"<Define>USE_HT32_DRIVER, %HT_EXTRA_CDEFINE% " GNU_ARM\*.uvprojx -o
gsar.exe -s"<Define>USE_HT32_DRIVER," -r"<Define>USE_HT32_DRIVER, %HT_EXTRA_CDEFINE% " SourceryG++Lite\*.uvprojx -o
:CdefineSET_End


:CREATE_PROJECT_END
del gsar.exe /Q
