@echo off
setlocal enabledelayedexpansion
call config.bat

echo === Phase 1: Prepare for Blink ===

@REM --- Preserve headers ---
@REM Light frames: preserve rig metadata from NINA paths
echo Preserving light frame headers...
python -m ap_preserve_header "%RAW_LIGHT%" --include INSTRUME OFFSET READOUTM

@REM Calibration frames: preserve equipment metadata from NINA paths
echo Preserving calibration frame headers...
python -m ap_preserve_header "%RAW_BIAS%" --include CAMERA OPTIC FILTER
python -m ap_preserve_header "%RAW_DARK%" --include CAMERA OPTIC FILTER
python -m ap_preserve_header "%RAW_FLAT%" --include CAMERA OPTIC FILTER

@REM --- Move lights to blink structure ---
echo Moving light frames to blink directories...
python -m ap_move_raw_light_to_blink "%RAW_LIGHT%" "%DATA_ROOT%"

@REM --- Cull poor quality frames (per-rig thresholds) ---
echo Culling poor quality frames...
for %%r in (rigs\*.bat) do (
    call %%r
    echo Culling for !RIG_DIR!...
    python -m ap_cull_light "%DATA_ROOT%\!RIG_DIR!\10_Blink" "%REJECT_DIR%" --max-rms !CULL_RMS_MAX! --auto-accept-percent !CULL_RMS_AUTO_ACCEPT!
    python -m ap_cull_light "%DATA_ROOT%\!RIG_DIR!\10_Blink" "%REJECT_DIR%" --max-hfr !CULL_HFR_MAX! --auto-accept-percent !CULL_HFR_AUTO_ACCEPT!
)

echo.
echo === Phase 1 Complete ===
echo Review frames in your blink tool, then run 02-post-blink.bat
pause
