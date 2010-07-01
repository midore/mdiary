# 2010-06-30
# % sw_vers
# ProductName:	Mac OS X
# ProductVersion:	10.6.4
# BuildVersion:	10F569
#
# AppleScript't version
# "2.1.2"

on run argv
  tell application "Terminal"
    do script "/usr/bin/vim  " & item 1 of argv
    return
  end tell
end run

