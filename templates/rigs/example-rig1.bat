@REM Example rig configuration: longer focal length scope
@REM Copy this file and rename it for each active rig.

@REM Rig profile directory name (must match directory under DATA_ROOT)
set RIG_DIR=C8E@f10.0+ZWO ASI2600MM Pro

@REM RMS culling: reject frames with guiding error above this threshold
set CULL_RMS_MAX=2.0
set CULL_RMS_AUTO_ACCEPT=100

@REM HFR culling: reject frames with poor star focus above this threshold
@REM Longer focal lengths typically need higher HFR tolerance
set CULL_HFR_MAX=7.0
set CULL_HFR_AUTO_ACCEPT=30
