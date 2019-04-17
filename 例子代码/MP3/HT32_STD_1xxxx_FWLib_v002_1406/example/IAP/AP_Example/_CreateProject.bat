@echo off
title CreatProject

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

REM gsar.exe -s"<AfterMake>:x0a            <RunUserProg1>0</RunUserProg1>:x0a            <RunUserProg2>0</RunUserProg2>" -r"<AfterMake>:x0a            <RunUserProg1>1</RunUserProg1>:x0a            <RunUserProg2>1</RunUserProg2>" MDK_ARM\Project_1654.uvproj -o
REM gsar.exe -s"<AfterMake>:x0a            <RunUserProg1>0</RunUserProg1>:x0a            <RunUserProg2>0</RunUserProg2>" -r"<AfterMake>:x0a            <RunUserProg1>1</RunUserProg1>:x0a            <RunUserProg2>1</RunUserProg2>" MDK_ARM\Project_1656.uvproj -o
REM gsar.exe -s"<AfterMake>:x0a            <RunUserProg1>0</RunUserProg1>:x0a            <RunUserProg2>0</RunUserProg2>" -r"<AfterMake>:x0a            <RunUserProg1>1</RunUserProg1>:x0a            <RunUserProg2>1</RunUserProg2>" MDK_ARM\Project_12345.uvproj -o
REM gsar.exe -s"<AfterMake>:x0a            <RunUserProg1>0</RunUserProg1>:x0a            <RunUserProg2>0</RunUserProg2>" -r"<AfterMake>:x0a            <RunUserProg1>1</RunUserProg1>:x0a            <RunUserProg2>1</RunUserProg2>" MDK_ARM\Project_12366.uvproj -o

REM gsar.exe -s"<AfterMake>:x0a            <RunUserProg1>0</RunUserProg1>:x0a            <RunUserProg2>0</RunUserProg2>" -r"<AfterMake>:x0a            <RunUserProg1>1</RunUserProg1>:x0a            <RunUserProg2>1</RunUserProg2>" MDK_ARMv5\Project_1654.uvprojx -o
REM gsar.exe -s"<AfterMake>:x0a            <RunUserProg1>0</RunUserProg1>:x0a            <RunUserProg2>0</RunUserProg2>" -r"<AfterMake>:x0a            <RunUserProg1>1</RunUserProg1>:x0a            <RunUserProg2>1</RunUserProg2>" MDK_ARMv5\Project_1656.uvprojx -o
REM gsar.exe -s"<AfterMake>:x0a            <RunUserProg1>0</RunUserProg1>:x0a            <RunUserProg2>0</RunUserProg2>" -r"<AfterMake>:x0a            <RunUserProg1>1</RunUserProg1>:x0a            <RunUserProg2>1</RunUserProg2>" MDK_ARMv5\Project_12345.uvprojx -o
REM gsar.exe -s"<AfterMake>:x0a            <RunUserProg1>0</RunUserProg1>:x0a            <RunUserProg2>0</RunUserProg2>" -r"<AfterMake>:x0a            <RunUserProg1>1</RunUserProg1>:x0a            <RunUserProg2>1</RunUserProg2>" MDK_ARMv5\Project_12366.uvprojx -o

gsar.exe -s"<TextAddressRange>0x00000000</TextAddressRange>" -r"<TextAddressRange>0x00001000</TextAddressRange>" MDK_ARM\Project_1654.uvproj -o
gsar.exe -s"<TextAddressRange>0x00000000</TextAddressRange>" -r"<TextAddressRange>0x00001000</TextAddressRange>" MDK_ARM\Project_1656.uvproj -o
gsar.exe -s"<TextAddressRange>0x00000000</TextAddressRange>" -r"<TextAddressRange>0x00001000</TextAddressRange>" MDK_ARM\Project_12345.uvproj -o
gsar.exe -s"<TextAddressRange>0x00000000</TextAddressRange>" -r"<TextAddressRange>0x00001000</TextAddressRange>" MDK_ARM\Project_12366.uvproj -o

gsar.exe -s"<TextAddressRange>0x00000000</TextAddressRange>" -r"<TextAddressRange>0x00001000</TextAddressRange>" MDK_ARMv5\Project_1654.uvprojx -o
gsar.exe -s"<TextAddressRange>0x00000000</TextAddressRange>" -r"<TextAddressRange>0x00001000</TextAddressRange>" MDK_ARMv5\Project_1656.uvprojx -o
gsar.exe -s"<TextAddressRange>0x00000000</TextAddressRange>" -r"<TextAddressRange>0x00001000</TextAddressRange>" MDK_ARMv5\Project_12345.uvprojx -o
gsar.exe -s"<TextAddressRange>0x00000000</TextAddressRange>" -r"<TextAddressRange>0x00001000</TextAddressRange>" MDK_ARMv5\Project_12366.uvprojx -o

