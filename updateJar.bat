@ECHO OFF

SETLOCAL ENABLEDELAYEDEXPANSION

REM Set name of ActionBar
set actionBarName=BIOP_Channel_Tools

copy "C:\Fiji\plugins\ActionBar\Debug\BIOP_Channel_Tools.ijm" BIOP_Channel_Tools.ijm

ECHO Packing ActionBar: "%actionBarName%"

set finalName=%actionBarName%.jar

REM Create JAR File
ECHO Creating JAR File
jar cf %finalName% plugins.config *.ijm
ECHO Done.

copy %finalName% "C:\Fiji\plugins\BIOP\%finalName%"
PAUSE