@echo off
setlocal enabledelayedexpansion
call config.bat

echo === Phase 3: Post-Blink ===

@REM --- Create master calibration frames ---
@REM Order matters: bias and darks first, then flats (which need bias/dark masters)
echo Creating master bias...
python -m ap_create_master "%RAW_BIAS%" "%CAL_OUTPUT%\bias" --pixinsight-binary "%PIXINSIGHT%"

echo Creating master dark...
python -m ap_create_master "%RAW_DARK%" "%CAL_OUTPUT%\dark" --pixinsight-binary "%PIXINSIGHT%"

@REM Move bias and darks to library before creating flats
echo Moving master bias to library...
python -m ap_move_master_to_library "%CAL_OUTPUT%\bias\master" "%CAL_LIBRARY%"

echo Moving master dark to library...
python -m ap_move_master_to_library "%CAL_OUTPUT%\dark\master" "%CAL_LIBRARY%"

@REM Create flats using bias/dark masters from library
echo Creating master flat...
python -m ap_create_master "%RAW_FLAT%" "%CAL_OUTPUT%\flat" --pixinsight-binary "%PIXINSIGHT%" --bias-master-dir "%CAL_LIBRARY%\MASTER BIAS" --dark-master-dir "%CAL_LIBRARY%\MASTER DARK"

echo Moving master flat to library...
python -m ap_move_master_to_library "%CAL_OUTPUT%\flat\master" "%CAL_LIBRARY%"

@REM --- Copy calibration to blink and move lights to data (per-rig) ---
for %%r in (rigs\*.bat) do (
    call %%r
    echo Copying masters to blink for !RIG_DIR!...
    python -m ap_copy_master_to_blink "%CAL_LIBRARY%" "%DATA_ROOT%\!RIG_DIR!\10_Blink" --flat-state "%DATA_ROOT%\!RIG_DIR!\flat-state.yaml"

    echo Moving lights to data for !RIG_DIR!...
    python -m ap_move_light_to_data "%DATA_ROOT%\!RIG_DIR!\10_Blink" "%DATA_ROOT%\!RIG_DIR!\20_Data"
)

echo.
echo === Phase 3 Complete ===
pause
