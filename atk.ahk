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
ctrZ :=chr(26)
ctrV :=chr(22)
log :=Object()
snp:=Object()
logsize :=0
presize :=0
Loop, Read, atk.log
	log[logsize++]:=A_LoopReadLine
Loop, Read, snippets.log
	snp[presize++]:=A_LoopReadLine
MsgBox %logsize% lines read from %A_ScriptDir%\atk.log`n%presize% lines read from %A_ScriptDir%\snippets.log
snippets=
Loop % presize>10? 10 : presize
	snippets.="`nf" . A_Index . " " . (StrLen(snp[A_Index])>50? SubStr(snp[A_Index],1,50) . " ..." : snp[A_Index-1]) 
Menu, Tray, NoStandard
Menu, Tray, add, &Edit log..., MenuEditLog
Menu, Tray, add, &Edit snippets..., MenuEditPre
Menu, Tray, add, &Reload from log, MenuReload
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

MenuReload:
	reload
MenuEditPre:
MenuEditLog:
	File := FileOpen("atk.log","w `r`n")
	for key,value in log
		File.WriteLine(value)
	File.close()
	File := FileOpen("snippets.log","w `r`n")
	for key,value in snp
		File.WriteLine(value)
	File.close()
	MsgBox %logsize% lines written to %A_ScriptDir%\atk.log`n%presize% lines written to %A_ScriptDir%\snippets.log
	Run, % A_ThisMenuItem="&Edit snippets..."? "snippets.log" : "atk.log"
	return
MenuExit:
	MsgBox, 3,, Write to log?
	IfMsgBox, Yes
	{
		File := FileOpen("atk.log","w `r`n")
		for key,value in log
			File.WriteLine(value)
		File.close()
		File := FileOpen("snippets.log","w `r`n")
		for key,value in snp
			File.WriteLine(value)
		File.close()
		MsgBox % logsize . " lines written to " . A_ScriptDir . "\atk.log`n" . presize . " lines written to " . A_ScriptDir . "\snippets.log"
	}
	IfMsgBox, Cancel
		return
	ExitApp

StartCompletion:
ToolTip,Enter search (^Help ^V:paste ^Write)%snippets%,10,10
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
	else if (char=ctrH) {
		Tooltip,
		( LTrim
			Universal Command History lets you quickly access everything you've typed! Every
			time you press ENTER, ESC, or TAB, the line just typed will be stored in the history,
			which you can search by pressing the hotkey. (Current hotkey: %mainHotkey%)`n
			Tips: # When editing atk.log, use "{enter}" to send a line break and "{!}" to send "!".
			See www.autohotkey.com/docs/commands/Send.htm for a list of special characters.
			# Only lines longer than %min_chars% characters will be stored.
			# To change the settings, edit the automatically generated init file atk.ini
			# Snippets allow for an easy way to access the first 10 entries and provide a way
			to keep frequently typed text separate from log entries. Snippets can be set simply
			by typing it into the search prompt or by editing snippets.log
		),10,10
		continue
	} else if (char=ctrV)
		CurrentEntry=%clipboard%
	else if (char=ctrW) { 
		File := FileOpen("atk.log","w `r`n")
		for key,value in log
			File.WriteLine(value)
		File.close()
		File := FileOpen("snippets.log","w `r`n")
		for key,value in snp
			File.WriteLine(value)
		File.close()
		Tooltip
		MsgBox %logsize% lines written to %A_ScriptDir%\atk.log`n%presize% lines written to %A_ScriptDir%\snippets.log
		return
	}
	matches:=1
	print=%CurrentEntry%
	if CurrentEntry
	{
		for key,value in snp {
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
		{
			for key,value in log {
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
		Tooltip, % matches>1? print : print . "`n(no matches)`nENTER: add to snippets & send`nTAB: add to snippets",10,10
	} else
		Tooltip,%snippets%,10,10
}
if ErrorLevel=EndKey:F1
	Send, % matches>1? keyarr[1] : snp[0]
else if ErrorLevel=EndKey:F2
	Send, % matches>2? keyarr[2] : snp[1]
else if ErrorLevel=EndKey:F3
	Send, % matches>3? keyarr[3] : snp[2]
else if ErrorLevel=EndKey:F4
	Send, % matches>4? keyarr[4] : snp[3]
else if ErrorLevel=EndKey:F5
	Send, % matches>5? keyarr[5] : snp[4]
else if ErrorLevel=EndKey:F6
	Send, % matches>6? keyarr[6] : snp[5]
else if ErrorLevel=EndKey:F7
	Send, % matches>7? keyarr[7] : snp[6]
else if ErrorLevel=EndKey:F8
	Send, % matches>8? keyarr[8] : snp[7]
else if ErrorLevel=EndKey:F9
	Send, % matches>9? keyarr[9] : snp[8]
else if ErrorLevel=EndKey:F10
	Send, % matches>10? keyarr[10] : snp[9]
else if ErrorLevel!=EndKey:Escape
{	if matches>1
		Send,% keyarr[1]
	else {
		if ErrorLevel=EndKey:Enter
			Send,% CurrentEntry
		snp[presize++]:=CurrentEntry
		if presize<=10
			snippets.="`nf" . presize . " " . CurrentEntry
	}
}
Tooltip
return
