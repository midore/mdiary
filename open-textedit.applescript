# 2010-06-30
# % sw_vers
# ProductName:  Mac OS X
# ProductVersion: 10.6.4
# BuildVersion: 10F569
#
# AppleScript't version
# "2.1.2"

on run argv
  set f to item 1 of argv as alias
  tell application "Finder"
    if exists file f then
      tell application "TextEdit"
        activate        
          open f
      end tell
    end if
  end tell
end run

