@echo off

@REM === Shared Paths ===
@REM Root of NINA raw capture output
set RAW_ROOT=D:\Astrophotography\RAW

@REM Subdirectories under RAW_ROOT
set RAW_LIGHT=%RAW_ROOT%\LIGHT
set RAW_BIAS=%RAW_ROOT%\BIAS
set RAW_DARK=%RAW_ROOT%\DARK
set RAW_FLAT=%RAW_ROOT%\FLAT

@REM Data directory (contains rig profile subdirectories)
set DATA_ROOT=D:\Astrophotography\Data

@REM Where rejected frames are moved
set REJECT_DIR=D:\Astrophotography\Reject

@REM Calibration library (permanent master storage)
set CAL_LIBRARY=D:\Astrophotography\_Library

@REM Calibration working directory (temporary integration output)
set CAL_OUTPUT=D:\Astrophotography\_calibration

@REM PixInsight binary path
set PIXINSIGHT=C:\Program Files\PixInsight\bin\PixInsight.exe
