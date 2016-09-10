@ECHO OFF
@ECHO // begin >> C:\%1.txt
@ECHO .Search Text: %1
@ECHO .Filename Search Pattern: %2
@ECHO .Search folder and files:
@ECHO .
DIR %2 | more
@ECHO Results contained in C:\%1.txt 
DATE /t >> C:\%1.txt & TIME /t >> C:\%1.txt
@ECHO .Search Text: %1 >> C:\%1.txt
@ECHO .Filename Search Pattern: %2 >> C:\%1.txt
@ECHO .Search folder and files: >> C:\%1.txt
@ECHO . >> C:\%1.txt
DIR %2 | more >> C:\%1.txt
@REM // does not print names of files processed
@REM findstr /i /n /s %1 *.%2 >> C:\%1.txt	
for /R %%F in (*.%2) do ECHO %%~sF >> C:\%1.txt & findstr /i /n %1 %%~sF >> C:\%1.txt
@ECHO // done >> C:\%1.txt 
