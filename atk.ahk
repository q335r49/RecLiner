#NoEnv
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

if !FileExist("atk.ini")
{
FileAppend,
(
;Uncomment to change settings

;[main]
;Hotkey=#s
;See http://www.autohotkey.com/docs/Hotkeys.htm for further documenation
;Examples: ^t (control t) !f5 (alt f5) +f6 (shift f6)
;Default if none specified: #s

;MinLength=14
;Strings shorter than this length will not be stored in the archive
), atk.ini
	mainHotkey="#s"
	min_chars=14
} else {
	IniRead, mainHotkey, atk.ini, main, Hotkey, #s
	IniRead, min_chars, atk.ini, main, Hotkey, 14
}

Hotkey,%mainHotkey%,StartCompletion

ASC127:=chr(127)
ASC8  :=chr(8)
ASC1  :=chr(1)

dict:=Object()
size=0
if !FileExist("atk.log")
	MsgBox % "Warning: `n" . A_ScriptDir . "\atk.log not found!`n`nTo save log between sessions, right click on tray menu and select 'Write log'"
else {
	Loop, Read, atk.log
	{
		dict[size]:=A_LoopReadLine
		size++
	}
	MsgBox % size . " lines read from " . A_ScriptDir . "\atk.log"
}
Menu, tray, NoStandard
Menu, tray, Add, Help, Help
Menu, tray, Add, Write log to atk.log, Save
Menu, tray, Add, Open atk.log, OpenLog
Menu, tray, Add,
Menu, tray, Add, Reload, Reload
Menu, tray, Add, Pause, Pause
Menu, tray, Add, Exit, Exit
Gosub, StartLog
return





Reload:
	reload
Exit:
	ExitApp
Pause:
	Pause
return

!f1::Send, % dict[0]
!f2::Send, % dict[1]
!f3::Send, % dict[2]

OpenLog:
	Run, atk.log
return

Save:
	Log := FileOpen("atk.log","w `r`n")
	for key,value in dict
		Log.WriteLine(value)
	Log.close()
	MsgBox % size . " lines written to " . A_ScriptDir . "\atk.log"
return

Help:
MsgBox,
(
AUTOTEXTKEEPER lets quickly retreive everything you have typed!
Every time you press ENTER or ESC the text you just typed will be stored as an entry in the history.
Win-S will search through history entries and ENTER or TAB will input the best match!

Tips:
- Right click on the tray icon and selet "Write log" to write to atk.log
- Press alt-f1, alt-f2, or alt-f3 to send the first 3 lines.
- Note: when editing atk.log, you must use "{enter}" to send a line break and "{!}" to send "!" ("!" is reserved for alt).
- To change the hotkey and other settings, uncomment lines in atk.ini (file should be automatically created in the same directory)
)
return

StartCompletion:
	ToolTip, (Enter fragment),10,7
	matches=0
	index=1
	best=
	CurrentEntry=
	Loop
	{
		Input, char, L1, {enter}{esc}{bs}
		if ErrorLevel=EndKey:Backspace
			StringTrimRight, CurrentEntry, CurrentEntry, 1
		else if ErrorLevel!=Max
			break
		CurrentEntry.=char
		matchstring=
		for key,value in dict
		{
			StringGetPos,pos,value,%CurrentEntry%
			if pos=-1
			{
				best=
				bestpos:=pos
				matchstring=
			}
			else if pos {
				if !best
				{
					bestpos:=pos
					best:=value
				} else if (StrLen(value)>50)
					matchstring.=pos+50>StrLen(value)? ("`n..." . SubStr(value,-50)) : ("`n" . SubStr(value,pos,50) . "...")
			    else
					matchstring.="`n" . value
				matches++
				if matches>5
					break
			} else {
				bestpos:=1
				best:=value
				break
			}
		}
		if (!matches and !best)
			Tooltip,% CurrentEntry ":`n(no matches)",10,7
		else if (StrLen(best)>50) {
			Tooltip,% CurrentEntry . ":`n" . (bestpos+50>StrLen(best)? "..." . SubStr(best,-50) : SubStr(best,bestpos,50) . "...") . matchstring,10,7 
		} else
			Tooltip,% CurrentEntry . ":`n" . best . matchstring,10,7
	}
	if ErrorLevel!=EndKey:Escape
		Send, %best%
	Tooltip
return

StartLog:
	Loop
	{
		Input, k, V M, {enter}{esc}{tab}
		if (ErrorLevel = "EndKey:Enter" and  StrLen(k)>min_chars) {
			out=
			Loop,Parse,k
			{
				if (A_LoopField = ASC127) {
					out := RTrim(out)
					StringGetPos,pos,out,%A_Space%,R1
					if !ErrorLevel
						StringLeft,out,out,% pos+1
				} else if (A_LoopField = "!")
					out.="{!}"
				else if (A_LoopField = ASC8)
					StringTrimRight,out,out,1
				else if (A_LoopField = ASC1)
					out=
				else
					out.=A_LoopField
			}
			if out
			{
				dict[size]:=out
				size++
			}
		}
	}
return
