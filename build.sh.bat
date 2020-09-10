#/bin/sh 2>nul || goto :windows

# POSIX Shell script for Unix-like systems
echo Compiling for Unix
if [ "${OS}" = Windows_NT ]; then
   echo Windows builds must be executed within Native Tools Command Prompt
   exit 1
fi

make -B

echo Completed
exit $?

# Windows Batch script
:windows
@echo off
echo Compiling for Windows NT
if not defined VSCMD_ARG_TGT_ARCH (
   echo Must be executed within Native Tools Command Prompt
   exit /B 1
)

set CC=cl
set RM=del
set OBJEXT=obj
set OUTEXT=dll
set CFLAGS=/nologo /W1 /DWINVER=0x0400 /D_WIN32_WINNT=0x0400 /DWIN32 /DCORRECT_VRAM_READS /D_WINDOWS /D_USRDLL /D_CRT_SECURE_NO_WARNINGS /DMSVC2010_EXPORTS  /D_UNICODE /DUNICODE /GL /O2 /Ob2 /fp:fast /Ot /GF /GT /Oi /MT
set LDFLAGS=/LTCG
set INLINE=__inline

if "%VSCMD_ARG_TGT_ARCH%"=="x64" (
	set CFLAGS=%CFLAGS% /Fdvc142.pdb
) else (
	rem 32-bit Windows NT builds require SSE instructions, supported from Pentium III CPUs.
	rem These builds offer support for ReactOS and Windows XP.
	set CFLAGS=%CFLAGS% /arch:SSE /Fdvc141.pdb
)

gnumake.exe CC="%CC%" RM="%RM%" OBJEXT="%OBJEXT%" OUTEXT="%OUTEXT%" CFLAGS="%CFLAGS%" INLINE="%INLINE%" LDFLAGS="%LDFLAGS%" DEBUG=0 %1

exit /B %errorlevel%