@echo off
setlocal enabledelayedexpansion

echo ============================================================
echo   FoodBridge Instant Auto-Install and Direct Launch
echo ============================================================

set "ADB=%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe"
if not exist "!ADB!" (
    set "ADB=D:\apk\Android studio\platform-tools\adb.exe"
)
if not exist "!ADB!" (
    where adb.exe >nul 2>nul
    if !errorlevel! equ 0 (
        set "ADB=adb"
    ) else (
        echo [ERROR] adb.exe not found!
        pause
        exit /b 1
    )
)

echo Using ADB: !ADB!
echo Waiting for your phone to connect...
"!ADB!" wait-for-device
echo [OK] Phone detected! Transferring and installing FoodBridge directly...

set "APK_PATH=%~dp0FoodBridge.apk"
if not exist "!APK_PATH!" (
    set "APK_PATH=%~dp0build\app\outputs\flutter-apk\app-debug.apk"
)

if not exist "!APK_PATH!" (
    echo [ERROR] FoodBridge APK not found at !APK_PATH!
    pause
    exit /b 1
)

"!ADB!" push "!APK_PATH!" /data/local/tmp/FoodBridge.apk
"!ADB!" shell pm install -r /data/local/tmp/FoodBridge.apk

echo [OK] Launching FoodBridge App on your phone screen...
"!ADB!" shell am start -n org.foodbridge.app/com.foodbridge.foodbridge.MainActivity

echo.
echo ============================================================
echo   SUCCESS: FoodBridge is now open on your mobile screen!
echo ============================================================
timeout /t 3
