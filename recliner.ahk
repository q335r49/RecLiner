#NoEnv
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
StringCaseSense, Off

if !FileExist("recliner.ini") {
	FileAppend,
	( LTrim
		[main]
		;Hotkey=#s
		;   Examples: ^t (control t) !f5 (alt f5) +f6 (shift f6) #s (windows s) See http://www.autohotkey.com/docs/Hotkeys.htm for further documenation (Default f4)
		;MinLength=14
		;   Strings shorter than this length will not be stored in the archive (default 14)
	), recliner.ini
	mainHotkey=f4
	min_chars=14
} else {
	IniRead, mainHotkey, recliner.ini, main, Hotkey, f4
	IniRead, min_chars, recliner.ini, main, MinLength, 14
}
Hotkey,%mainHotkey%,StartCompletion
shDel:=chr(127)
ctrW:=chr(23)
ctrH:=chr(8)
ctrA:=chr(1)
ctrZ:=chr(26)
ctrV:=chr(22)
log:=Object()
pre:=Object()
logL:=0
preL:=0
logsection=
Loop, Read, recliner.log
	if logsection
		log[logL++]:=A_LoopReadLine
	else if A_LoopReadLine = ### End Presets ###
		logsection=1
	else
		pre[preL++]:=A_LoopReadLine
MsgBox % logL+preL . " lines read from " . A_ScriptDir
while preL < 10
	pre[preL++]:="Preset " . preL
presets=
Loop 10
	presets.="`nf" . A_Index . " " . (StrLen(pre[A_Index])>50? SubStr(pre[A_Index],1,50) . " ..." : pre[A_Index-1]) 
Menu, Tray, NoStandard
Menu, Tray, add, Current Hotkey: %mainHotkey%, MenuNull
Menu, Tray, add, &Edit log..., MenuEditLog
Menu, Tray, add, &Edit settings..., MenuEditSettings
Menu, Tray, add, &Reload from log, MenuReload
Menu, Tray, add
Menu, Tray, add, &Exit..., MenuExit
Loop {
	Input, k, V M, {enter}{esc}{tab}
	if (StrLen(k)>min_chars) {
		out=
		Loop,Parse,k
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
		log[logL++]:=out
	}
}

WriteLog:
	File := FileOpen("recliner.log","w `r`n")
	for key,value in pre
		File.WriteLine(value)
	File.WriteLine("### End Presets ###")
	for key,value in log
		File.WriteLine(value)
	File.close()
	MsgBox % logL+preL . " lines written to %A_ScriptDir%\recliner.log"
	return
MenuReload:
	reload
MenuNull:
	return
MenuEditLog:
	Gosub, WriteLog
	Run, recliner.log
	return
MenuEditSettings:
	Run, recliner.ini
	return
MenuExit:
	MsgBox, 3,, Write to log?
	IfMsgBox, Yes
		Gosub, WriteLog
	IfMsgBox, Cancel
		return
	ExitApp

StartCompletion:
ToolTip,Enter search (^Help ^V:paste ^Write)%presets%,10,10
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
			RecLiner lets you record and recall every line you type! When you press Enter, Esc, or Tab,
			the line just typed will be stored in a searchable history. Useful for:
			* Remembering addresses, commands, or form data
			* A universal command line history for various command line interfaces
			* Keeping a log of online chats
			* Building a library of often used fragments or quotes`n
			Pressing the hotkey will open a search prompt. Pressing f1 ... f10 on an empty prompt will
			send the first 10 entries, the 'presets'. You can modify presets by typing or pasting text
			into the search prompt and hitting the appropriate function key. More than 10 presets can be
			set, and since presets appear first in the log and in search results this may be a good way
			to differentiate between autotext and log entries.`n
			Some tips
			* When editing recliner.log, use {enter} to send a line break and {!} to send "!".
			See www.autohotkey.com/docs/commands/Send.htm for a list of special characters.
			* Only lines longer than %min_chars% characters will be stored.
			* To change the settings, edit the automatically generated init file recliner.ini
		),10,10
		continue
	} else if (char=ctrV)
		CurrentEntry=%clipboard%
	else if (char=ctrW) { 
		Gosub, WriteLog
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
		Tooltip, % matches>1? print : print . "`n(no matches)`nf1..f10 to add to presets`nenter: append to presets & send`ntab: append to presets",10,10
	} else
		Tooltip,%presets%,10,10
}
if ErrorLevel=EndKey:F1
	if (matches>1 || !CurrentEntry)
		Send, % matches>1? keyarr[1] : pre[0]
	else {
		pre[0]:=CurrentEntry
		presets=
		Loop 10
			presets.="`nf" . A_Index . " " . (StrLen(pre[A_Index])>50? SubStr(pre[A_Index],1,50) . " ..." : pre[A_Index-1]) 
		GoSub, StartCompletion
	}
