#NoEnv
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

if !FileExist("atk.ini") {
	FileAppend,
(
;[main]
;Hotkey=#s
;Examples: ^t (control t) !f5 (alt f5) +f6 (shift f6) See http://www.autohotkey.com/docs/Hotkeys.htm for further documenation
;Default if none specified: #s

;MinLength=14
;Strings shorter than this length will not be stored in the archive
), atk.ini
	mainHotkey="#s"
	min_chars=14
} else {
	IniRead, mainHotkey, atk.ini, main, Hotkey, #s
	IniRead, min_chars, atk.ini, main, MinLength, 14
}
Hotkey,%mainHotkey%,StartCompletion
shDel:=chr(127)
ctrR :=chr(18)
ctrW :=chr(23)
ctrH :=chr(8)
ctrA :=chr(1)
ctrE :=chr(5)
ctrX :=chr(24)
ctrZ :=chr(26)
dict :=Object()
size :=0
if !FileExist("atk.log")
	MsgBox % "Warning: `n" . A_ScriptDir . "\atk.log not found!`n`nTo save log between sessions, use " . %mainHotkey% . " Ctrl-W"
else {
	Loop, Read, atk.log
		dict[size++]:=A_LoopReadLine
	MsgBox % size . " lines loaded from " . A_ScriptDir . "\atk.log"
}
Loop {
	Input, k, V M, {enter}{esc}
	if (StrLen(k)>min_chars) {
		out=
		Loop,Parse,k
		{
			if (A_LoopField = shDel) {
				out := RTrim(out)
				StringGetPos,pos,out,%A_Space%,R1
				if !ErrorLevel
					StringLeft,out,out,% pos+1
			} else if (A_LoopField = "!")
				out.="{!}"
			else if (A_LoopField = ctrH)
				StringTrimRight,out,out,1
			else if (A_LoopField = ctrA)
				out=
			else
				out.=A_LoopField
		}
		dict[size]:=out
		size++
	}
}

StartCompletion:
	ToolTip, Enter text or ^Editlog ^Help ^Reload ^Writelog e^Xit f1 f2 f3: first 3 lines
	matches=0
	index=1
	best=
	CurrentEntry=
	Loop
	{
		Input, char, M L1, {enter}{esc}{bs}{f1}{f2}{f3}
		if ErrorLevel=EndKey:Backspace
			StringTrimRight, CurrentEntry, CurrentEntry, 1
		else if ErrorLevel!=Max
			break
		else if (char>ctrZ)
			CurrentEntry.=char
		else if (char=ctrW) { 
			Log := FileOpen("atk.log","w `r`n")
			for key,value in dict
				Log.WriteLine(value)
			Log.close()
			MsgBox % size . " lines written to " . A_ScriptDir . "\atk.log"
			Tooltip
			return
		} else if (char=ctrR)
			reload
		else if (char=ctrE) {
			Run, atk.log
			ToolTip
			return
		} else if (char=ctrH) {
			ToolTip
			msgbox,
			( LTrim
				Autotextkeeper lets you store and retreive everything you've typed!
				Hotkey: %mainHotkey%`n
				- On enter or esc the text just typed will be stored as a history entry
				- The hotkey will search the history.
				- Press hotkey f1, hotkey f2, or hotkey f3 to send the first 3 lines
				- When editing atk.log, use "{enter}" to send a line break and "{!}" to send "!" ("!" is reserved for alt)
				- Only lines longer than 14 characters will be stored (redefine in settings)
				- To change the hotkey and other settings, uncomment lines in atk.ini, which should be automatically by the script
			)
			return
		} else if (char=ctrX) {
			MsgBox, 4,, Write to log?
			IfMsgBox, Yes
			{
				Log := FileOpen("atk.log","w `r`n")
				for key,value in dict
					Log.WriteLine(value)
				Log.close()
				MsgBox % size . " lines written to " . A_ScriptDir . "\atk.log"
			}
			ExitApp
		}
		matchstring=
		for key,value in dict {
			StringGetPos,pos,value,%CurrentEntry%
			if pos=-1
			{
				best=
				bestpos:=pos
				matchstring=
			}
			else if pos
			{
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
			Tooltip,% CurrentEntry . ":`n(no matches)"
		else if (StrLen(best)>50)
			Tooltip,% CurrentEntry . ":`n" . (bestpos+50>StrLen(best)? "..." . SubStr(best,-50) : SubStr(best,bestpos,50) . "...") . matchstring
		else
			Tooltip,% CurrentEntry . ":`n" . best . matchstring
	}
	if ErrorLevel=EndKey:F1
		Send, % dict[0]
	else if ErrorLevel=EndKey:F2
		Send, % dict[1]
	else if ErrorLevel=EndKey:F3
		Send, % dict[2]
	if ErrorLevel!=EndKey:Escape
		Send, %best%
	Tooltip
return
