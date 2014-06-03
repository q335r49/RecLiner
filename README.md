#RecLiner
Record and recall every line you type! On <kbd>enter</kbd>, <kbd>esc</kbd>, or <kbd>tab</kbd>, the line just typed will be stored in a searchable history.
* Remember addresses, serial numbers, usernames!
* Have a unified history for command line interfaces!
* Log online chats!
* Build a library of often used quotes!
* Check out the **[Youtube video](https://www.youtube.com/watch?v=iOPYzTMHf_0)**!

####Startup
Install [Autohotkey](http://www.autohotkey.com/) and run [recliner.ahk](https://raw.githubusercontent.com/q335r49/RecLiner/master/recliner.ahk).

####Searching
* Press the hotkey (default: <kbd>f4</kbd>) to bring up a search prompt.
* Pressing <kbd>f1</kbd> .. <kbd>f12</kbd> on an empty prompt will return the first 12 lines, the 'presets'.
* Enter text at the prompt and press <kbd>f1</kbd> .. <kbd>f12</kbd> to set presets.
* Without search results, the arrow keys will navigate the history starting with the last returned entry. With search results, navigation starts at the first search result.
* More than 12 presets can be set. The inaccessible presets can serve to differentiate between autotext and log. Presets appear first in recliner.log and search results.

####Editing recliner.log
* Use "{enter}" to send a line break and "{!}" to send "!".  See [www.autohotkey.com/docs/commands/Send.htm](www.autohotkey.com/docs/commands/Send.htm) for a complete list of special characters.
* Only lines longer than 14 characters will be stored.
