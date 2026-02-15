@REM Example rig configuration: shorter focal length scope
@REM Copy this file and rename it for each active rig.

@REM Rig profile directory name (must match directory under DATA_ROOT)
set RIG_DIR=SQA55@f5.3+ATR585M

@REM RMS culling: reject frames with guiding error above this threshold
set CULL_RMS_MAX=2.0
set CULL_RMS_AUTO_ACCEPT=100

@REM HFR culling: reject frames with poor star focus above this threshold
@REM Shorter focal lengths allow tighter HFR thresholds
set CULL_HFR_MAX=4.0
set CULL_HFR_AUTO_ACCEPT=10
