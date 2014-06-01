#NoEnv
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
StringCaseSense, Off
shDel:=chr(127)
ctrW:=chr(23)
ctrH:=chr(8)
ctrA:=chr(1)
ctrZ:=chr(26)
ctrV:=chr(22)

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
Hotkey,%mainHotkey%,uiLoop
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
MsgBox % logL . " log entries, " . preL . " preset entries read from " . A_ScriptDir . "\recliner.log"
while preL < 12
	pre[preL++]:="Preset " . preL
presets=
Loop 12
	presets.="`nf" . A_Index . " " . (StrLen(pre[A_Index])>50? SubStr(pre[A_Index],1,50) . " ..." : pre[A_Index-1]) 
Menu, Tray, NoStandard
Menu, Tray, add, Current Hotkey: %mainHotkey%, MenuEditSettings
Menu, Tray, add, &Edit log, MenuEditLog
Menu, Tray, add, &Reload from log, MenuReload
Menu, Tray, add
Menu, Tray, add, &Exit, MenuExit
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
	MsgBox % logL . " log entries, " . preL . " preset entries written to " . A_ScriptDir . "\recliner.log"
	return
MenuReload:
	reload
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

uiLoop:
ToolTip,Enter search (^Help ^V:paste ^Write)%presets%,10,10
Entry=
keyarr := Object()
Loop
{	Input, char, M L1, {enter}{esc}{bs}{f1}{f2}{f3}{f4}{f5}{f6}{f7}{f8}{f9}{f10}{up}{down}{tab}
	if ErrorLevel=EndKey:Backspace
		StringTrimRight, Entry, Entry, 1
	else if ErrorLevel!=Max
		break
	else if (char>ctrZ)
		Entry.=char
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
		),10,10
		continue
	} else if (char=ctrV)
		Entry=%clipboard%
	else if (char=ctrW) { 
		Gosub, WriteLog
		Tooltip
		return
	}
	if !Entry
	{	Tooltip,%presets%,10,10
		continue
	}
	matches:=1
	print=%Entry%
	for key,value in pre {
		StringGetPos,pos,value,%Entry%
		if (pos=-1)
			continue
		keyarr[matches] := value
		len:=StrLen(value)
		print.="`nf" . matches . " " . (len<50? value : pos+30>len? "..." . SubStr(value,-50) : pos>25? SubStr(value,1,10) . "..." . SubStr(value,pos-10,50) . "..." : SubStr(value,1,50) . "...")
		if (++matches>12)
			break
	}
	if matches<=12
		for key,value in log {
			StringGetPos,pos,value,%Entry%
			if (pos=-1)
				continue
			keyarr[matches] := value
			len:=StrLen(value)
			print.="`nf" . matches . " " . (len<50? value : pos+30>len? "..." . SubStr(value,-50) : pos>25? SubStr(value,1,10) . "..." . SubStr(value,pos-10,50) . "..." : SubStr(value,1,50) . "...")
			if (++matches>12)
				break
		}
	Tooltip, % matches>1? print : print . "`n(no matches)`nf1..f10 to add to presets`nenter: append to presets & send`ntab: append to presets",10,10
}
if (SubStr(ErrorLevel,1,8)="EndKey:F") {
	fN:=SubStr(ErrorLevel,9)
	if (matches>1 || !Entry)
		Send, % matches>fN? keyarr[fN] : pre[fN-1]
	else {
		pre[fN-1]:=Entry
		presets=
		Loop 12
			presets.="`nf" . A_Index . " " . (StrLen(pre[A_Index])>50? SubStr(pre[A_Index],1,50) . " ..." : pre[A_Index-1]) 
		GoSub, uiLoop
	}
} else if ErrorLevel!=EndKey:Escape
	if matches>1
		Send,% keyarr[1]
	else
		pre[preL++]:=Entry
	if ErrorLevel=EndKey:Enter
		Send,% Entry
Tooltip
return
