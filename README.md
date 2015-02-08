#RecLiner
Record and recall lines that you have typed! On <kbd>enter</kbd>, <kbd>esc</kbd>, or <kbd>tab</kbd>, the line just typed will be stored in a searchable history.
* Remember addresses, serial numbers, usernames!
* Have a unified history for command line interfaces!
* Log online chats!
* Build a library of often used quotes!
* Check out the **[Youtube video](http://youtu.be/PIzkEBu4754)**!

####Startup
Install [Autohotkey 1.1.15+](http://ahkscript.org/download/) and run [recliner.ahk](https://raw.githubusercontent.com/q335r49/RecLiner/master/recliner.ahk).

####Searching
* Press the hotkey (default: <kbd>f4</kbd>) to bring up a search prompt.
* The arrow keys navigate the history starting with the first found entry (i.e., F1).
* Search by text or index number
* To send the next entry, press enter on a blank prompt.

####Tips
* Only lines longer than 2 characters will be stored (change MinLength in recliner.ini).
* To send special characters (such as line breaks), append the entry with '###'. For example, "###blah blah{!}{enter}blah" will send the two lines "blah blah!" and "blah". For a list of special characters, see [autohotkey help](http://www.autohotkey.com/docs/commands/Send.htm)
