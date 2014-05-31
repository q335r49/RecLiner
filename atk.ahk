#NoEnv
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
StringCaseSense, Off

if !FileExist("atk.ini") {
	FileAppend,
	( LTrim
		[main]
		;Hotkey=#s
		;   Examples: ^t (control t) !f5 (alt f5) +f6 (shift f6) See http://www.autohotkey.com/docs/Hotkeys.htm for further documenation (Default #s)
		;MinLength=14
		;   Strings shorter than this length will not be stored in the archive (default 14)
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
ctrC :=chr(3)
ctrV :=chr(22)
dict :=Object()
size :=0
if !FileExist("atk.log")
	MsgBox % "Warning: `n" . A_ScriptDir . "\atk.log not found!`n`nTo save log between sessions, use " . %mainHotkey% . " Ctrl-W"
else {
	Loop, Read, atk.log
		dict[size++]:=A_LoopReadLine
	MsgBox % size . " lines loaded from " . A_ScriptDir . "\atk.log"
}
presets=
Loop % size>10? 10 : size
	presets.="`nf" . A_Index . " " . (StrLen(dict[A_Index])>50? SubStr(dict[A_Index],1,50) . " ..." : dict[A_Index-1]) 
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
			else if (A_LoopField = "#")
				out.="{#}"
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
ToolTip,? :%presets%`n^edit ^help ^reload ^v:paste ^write e^xit up:prev dn:next,10,10
CurrentEntry=
keyarr := Object()
pointer := size
matches=1
Loop
{
	Input, char, M L1, {enter}{esc}{bs}{f1}{f2}{f3}{f4}{f5}{f6}{f7}{f8}{f9}{f10}{up}{down}{tab}
	if ErrorLevel=EndKey:Backspace
		StringTrimRight, CurrentEntry, CurrentEntry, 1
	else if ErrorLevel=EndKey:Up
	{	matches=0
		pointer:=pointer>0? pointer-1 : 0
		CurrentEntry:=dict[pointer]
	}
	else if ErrorLevel=EndKey:Down
	{	matches=0
		pointer:=pointer<size-1? pointer+1 : size-1
		CurrentEntry:=dict[pointer]
	}
	else if ErrorLevel!=Max
		break
	else if (char>ctrZ)
		CurrentEntry.=char
	else if (char=ctrV)
		CurrentEntry=%clipboard%
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
		Log := FileOpen("atk.log","w `r`n")
		for key,value in dict
			Log.WriteLine(value)
		Log.close()
		MsgBox % size . " lines written to " . A_ScriptDir . "\atk.log"
		Tooltip
		Run, atk.log
		return
	} else if (char=ctrH) {
		ToolTip
		msgbox,
		( LTrim
			Universal command history allows quick access to everything you've typed!
			Hotkey: %mainHotkey%`n
			- On enter or esc the preceding typed text will be stored as a 'command line' entry
			- Pressing the hotkey will search the history.
			- When editing atk.log, use "{enter}" to send a line break and "{!}" to send "!" ("!" is reserved for alt)
			- Only lines longer than 14 characters will be stored (redefine in settings)
			- To change the hotkey and other settings, uncomment lines in atk.ini (automatically created)
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
	matches:=1
	print=? : %CurrentEntry%
	if CurrentEntry
	{
		for key,value in dict {
			StringGetPos,pos,value,%CurrentEntry%
			if pos!=-1
			{	keyarr[matches] := key
				len:=StrLen(value)
				print.="`nf" . matches . " " . (len<50? value : pos+30>len? "..." . SubStr(value,-50) : pos>25? SubStr(value,1,10) . "..." . SubStr(value,pos-10,50) . "..." : SubStr(value,1,50) . "...")
				if (++matches>10)
					break
			}
		}
		Tooltip, % matches>1? print : print . "`n(no matches)",10,10
	} else
		Tooltip,? : %presets%,10,10
}
if ErrorLevel=EndKey:F1
	Send, % matches>1? dict[keyarr[1]] : dict[0]
else if ErrorLevel=EndKey:F2
	Send, % matches>2? dict[keyarr[2]] : dict[1]
else if ErrorLevel=EndKey:F3
	Send, % matches>3? dict[keyarr[3]] : dict[2]
else if ErrorLevel=EndKey:F4
	Send, % matches>4? dict[keyarr[4]] : dict[3]
else if ErrorLevel=EndKey:F5
	Send, % matches>5? dict[keyarr[5]] : dict[4]
else if ErrorLevel=EndKey:F6
	Send, % matches>6? dict[keyarr[6]] : dict[5]
else if ErrorLevel=EndKey:F7
	Send, % matches>7? dict[keyarr[7]] : dict[6]
else if ErrorLevel=EndKey:F8
	Send, % matches>8? dict[keyarr[8]] : dict[7]
else if ErrorLevel=EndKey:F9
	Send, % matches>9? dict[keyarr[9]] : dict[8]
else if ErrorLevel=EndKey:F10
	Send, % matches>10? dict[keyarr[10]] : dict[9]
else if ErrorLevel!=EndKey:Escape
{	if matches>1
		Send,% dict[keyarr[1]]
	else {
		Send,% CurrentEntry
		dict[size]:=CurrentEntry
		size++
	}
}
Tooltip
return
