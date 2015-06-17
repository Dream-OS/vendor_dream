for device in $(curl -s https://raw.githubusercontent.com/Dream-OS/hudson/master/build-targets)
do
add_lunch_combo dream_$device-userdebug
done
