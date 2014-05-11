#Autotextkeeper
* Autotextkeeper lets retrieve everything you've recently typed!
* Every time you press <kbd>enter</kbd> or <kbd>esc</kbd> the text you just typed will be stored in the history.
* Pressing <kbd>win</kbd>+<kbd>s</kbd> will search the entries. Lines that begin with the searched text are prioritized.
* Check out the **[Youtube video](https://www.youtube.com/watch?v=buHfIfkn3JM&feature=youtu.be)**!

####Startup
Install [Autohotkey](http://www.autohotkey.com/) and run [atk.ahk](https://github.com/q335r49/Autotextkeeper/raw/master/atk.ahk).

####Tips
- Edit atk.log to manually edit entries.
- Edit atk.ini to manually change settings.
- Only lines longer than 14 characters will be stored. (Change in atk.ini)
- Press <kbd>hotkey</kbd> <kbd>f1</kbd>, <kbd>hotkey</kbd> <kbd>f2</kbd>, or <kbd>hotkey</kbd> <kbd>f3</kbd> to send the first 3 lines in atk.log
- When editing an entry, you must use "{enter}" to send a line break and "{!}" to send "!" (since the "!" is reserved for alt).
- You might want to occasionally trim atk.log to keep the most important entries
