@echo off
REM ###########################################################################
REM Script generated by Fortify Scan Wizard (c) 2011-2022 Micro Focus or one of its affiliates
REM Created on 2022/06/17 20:26:00
REM ###########################################################################
REM Generated for the following languages:
REM 	Python
REM ###########################################################################
REM FPR - the name of analysis results file
REM DEBUG - if set to true, runs SCA in debug mode
REM SOURCEANALYZER - the name of the SCA executable
REM BUILDID - the SCA build ID
REM ARGFILE - the name of the argument file that's passed to SCA
REM BYTECODE_ARGFILE - the name of the argument file for Java bytecode translation in the SCA
REM MEMORY - the memory settings for SCA
REM SCANSWITCHES - parameters to pass in the SCA analysis phase
REM LAUNCHERSWITCHES - the launcher settings that are used to invoke SCA
REM SCANCENTRAL_CLI - the name of the ScanCentral executable
REM SCANCENTRAL_URL - the URL of the ScanCentral Controller
REM SSCURL - the SSC url for uploading the FPR
REM SSCPROJECT - the name of the project to upload the FPR to
REM SSCVERSION - the name of the project version to upload the FPR to
REM SSCTOKEN - the token for authenticating the FPR upload
REM OLDFILENUMBER - this defines the file that contains the number of files within the project, it is automatically generated
REM FILENOMAXDIFF - this is the percentage of difference between the number of files which will trigger a warning by the script
REM ###########################################################################

set DEBUG=false
set SOURCEANALYZER=sourceanalyzer
set FPR="Fortifypython-fortify-master.fpr"
set SCANCENTRAL_CLI=scancentral.bat
set SCANCENTRAL_URL=null
set SSCURL=http://192.168.1.120:8080/ssc
set SSCPROJECT="Sample_python"
set SSCVERSION="1.0"
set SSCTOKEN=a8c667a5-cb20-4952-b6f5-c760355f0a9e
set BUILDID="python-fortify-master"
set ARGFILE="Fortifypython-fortify-master.bat.args"
set BYTECODE_ARGFILE="Fortifypython-fortify-master.bat.bytecode.args"
set MEMORY=-Xmx7298M -Xms400M -Xss24M 
set LAUNCHERSWITCHES=""
set SCANSWITCHES=""
set OLDFILENUMBER="Fortifypython-fortify-master.bat.fileno"
set FILENOMAXDIFF=10
set ENABLE_BYTECODE=false

set PROJECTROOT0="D:\Synnex Metrodata\MICRO FOCUS\CyberRes\Fortify\Example Project\python-fortify-master\python-fortify-master"
IF NOT EXIST %PROJECTROOT0% (
   ECHO  ERROR: This script is being run on a different machine than it was
   ECHO         generated on or the targeted project has been moved. This script is 
   ECHO         configured to locate files at
   ECHO            %PROJECTROOT0%
   ECHO         Please modify the %%PROJECTROOT0%% variable found
   ECHO         at the top of this script to point to the corresponding directory
   ECHO         located on this machine.
   GOTO :FINISHED
)

IF %DEBUG%==true set LAUNCHERSWITCHES=-debug %LAUNCHERSWITCHES%
echo Extracting Arguments File


echo. >%ARGFILE%
echo. >%BYTECODE_ARGFILE%
SETLOCAL ENABLEDELAYEDEXPANSION
IF EXIST %0 (
   set SCAScriptFile=%0
) ELSE (
  set SCAScriptFile=%0.bat
)

set PROJECTROOT0=%PROJECTROOT0:)=^)%
FOR /f "delims=" %%a IN ('findstr /B /C:"REM ARGS" %SCAScriptFile%' ) DO (
   set argVal=%%a
   set argVal=!argVal:PROJECTROOT0_MARKER=%PROJECTROOT0:~1,-1%!
   echo !argVal:~9! >> %ARGFILE%
)
set PROJECTROOT0=%PROJECTROOT0:)=^)%
FOR /f "delims=" %%a IN ('findstr /B /C:"REM BYTECODE_ARGS" %SCAScriptFile%' ) DO (
   set ENABLE_BYTECODE=true
   set argVal=%%a
   set argVal=!argVal:PROJECTROOT0_MARKER=%PROJECTROOT0:~1,-1%!
   echo !argVal:~18! >> %BYTECODE_ARGFILE%
)
ENDLOCAL && set ENABLE_BYTECODE=%ENABLE_BYTECODE%

REM ###########################################################################
echo Cleaning previous scan artifacts
%SOURCEANALYZER% %MEMORY% %LAUNCHERSWITCHES% -b %BUILDID% -clean 
IF %ERRORLEVEL% NEQ 0  (
echo sourceanalyzer failed, exiting
GOTO :FINISHED
)
REM ###########################################################################
echo Translating files
%SOURCEANALYZER% %MEMORY% %LAUNCHERSWITCHES% -b %BUILDID% @%ARGFILE%
IF %ERRORLEVEL% NEQ 0  (
echo sourceanalyzer failed, exiting
GOTO :FINISHED
)
REM ###########################################################################
IF %ENABLE_BYTECODE%==true (
echo Translating Java bytecode files
%SOURCEANALYZER% %MEMORY% %LAUNCHERSWITCHES% -b %BUILDID% @%BYTECODE_ARGFILE%
IF %ERRORLEVEL% NEQ 0  (
echo sourceanalyzer failed, exiting
GOTO :FINISHED
)
)
REM ###########################################################################
echo Testing Difference between Translations
SETLOCAL
FOR /F "delims=" %%A in ('%SOURCEANALYZER% -b %BUILDID% -show-files ^| findstr /R /N "^" ^| find /C ":" ') DO SET FILENUMBER=%%A
IF NOT EXIST %OLDFILENUMBER% (
	ECHO It appears to be the first time running this script, setting %OLDFILENUMBER% to %FILENUMBER%
	ECHO %FILENUMBER% > %OLDFILENUMBER%
	GOTO TESTENDED
)

FOR /F "delims=" %%i IN (%OLDFILENUMBER%) DO SET OLDFILENO=%%i
set /a DIFF=%OLDFILENO% * %FILENOMAXDIFF%
set /a DIFF /=  100
set /a MAX=%OLDFILENO% + %DIFF%
set /a MIN=%OLDFILENO% - %DIFF%

IF %FILENUMBER% LSS %MIN% set SHOWWARNING=true
IF %FILENUMBER% GTR %MAX% set SHOWWARNING=true

IF DEFINED SHOWWARNING (
	ECHO WARNING: The number of files has changed by over %FILENOMAXDIFF%%%, it is recommended 
	ECHO          that this script is regenerated with the ScanWizard
)
:TESTENDED
ENDLOCAL

REM ###########################################################################
echo Starting ScanCentral scan
%SCANCENTRAL_CLI% -sscurl %SSCURL% -ssctoken %SSCTOKEN% start -upload  -uptoken %SSCTOKEN% --application %SSCPROJECT% --application-version %SSCVERSION% -b %BUILDID% -scan 
IF %ERRORLEVEL% NEQ 0  (
echo scancentral failed, exiting
GOTO :FINISHED
)
REM ###########################################################################
echo Finished
:FINISHED
REM ARGS "PROJECTROOT0_MARKER"