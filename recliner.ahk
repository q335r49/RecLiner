#NoEnv
#SingleInstance force
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
StringCaseSense, Off
shDel:=chr(127)
ctrS:=chr(19)
ctrH:=chr(8)
ctrA:=chr(1)
ctrU:=chr(21)
ctrZ:=chr(26)
ctrV:=chr(22)
if !FileExist("recliner.ini")
	FileAppend,
	( LTrim
		[main]
		;Hotkey=#s
		;   Examples: ^t (control t) !f5 (alt f5) +f6 (shift f6) #s (windows s) See http://www.autohotkey.com/docs/Hotkeys.htm for further documenation (Default f4)
		;MinLength=14
		;   Strings shorter than this length will not be stored in the archive (default 14)
	), recliner.ini

IniRead, mainHotkey, recliner.ini, main, Hotkey, f4
IniRead, min_chars, recliner.ini, main, MinLength, 14
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
MsgBox, % logL . " logs " . preL . " presets loaded from recliner.log"
while preL < 12
	pre[preL++]:=""
Loop 12
	presets.="`nf" . A_Index . " " . (StrLen(pre[A_Index-1])>50? SubStr(pre[A_Index-1],1,50) . " ..." : pre[A_Index-1]) 
mark:=0
Menu, Tray, Nostandard
Menu, Tray, add, &Edit log, MenuEditLog
Menu, Tray, add, &Reload from log, MenuReload
Menu, Tray, add
Menu, Tray, add, E&xit, MenuExit
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
			} else if (A_LoopField = ctrH)
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
	MsgBox, % logL . " logs " . preL . " presets written to recliner.log"
	return
MenuReload:
	Reload
	return
MenuEditLog:
	Gosub, WriteLog
	Run, recliner.log
	return
MenuEditSettings:
	Run, recliner.ini
	return
MenuExit:
	MsgBox, 3,, Save log?
	IfMsgBox, Yes
		Gosub, WriteLog
	IfMsgBox, Cancel
		return
	ExitApp

