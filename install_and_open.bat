@echo off
echo ============================================================
echo   FoodBridge Instant Auto-Install and Direct Launch
echo ============================================================
echo Waiting for your phone to connect...

"%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" wait-for-device
echo [OK] Phone detected! Transferring and installing FoodBridge directly...

"%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" push "%~dp0FoodBridge.apk" /data/local/tmp/FoodBridge.apk
"%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" shell pm install -r /data/local/tmp/FoodBridge.apk

echo [OK] Launching FoodBridge App on your phone screen...
"%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" shell am start -n org.foodbridge.app/com.foodbridge.foodbridge.MainActivity

echo.
echo ============================================================
echo   SUCCESS: FoodBridge is now open on your mobile screen!
echo ============================================================
timeout /t 3
