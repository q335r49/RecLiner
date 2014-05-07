#Autotextkeeper
Autotextkeeper lets retrieve everything you've recently typed!
* Every time you press <kbd>enter</kbd> or <kbd>esc</kbd> the text you just typed will be stored in the history.
* Pressing <kbd>win</kbd>+<kbd>s</kbd> will autocomplete from the entries. Lines that start with the searched text are prioritized.

####Startup
Install [Autohotkey](http://www.autohotkey.com/) and run [atk.ahk](https://github.com/q335r49/Autotextkeeper/raw/master/atk.ahk).

####Useage
- Right-click on the tray icon for help, to reload, exit, etc.
- Only lines longer than 14 characters will be stored.
- Edit atk.log to manually edit entries.
- Edit atk.ini to manually change settings.
- Press <kbd>alt</kbd>+<kbd>f1</kbd>, <kbd>alt</kbd>+<kbd>f2</kbd>, or <kbd>alt</kbd>+<kbd>f3</kbd> to send the first 3 lines in atk.log
- Note: when editing an entry, you must use "{enter}" to send a line break and "{!}" to send "!" (since the "!" is reserved for alt).
