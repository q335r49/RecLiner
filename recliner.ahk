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
Gosub, RebuildPresets
mark:=0
browseKeys := Object("EndKey:Up",-1,"EndKey:Down",1,"EndKey:Delete",1,"EndKey:Left",-12,"EndKey:Right",12,"EndKey:Home",-999999,"EndKey:End",999999)
Menu, Tray, Nostandard
Menu, Tray, add, &Edit log, MenuEditLog
Menu, Tray, add, &Reload from log, MenuReload
Menu, Tray, add
Menu, Tray, add, S&ave, WriteLog
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
ToolTip,% ">`n^Help ^U:clear ^V:paste ^Save arrows:history`nEnter`t" . (StrLen(nextEnt) > 50? SubStr(nextEnt,1,50) . "..." : nextEnt) . presets,10,10
matches := 1
Entry=
NotFirstPress=0
matchV := Object()
matchK := Object()
deleteK := {}
nmode=0
Loop {
	Input, char, M L1, {enter}{esc}{bs}{f1}{f2}{f3}{f4}{f5}{f6}{f7}{f8}{f9}{f10}{up}{down}{left}{right}{delete}{home}{end}
	if browseKeys.HasKey(ErrorLevel) {
		nmode=1
		mark:=matches>1? matchK[1] : mark
		if (ErrorLevel="EndKey:Delete") && NotFirstPress
			if deleteK.HasKey(mark)
				deleteK.Remove(mark,"")
			else
				deleteK[mark]:=1
		if (mark>=0) {
			mark+=browseKeys[ErrorLevel]*(NotFirstPress || ErrorLevel="EndKey:Home" || ErrorLevel="EndKey:End")
			mark:=mark>=preL? preL-1 : mark<0? 0 : mark
			Entry:=pre[mark]
			start:=mark//12*12-1
			hist=
			Loop 12
				hist.="`n" . (A_Index+start=mark? "{ " : " ") . (deleteK.HasKey(A_Index+start)? "X " : " ") . "F" . A_Index . "`t" . (A_Index+start+1) . " " . (StrLen(pre[A_Index+start])>50? (SubStr(pre[A_Index+start],1,50) . " ...") : pre[A_Index+start]) 
		} else {
			mark-=browseKeys[ErrorLevel]*(NotFirstPress || ErrorLevel="EndKey:Home" || ErrorLevel="EndKey:End")
			mark:=-mark-1>logL? -logL-1 : mark>-1? -1 : mark 
			Entry:=log[-mark-1]
			start:=(-mark-1)//12*12-1
			hist=
			Loop 12
				hist.="`n" . (A_Index+start=-mark-1? "{ " : " ") . (deleteK.HasKey(-A_Index-start-1)? "X " : " ") . "f" . A_Index . "`t" . (A_Index+start+1) . " " . (StrLen(log[A_Index+start])>50? (SubStr(log[A_Index+start],1,50) . " ...") : log[A_Index+start]) 
		}
		NotFirstPress=1
		matches=1
		Tooltip,% "> " . Entry .  hist,10,10
		continue
	} else if (ErrorLevel="EndKey:Backspace") {
		StringTrimRight, Entry, Entry, 1
		nmode=0
	} else if (SubStr(ErrorLevel,1,8)="EndKey:F") {
		fN:=SubStr(ErrorLevel,9)
		if fN<=12
			if (nmode=1) {
				SendString(mark>=0? pre[fN+start] : log[fN+start])
			} else if (matches>fN) {
				SendString(matchV[fN])
				mark:=matchK[fN]
			} else if (matches<=1)
				if (Entry!="") {
					pre[fN-1]:=Entry
					Gosub, RebuildPresets
					GoSub, uiLoop
				} else
					SendString(pre[fn-1])
		Gosub, ProcDel
		if deletions>0
			MsgBox, %deletions% entries removed
		break
	} else if (ErrorLevel="EndKey:Enter") {
		if (nmode=1) {
			Gosub, ProcDel
			if deletions>0
				MsgBox, %deletions% entries removed
			else
				SendString(Entry)
		} else if (matches>1) {
			SendString(matchV[1])
			mark:=matchK[1]
		} else if (Entry="") {
			mark := next
			SendString(nextEnt)
		} else {
			count=0
			while (pre[count]!="" && count<12)
				count++
			if count=12
				pre[preL++]:=Entry
			else {
				pre[count]:=Entry
				Gosub, RebuildPresets
			}
			SendString(Entry)
		}
		break
	} else if (ErrorLevel!="Max") {
		break
	} else if (char>ctrZ) {
		Entry.=char
		NotFirstPress=0
	} else if (char=ctrU)
		Entry := ""
	else if (char=ctrH) {
		Tooltip,
		( LTrim
			RECLINER v1.2`n
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
			text, they will set the corresponding preset to that text.`n
			BROWSING
			* The arrow keys, [home], and [end] navigate the log. The starting point is either the first
			search result or the last returned entry on an empty prompt.
			* More than 12 presets can be set. Presets appear first in recliner.log and the search
			and can serve to conceptually differentiate between autotext and log entries.
			* To make entering consecutive entries easier, press enter on a blank prompt to send the
			next line.`n
			TIPS
			* Only lines longer than %min_chars% characters will be stored in the log (change in recliner.ini).
			* In recliner.log, the line "### End Presets ###" separates presets from log entries.
			* To send special characters (such as line breaks), append the entry with '###'. For example,
			"###blah blah{!}{enter}blah" will send the two lines "blah blah!" and "blah". For a list of
			special characters, see www.autohotkey.com/docs/commands/Send.htm
		),10,10
		continue
	} else if (char=ctrS) { 
		Gosub, WriteLog
		GoSub, ProcDel
		break
	} else if (char=ctrV)
		Entry=%clipboard%
	matches:=1
	if Entry
	{	print=> %Entry%
		for key,value in pre {
			StringGetPos,pos,value,%Entry%
			if (pos=-1)
				continue
			matchV[matches] := value
			matchK[matches] := key
			len:=StrLen(value)
			print.="`n F" . matches . "`t" . (len<50? value : pos+30>len? "..." . SubStr(value,-50) : pos>25? SubStr(value,1,10) . "..." . SubStr(value,pos-10,50) . "..." : SubStr(value,1,50) . "...")
			if (++matches>12)
				break
		}
		key := logL
		while (key>0 && matches<=12) {
			key--
			value := log[key]
			StringGetPos,pos,value,%Entry%
			if (pos=-1)
				continue
			matchV[matches] := value
			matchK[matches] := -key-1
			len:=StrLen(value)
			print.="`n f" . matches . "`t" . (len<50? value : pos+30>len? "..." . SubStr(value,-50) : pos>25? SubStr(value,1,10) . "..." . SubStr(value,pos-10,50) . "..." : SubStr(value,1,50) . "...")
			matches++
		}
		Tooltip, % matches>1? print : print . "`nF1-12`tset`nEnter`tappend to presets & send",10,10
	} else
		ToolTip,% ">`nEnter`t" . (StrLen(nextDisP) > 50? SubStr(nextEnt,1,50) . "..." : nextEnt) . presets,10,10
}
Tooltip
return

ProcDel:
	deletions=0
	for key in deleteK {
		deletions++
		if key>=0
			pre[key]:=""
		else
			log.Remove(-key-1)
	}
RebuildPresets:
	presets:=""
	Loop 12
		presets.="`n F" . A_Index . "`t" . (StrLen(pre[A_Index-1])>50? SubStr(pre[A_Index-1],1,50) . " ..." : pre[A_Index-1]) 
	return

SendString(string) {
	Send % SubStr(string,1,3)="###"? SubStr(string,4) : "{Raw}" . string
}