uiLoop:
next := mark>=0? (mark+1>=preL? preL-1 : mark+1) : (-mark>logL? -logL-1 : mark-1)
nextEnt := next>=0? pre[next] : log[-next-1]
ToolTip,% ">`n^Help ^U:clear ^V:paste ^Save arrows:history`nEnter: " . (StrLen(nextEnt) > 50? SubStr(nextEnt,1,50) . "..." : nextEnt) . presets,10,10
matches:=1
Entry=
NotFirstPress=0
matchV := Object()
matchK := Object()
Loop {
	Input, char, M L1, {enter}{esc}{bs}{f1}{f2}{f3}{f4}{f5}{f6}{f7}{f8}{f9}{f10}{up}{down}{left}{right}{tab}
	if (ErrorLevel="EndKey:Up" || ErrorLevel="EndKey:Down" || ErrorLevel="EndKey:Right" || ErrorLevel="EndKey:Left") {
		browsemode=1
		mark:=matches>1? matchK[1] : mark
		if (mark>=0) {
			mark+=(ErrorLevel="EndKey:Up"? -1 : ErrorLevel="EndKey:Down"? 1 : ErrorLevel="EndKey:Left"? -12 : 12)*NotFirstPress
			mark:=mark>=preL? preL-1 : mark<0? 0 : mark
			Entry:=pre[mark]
			start:=mark//12*12-1
			hist=
			Loop 12
				hist.="`nf" . A_Index . ": " . (A_Index+start=mark? "[" . A_Index+start+1 . "]" : A_Index+start+1) . " " . (StrLen(pre[A_Index+start])>50? (SubStr(pre[A_Index+start],1,50) . " ...") : pre[A_Index+start]) 
		} else {
			mark+=(ErrorLevel="EndKey:Up"? 1 : ErrorLevel="EndKey:Down"? -1 : ErrorLevel="EndKey:Left"? 12 : -12)*NotFirstPress
			mark:=-mark-1>logL? -logL-1 : mark>-1? -1 : mark 
			Entry:=log[-mark-1]
			start:=(-mark-1)//12*12-1
			hist=
			Loop 12
				hist.="`nf" . A_Index . ": " . (A_Index+start=-mark-1? "[" . A_Index+start+1 . "]" : A_Index+start+1) . " " . (StrLen(log[A_Index+start])>50? (SubStr(log[A_Index+start],1,50) . " ...") : log[A_Index+start]) 
		}
		NotFirstPress=1
		matches=1
		Tooltip,% "> " . Entry .  hist,10,10
		continue
	} else if ErrorLevel=Max
		browsemode=0
	else
		break
	if ErrorLevel=EndKey:Backspace
		StringTrimRight, Entry, Entry, 1
	else if (char>ctrZ) {
		Entry.=char
		NotFirstPress=0
	} else if (char=ctrU)
		Entry:=""
	else if (char=ctrH) {
		Tooltip,
		( LTrim
			RECLINER v1.1`n
			Record and recall every line you type! On Enter, Esc, or Tab, the line just typed will
			be stored in a searchable history.
			* Remember addresses, serial numbers, and usernames!
			* Have a unified history for command line interfaces!
			* Log online chats!
			* Build a library of frequently used quotes!`n
			SEARCHING
			* Press [%mainHotkey%] to bring up a search prompt.
			* The function keys [f1] .. [f12] serve multiple roles depending on the situation. On an
			empty prompt, they will send the presets. When there are search results, it will send
			the corresponding search entry. But when there are no search results for an entered
			text, they will set the corresponding preset to that text.
			* The arrow keys navigates the log. The starting point is either the first search
			result or the last returned entry on an empty prompt.
			* More than 12 presets can be set. Presets appear first in recliner.log and the search
			and can serve to conceptually differentiate between autotext and log entries.
			* To make entering consecutive entries easier, press enter on a blank prompt to send the
			next line.
			EDITING RECLINER.LOG
			* Only lines longer than %min_chars% characters will be stored in the log.
			* The line "### End Presets ###" separates presets from log entries.
		),10,10
		continue
	} else if (char=ctrV) {
		Entry=%clipboard%
	} else if (char=ctrS) { 
		Gosub, WriteLog
		Tooltip
		return
	}
	matches:=1
	if !Entry
	{
		ToolTip,% ">`nEnter: " . (StrLen(nextDisP) > 50? SubStr(nextEnt,1,50) . "..." : nextEnt) . presets,10,10
		continue
	}
	print=> %Entry%
	for key,value in pre {
		StringGetPos,pos,value,%Entry%
		if (pos=-1)
			continue
		matchV[matches] := value
		matchK[matches] := key
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
			matchV[matches] := value
			matchK[matches] := -key-1
			len:=StrLen(value)
			print.="`nf" . matches . " " . (len<50? value : pos+30>len? "..." . SubStr(value,-50) : pos>25? SubStr(value,1,10) . "..." . SubStr(value,pos-10,50) . "..." : SubStr(value,1,50) . "...")
			if (++matches>12)
				break
		}
	Tooltip, % matches>1? print : print . "`n   --- no matches ---`nf1..f10 - add to presets`nenter - append to presets & send`ntab - append to presets",10,10
}
if (SubStr(ErrorLevel,1,8)="EndKey:F") {
	fN:=SubStr(ErrorLevel,9)
	if fN<=12
		if browsemode=1
			SendRaw,% mark>=0? pre[fN+start] : log[fN+start]
		else if (matches>fN) {
			SendRaw,% matchV[fN]
			mark:=matchK[fN]
		} else if (matches<=1)
			if (Entry!="") {
				pre[fN-1]:=Entry
				presets=
				Loop 12
					presets.="`nf" . A_Index . " " . (StrLen(pre[A_Index-1])>50? SubStr(pre[A_Index-1],1,50) . " ..." : pre[A_Index-1]) 
				GoSub, uiLoop
			} else
				SendRaw,% pre[fN-1]
} else if ErrorLevel!=EndKey:Escape
	if browsemode=1
		SendRaw,% Entry
	else if (matches>1) {
		SendRaw,% matchV[1]
		mark:=matchK[1]
	} else if (Entry="" && ErrorLevel="EndKey:Enter") {
		mark := next
		Sendraw,% nextEnt
	} else {
		count=0
		while (pre[count]!="" && count<12)
			count++
		if count=12
			pre[preL++]:=Entry
		else {
			pre[count]:=Entry
			presets=
			Loop 12
				presets.="`nf" . A_Index . " " . (StrLen(pre[A_Index-1])>50? SubStr(pre[A_Index-1],1,50) . " ..." : pre[A_Index-1]) 
		}
		if ErrorLevel=EndKey:Enter
			SendRaw,% Entry
	}
Tooltip
return
