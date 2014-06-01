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
ctrW :=chr(23)
ctrH :=chr(8)
ctrA :=chr(1)
ctrX :=chr(24)
ctrZ :=chr(26)
ctrV :=chr(22)
log :=Object()
pre :=Object()
logsize :=0
presize :=0
Loop, Read, atk.log
	log[logsize++]:=A_LoopReadLine
Loop, Read, atkpresets.log
	pre[presize++]:=A_LoopReadLine
MsgBox %logsize% lines read from %A_ScriptDir%\atk.log`n%presize% lines read from %A_ScriptDir%\atkpresets.log
presets=
Loop % presize>10? 10 : presize
	presets.="`nf" . A_Index . " " . (StrLen(pre[A_Index])>50? SubStr(pre[A_Index],1,50) . " ..." : pre[A_Index-1]) 
Menu, Tray, NoStandard
Menu, Tray, add, &Help, MenuHelp
Menu, Tray, add, &Reload, MenuReload
Menu, Tray, add
Menu, Tray, add, &Edit log..., MenuEditLog
Menu, Tray, add, &Edit presets..., MenuEditPre
Menu, Tray, add
Menu, Tray, add, &Exit..., MenuExit
Loop {
	Input, k, V M, {enter}{esc}{tab}
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
		log[logsize++]:=out
	}
}

MenuHelp:
	MsgBox,
	( LTrim
		Universal command history allows quick access to everything you've typed!
		Hotkey: %mainHotkey%`n
		- On enter, esc, or tab the preceding typed text will be stored as a 'command line' entry
		- Pressing the hotkey will search the history.
		- When editing atk.log, use "{enter}" to send a line break and "{!}" to send "!" ("!" is reserved for alt)
		- Only lines longer than 14 characters will be stored (redefine in settings)
		- To change the hotkey and other settings, uncomment lines in atk.ini (automatically created)
	)
	return
MenuReload:
	reload
MenuEditPre:
MenuEditLog:
	File := FileOpen("atk.log","w `r`n")
	for key,value in log
		File.WriteLine(value)
	File.close()
	File := FileOpen("atkpresets.log","w `r`n")
	for key,value in pre
		File.WriteLine(value)
	File.close()
	MsgBox %logsize% lines written to %A_ScriptDir%\atk.log`n%presize% lines written to %A_ScriptDir%\atkpresets.log
	Run, % A_ThisMenuItem="&Edit presets..."? "atkpresets.log" : "atk.log"
	return
MenuExit:
	MsgBox, 3,, Write to log?
	IfMsgBox, Yes
	{
		File := FileOpen("atk.log","w `r`n")
		for key,value in log
			File.WriteLine(value)
		File.close()
		File := FileOpen("atkpresets.log","w `r`n")
		for key,value in pre
			File.WriteLine(value)
		File.close()
		MsgBox % logsize . " lines written to " . A_ScriptDir . "\atk.log`n" . presize . " lines written to " . A_ScriptDir . "\atkpresets.log"
	}
	IfMsgBox, Cancel
		return
	ExitApp

StartCompletion:
ToolTip,Enter search (^V:paste ^Write)%presets%,10,10
CurrentEntry=
keyarr := Object()
matches=1
Loop
{
	Input, char, M L1, {enter}{esc}{bs}{f1}{f2}{f3}{f4}{f5}{f6}{f7}{f8}{f9}{f10}{up}{down}{tab}
	if ErrorLevel=EndKey:Backspace
		StringTrimRight, CurrentEntry, CurrentEntry, 1
	else if ErrorLevel!=Max
		break
	else if (char>ctrZ)
		CurrentEntry.=char
	else if (char=ctrV)
		CurrentEntry=%clipboard%
	else if (char=ctrW) { 
		File := FileOpen("atk.log","w `r`n")
		for key,value in log
			File.WriteLine(value)
		File.close()
		File := FileOpen("atkpresets.log","w `r`n")
		for key,value in pre
			File.WriteLine(value)
		File.close()
		MsgBox %logsize% lines written to %A_ScriptDir%\atk.log`n%presize% lines written to %A_ScriptDir%\atkpresets.log
		Tooltip
		return
	}
	matches:=1
	print=%CurrentEntry%
	if CurrentEntry
	{
		for key,value in pre {
			StringGetPos,pos,value,%CurrentEntry%
			if pos!=-1
			{	keyarr[matches] := value
				len:=StrLen(value)
				print.="`nf" . matches . " " . (len<50? value : pos+30>len? "..." . SubStr(value,-50) : pos>25? SubStr(value,1,10) . "..." . SubStr(value,pos-10,50) . "..." : SubStr(value,1,50) . "...")
				if (++matches>10)
					break
			}
		}
		if matches<=10
		{	for key,value in log {
				StringGetPos,pos,value,%CurrentEntry%
				if pos!=-1
				{	keyarr[matches] := value
					len:=StrLen(value)
					print.="`nf" . matches . " " . (len<50? value : pos+30>len? "..." . SubStr(value,-50) : pos>25? SubStr(value,1,10) . "..." . SubStr(value,pos-10,50) . "..." : SubStr(value,1,50) . "...")
					if (++matches>10)
						break
				}
			}
		}
		Tooltip, % matches>1? print : print . "`n(no matches)",10,10
	} else
		Tooltip,%presets%,10,10
}
if ErrorLevel=EndKey:F1
	Send, % matches>1? keyarr[1] : pre[0]
else if ErrorLevel=EndKey:F2
	Send, % matches>2? keyarr[2] : pre[1]
else if ErrorLevel=EndKey:F3
	Send, % matches>3? keyarr[3] : pre[2]
else if ErrorLevel=EndKey:F4
	Send, % matches>4? keyarr[4] : pre[3]
else if ErrorLevel=EndKey:F5
	Send, % matches>5? keyarr[5] : pre[4]
else if ErrorLevel=EndKey:F6
	Send, % matches>6? keyarr[6] : pre[5]
else if ErrorLevel=EndKey:F7
	Send, % matches>7? keyarr[7] : pre[6]
else if ErrorLevel=EndKey:F8
	Send, % matches>8? keyarr[8] : pre[7]
else if ErrorLevel=EndKey:F9
	Send, % matches>9? keyarr[9] : pre[8]
else if ErrorLevel=EndKey:F10
	Send, % matches>10? keyarr[10] : pre[9]
else if ErrorLevel!=EndKey:Escape
{	if matches>1
		Send,% keyarr[1]
	else {
		Send,% CurrentEntry
		pre[presize++]:=CurrentEntry
		if presize<=10
			presets.="`nf" . presize . " " . CurrentEntry
	}
}
Tooltip
return
