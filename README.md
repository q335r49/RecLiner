#RecLiner
RecLiner lets you record and recall every line you type! When you press <kbd>enter</kbd>, <kbd>esc</kbd>, or <kbd>tab</kbd>, the line just typed will be stored in a searchable history. Useful for:
* Remembering addresses, commands, or form data
* A universal command line history for various command line interfaces
* Keeping a log of online chats
* Building a library of often used fragments or quotes

####Startup
Install [Autohotkey](http://www.autohotkey.com/) and run [atk.ahk](https://raw.githubusercontent.com/q335r49/RecLiner/master/recliner.ahk).

####Use
Press the hotkey (default <kbd>f4</kbd>) to search through all entries. Pressing <kbd>f1</kbd> ... <kbd>f10</kbd> on an empty prompt will send the first 10 entries, the 'presets'. You can modify presets by typing or pasting text into the search prompt and hitting the appropriate function key. More than 10 presets can be set, and since presets appear first in the log and in search results this may be a good way to differentiate between autotext and log entries.

####Tips
* When editing atk.log, use {enter} to send a line break and {!} to send "!".  See [www.autohotkey.com/docs/commands/Send.htm](www.autohotkey.com/docs/commands/Send.htm) for a list of special characters.
* Only lines longer than 14 characters will be stored.
* Check out the **[Youtube video](https://www.youtube.com/watch?v=buHfIfkn3JM&feature=youtu.be)**!
