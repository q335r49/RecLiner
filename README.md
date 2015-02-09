#RecLiner
Record and recall lines that you have typed!
* On <kbd>enter</kbd>, <kbd>esc</kbd>, or <kbd>tab</kbd>, the line just typed will be stored in a searchable history.
* **[Youtube Demo](http://youtu.be/oMZfaVSBeqw)**

####Startup
Install [Autohotkey 1.1.15+](http://ahkscript.org/download/) and run [recliner.ahk](https://raw.githubusercontent.com/q335r49/RecLiner/master/recliner.ahk).

####Searching
* Press the hotkey (default: <kbd>f4</kbd>) to bring up a search prompt.
* Navigate the history the arrow keys, starting with the first found entry (i.e., F1).
* Search by text or index number
* Press enter on a blank prompt to automatically send the next entry.

####Tips
* Only lines longer than 2 characters will be stored (change MinLength in recliner.ini).
* To send special characters (such as line breaks), append the entry with '###'. For example, "###blah blah{!}{enter}blah" will send the two lines "blah blah!" and "blah". For a list of special characters, see [autohotkey help](http://www.autohotkey.com/docs/commands/Send.htm)