gsar.exe -s"<DataAddressRange>0x20000000</DataAddressRange>" -r"<DataAddressRange>0x20000010</DataAddressRange>" MDK_ARM\Project_1654.uvproj -o
gsar.exe -s"<DataAddressRange>0x20000000</DataAddressRange>" -r"<DataAddressRange>0x20000010</DataAddressRange>" MDK_ARM\Project_1656.uvproj -o
gsar.exe -s"<DataAddressRange>0x20000000</DataAddressRange>" -r"<DataAddressRange>0x20000010</DataAddressRange>" MDK_ARM\Project_12345.uvproj -o
gsar.exe -s"<DataAddressRange>0x20000000</DataAddressRange>" -r"<DataAddressRange>0x20000010</DataAddressRange>" MDK_ARM\Project_12366.uvproj -o

gsar.exe -s"<DataAddressRange>0x20000000</DataAddressRange>" -r"<DataAddressRange>0x20000010</DataAddressRange>" MDK_ARMv5\Project_1654.uvprojx -o
gsar.exe -s"<DataAddressRange>0x20000000</DataAddressRange>" -r"<DataAddressRange>0x20000010</DataAddressRange>" MDK_ARMv5\Project_1656.uvprojx -o
gsar.exe -s"<DataAddressRange>0x20000000</DataAddressRange>" -r"<DataAddressRange>0x20000010</DataAddressRange>" MDK_ARMv5\Project_12345.uvprojx -o
gsar.exe -s"<DataAddressRange>0x20000000</DataAddressRange>" -r"<DataAddressRange>0x20000010</DataAddressRange>" MDK_ARMv5\Project_12366.uvprojx -o

gsar.exe -s"define symbol __ICFEDIT_intvec_start__ = 0x00000000;" -r"define symbol __ICFEDIT_intvec_start__ = 0x00001000;" EWARM\linker.icf -o
gsar.exe -s"define symbol __ICFEDIT_region_ROM_start__ = 0x00000000;" -r"define symbol __ICFEDIT_region_ROM_start__ = 0x00001000;" EWARM\linker.icf -o
gsar.exe -s"define symbol __ICFEDIT_region_RAM_start__ = 0x20000000;" -r"define symbol __ICFEDIT_region_RAM_start__ = 0x20000010;" EWARM\linker.icf -o

gsar.exe -s"define symbol __ICFEDIT_intvec_start__ = 0x00000000;" -r"define symbol __ICFEDIT_intvec_start__ = 0x00001000;" EWARMv8\linker.icf -o
gsar.exe -s"define symbol __ICFEDIT_region_ROM_start__ = 0x00000000;" -r"define symbol __ICFEDIT_region_ROM_start__ = 0x00001000;" EWARMv8\linker.icf -o
gsar.exe -s"define symbol __ICFEDIT_region_RAM_start__ = 0x20000000;" -r"define symbol __ICFEDIT_region_RAM_start__ = 0x20000010;" EWARMv8\linker.icf -o

IF EXIST _StackHeapSize.bat GOTO MemSET
GOTO NoMemSET

:MemSET
CALL _StackHeapSize.bat

gsar.exe -s"Stack_Size          EQU     512" -r"Stack_Size          EQU     %HT_STACK_SIZE%" MDK_ARM\startup_ht32f1xxxx_01.s -o
gsar.exe -s"Stack_Size          EQU     512" -r"Stack_Size          EQU     %HT_STACK_SIZE%" MDK_ARMv5\startup_ht32f1xxxx_01.s -o
gsar.exe -s"Heap_Size           EQU     0" -r"Heap_Size           EQU     %HT_HEAP_SIZE%" MDK_ARM\startup_ht32f1xxxx_01.s -o
gsar.exe -s"Heap_Size           EQU     0" -r"Heap_Size           EQU     %HT_HEAP_SIZE%" MDK_ARMv5\startup_ht32f1xxxx_01.s -o

gsar.exe -s"define symbol __ICFEDIT_size_cstack__ = 0x200;" -r"define symbol __ICFEDIT_size_cstack__ = %HT_STACK_SIZE%;" EWARM\linker.icf -o
gsar.exe -s"define symbol __ICFEDIT_size_cstack__ = 0x200;" -r"define symbol __ICFEDIT_size_cstack__ = %HT_STACK_SIZE%;" EWARMv8\linker.icf -o
gsar.exe -s"define symbol __ICFEDIT_size_heap__   = 0x0;" -r"define symbol __ICFEDIT_size_heap__   = %HT_HEAP_SIZE%;" EWARM\linker.icf -o
gsar.exe -s"define symbol __ICFEDIT_size_heap__   = 0x0;" -r"define symbol __ICFEDIT_size_heap__   = %HT_HEAP_SIZE%;" EWARMv8\linker.icf -o

:NoMemSET
del gsar.exe /Q