else if ErrorLevel=EndKey:F2
	if (matches>1 || !CurrentEntry)
		Send, % matches>2? keyarr[2] : pre[1]
	else {
		pre[1]:=CurrentEntry
		presets=
		Loop 10
			presets.="`nf" . A_Index . " " . (StrLen(pre[A_Index])>50? SubStr(pre[A_Index],1,50) . " ..." : pre[A_Index-1]) 
		GoSub, StartCompletion
	}
else if ErrorLevel=EndKey:F3
	if (matches>1 || !CurrentEntry)
		Send, % matches>3? keyarr[3] : pre[2]
	else {
		pre[2]:=CurrentEntry
		presets=
		Loop 10
			presets.="`nf" . A_Index . " " . (StrLen(pre[A_Index])>50? SubStr(pre[A_Index],1,50) . " ..." : pre[A_Index-1]) 
		GoSub, StartCompletion
	}
else if ErrorLevel=EndKey:F4
	if (matches>1 || !CurrentEntry)
		Send, % matches>4? keyarr[4] : pre[3]
	else {
		pre[3]:=CurrentEntry
		presets=
		Loop 10
			presets.="`nf" . A_Index . " " . (StrLen(pre[A_Index])>50? SubStr(pre[A_Index],1,50) . " ..." : pre[A_Index-1]) 
		GoSub, StartCompletion
	}
else if ErrorLevel=EndKey:F5
	if (matches>1 || !CurrentEntry)
		Send, % matches>5? keyarr[5] : pre[4]
	else {
		pre[4]:=CurrentEntry
		presets=
		Loop 10
			presets.="`nf" . A_Index . " " . (StrLen(pre[A_Index])>50? SubStr(pre[A_Index],1,50) . " ..." : pre[A_Index-1]) 
		GoSub, StartCompletion
	}
else if ErrorLevel=EndKey:F6
	if (matches>1 || !CurrentEntry)
		Send, % matches>6? keyarr[6] : pre[5]
	else {
		pre[5]:=CurrentEntry
		presets=
		Loop 10
			presets.="`nf" . A_Index . " " . (StrLen(pre[A_Index])>50? SubStr(pre[A_Index],1,50) . " ..." : pre[A_Index-1]) 
		GoSub, StartCompletion
	}
else if ErrorLevel=EndKey:F7
	if (matches>1 || !CurrentEntry)
		Send, % matches>7? keyarr[7] : pre[6]
	else {
		pre[6]:=CurrentEntry
		presets=
		Loop 10
			presets.="`nf" . A_Index . " " . (StrLen(pre[A_Index])>50? SubStr(pre[A_Index],1,50) . " ..." : pre[A_Index-1]) 
		GoSub, StartCompletion
	}
else if ErrorLevel=EndKey:F8
	if (matches>1 || !CurrentEntry)
		Send, % matches>8? keyarr[8] : pre[7]
	else {
		pre[7]:=CurrentEntry
		presets=
		Loop 10
			presets.="`nf" . A_Index . " " . (StrLen(pre[A_Index])>50? SubStr(pre[A_Index],1,50) . " ..." : pre[A_Index-1]) 
		GoSub, StartCompletion
	}
else if ErrorLevel=EndKey:F9
	if (matches>1 || !CurrentEntry)
		Send, % matches>9? keyarr[9] : pre[8]
	else {
		pre[8]:=CurrentEntry
		presets=
		Loop 10
			presets.="`nf" . A_Index . " " . (StrLen(pre[A_Index])>50? SubStr(pre[A_Index],1,50) . " ..." : pre[A_Index-1]) 
		GoSub, StartCompletion
	}
else if ErrorLevel=EndKey:F10
	if (matches>1 || !CurrentEntry)
		Send, % matches>10? keyarr[10] : pre[9]
	else {
		pre[9]:=CurrentEntry
		presets=
		Loop 10
			presets.="`nf" . A_Index . " " . (StrLen(pre[A_Index])>50? SubStr(pre[A_Index],1,50) . " ..." : pre[A_Index-1]) 
		GoSub, StartCompletion
	}
else if ErrorLevel!=EndKey:Escape
	if matches>1
		Send,% keyarr[1]
	else {
		if ErrorLevel=EndKey:Enter
			Send,% CurrentEntry
		pre[preL++]:=CurrentEntry
		if preL<=10
			presets.="`nf" . preL . " " . CurrentEntry
	}
Tooltip
return
