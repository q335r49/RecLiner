#Autotextkeeper
* Autotextkeeper lets retrieve everything you've recently typed!
* Every time you press <kbd>enter</kbd> or <kbd>esc</kbd> the text you just typed will be stored in the history.
* Pressing <kbd>win</kbd>+<kbd>s</kbd> will search the entries.
* Check out the **[Youtube video](https://www.youtube.com/watch?v=buHfIfkn3JM&feature=youtu.be)**!

####Startup
Install [Autohotkey](http://www.autohotkey.com/) and run [atk.ahk](https://github.com/q335r49/Autotextkeeper/raw/master/atk.ahk).

####Tips
- Edit atk.log to manually edit entries.
- Edit atk.ini to manually change settings (automatically generated).
- Only lines longer than 14 characters will be stored. (Change in atk.ini)
- Press <kbd>hotkey</kbd> <kbd>f1</kbd... <kbd>f10</kbd> to send 'presets', the first N lines in atk.log
- When editing an entry, you must use "{enter}" to send a line break and "{!}" and "{#}" to send "!" and "#" (since the "!" is reserved for alt and # for the windows key).
- You might want to occasionally trim atk.log to keep the most important entries
