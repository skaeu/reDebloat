#!/bin/bash

# Start re:Debloat

pause() {
    read -n 1 -s -r -p "Welcome to re:Debloat! Press any button to start the script..."
    echo
}

# Step 1: Run logcat with filtering and write to file

echo "Running logcat to collect logs..."
(
    adb logcat *:W -v time | grep -v "SemWallpaperThemeOverlayPolicy" | grep -v "PackageManager" | grep -v "ActivityManager" > logcat.txt &
    sleep 5
    pkill -f "adb logcat"
)
echo "Logs collected and saved to logcat.txt"
pause

# Step 2: Search for matches in logs and save results

echo "Search for matches in logs and save results..."
log_file="logcat.txt"
debloat_list="debloat_list_packages.txt"
output_file="found_packages.txt"

grep -E 'E |W ' "$log_file" | grep -oP '([a-zA-Z0-9._-]+\.[a-zA-Z0-9._-]+)' | sort | uniq | grep -Fxf "$debloat_list" > "$output_file"
echo "Matching packets saved to $output_file"
pause

# Step 3: Installing packages

echo "Installing packages..."
input_file="found_packages.txt"

for package in $(cat $input_file); do
    echo "Installing package: $package"
    adb shell pm install-existing "$package"
done

echo "Package installation complete."
echo "re:Debloat completed!"
pause
