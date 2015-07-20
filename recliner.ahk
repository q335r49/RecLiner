#NoEnv
#SingleInstance force
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

StringCaseSense, Off
FileEncoding, UTF-8

ctrDel:=chr(127)
ctrS:=chr(19)
ctrH:=chr(8)
ctrA:=chr(1)
ctrU:=chr(21)
ctrZ:=chr(26)
ctrV:=chr(22)

if !FileExist("recliner.ini")
	FileAppend,
	( LTrim
		Hotkey=f4
		MinLength=2
		Font=Arial
		FontColor=FF0000
		BGColor=808080
		FontSize=10
		AutosaveFrequency=100
	), recliner.ini
Hotkey=f4
MinLength=2
Font=Arial
FontColor=FF0000
BGColor=000000
FontSize=12
AutosaveFrequency=100

#Include recliner.ini

Hotkey,%Hotkey%,uiLoop

log:=Object()
logL:=0
Loop, Read, recliner.log
	log[logL++]:=A_LoopReadLine

mark:=0
browseKeys := Object("EndKey:Up",-1,"EndKey:Down",1,"EndKey:Delete",1,"EndKey:Left",-12,"EndKey:Right",12,"EndKey:Home",-999999,"EndKey:End",999999)

Menu, Tray, Nostandard
Menu, Tray, add, &Edit log..., MenuEditLog
Menu, Tray, add, &Reload from log, MenuReload
Menu, Tray, add, Edit &Settings..., MenuEditSettings
Menu, Tray, add, Save && E&xit, MenuExit

Gui, Font, s%FontSize% c%FontColor%, %Font%
Gui, Color, %BGColor%
Gui, Add, Text,vConsole r14 -Wrap,
	( LTrim
		RECLINER 1.3, updated 2/8/2015
		hotkey: %Hotkey%		recliner.log: %logL% entries
		
		Recliner logs all typed text in recliner.log
		- Search by text or (positive or negative) index number.
		- Edit recliner.log and place most often used entries first for quick access
		- Drag and resize this window to change location of console.
		- Change font, color, and hotkey in recliner.ini



		(Press any key to continue)
	)
Gui, +AlwaysOnTop +ToolWindow +Resize
Gui, show, % "X" . WinPos.X . " Y" . WinPos.Y . " W" . WinPos.W, recLiner
Winwaitactive, recLiner
VarSetCapacity( rect, 16, 0 )
MyGuiHWND := WinExist()
DllCall("GetClientRect", uint, MyGuiHWND, uint, &rect )
ClientH := NumGet( rect, 12, "int" )
Input, char, L1
Gui, -Caption -Resize
DllCall("GetClientRect", uint, MyGuiHWND, uint, &rect )
ClientW := NumGet( rect, 8, "int" )
GuiControl, Move, Console, % "w" . (ClientW-25)
WinMove, recLiner,,,,%ClientW%,%ClientH%
WinGetPos, ClientX, ClientY,,,recLiner
Winset, Region, 0-0 w%ClientW% h%ClientH% R30-30, recLiner
Gui, hide

Loop {
	Input, k, V M, {enter}{esc}{tab}
	if (StrLen(k)<MinLength)
		continue
	out=
	Loop,Parse,k
		if (A_LoopField = ctrDel) {
			out := RTrim(out)
			StringGetPos,pos,out,%A_Space%,R1
			if !ErrorLevel
				StringLeft,out,out,% pos+1
		} else if (A_LoopField = ctrH)
			StringTrimRight,out,out,1
		else if (A_LoopField = ctrA)
			out=
		else if (Asc(A_LoopField)>=32)
			out.=A_LoopField
	log[logL++]:=out
	if (!mod(logL,AutosaveFrequency))
		GoSub, Autosave
}
return

ConsoleMsg(string, hide=0) {
	if hide
	{	GuiControl,,Console,%string%
		Gui, show
		Winwaitactive, recLiner
		Input, char, L1
		Gui, hide
	} else {
		GuiControl,,Console,%string%
		Input, char, L1
	}
	return char
}

WriteLog:
	File := FileOpen("recliner.ini","w `r`n")
		File.WriteLine("WinPos:={X:" . ClientX . ", Y:" . ClientY . ", W:" . ClientW . ", H:" . ClientH . "}")
		File.WriteLine("Hotkey=" . Hotkey)
		File.WriteLine("MinLength=" . MinLength)
		File.WriteLine("Font=" . Font)
		File.WriteLine("FontColor=" . FontColor)
		File.WriteLine("BGColor=" . BGColor)
		File.WriteLine("FontSize=" . FontSize)
		File.WriteLine("AutosaveFrequency=" . AutosaveFrequency)
	File.close()
Autosave:
	File := FileOpen("recliner.log","w `r`n")
		for key,value in log
			File.WriteLine(value)
	File.close()
	return
MenuEditLog:
	Gosub, WriteLog
	Run, recliner.log
	return
MenuReload:
	Reload
	return
MenuEditSettings:
	Run, recliner.ini
	return
MenuExit:
	Gosub, WriteLog
	ExitApp

uiLoop:
Gui, show
next := mark+1>=logL? logL-1 : mark+1
nextEnt := log[next]
first12:=""
Loop 12
	first12.="`n F" . A_Index . "`t" . log[A_Index-1]
GuiControl,,Console,% ">`t^U:clear ^V:paste ^Save Arrows:browse`nEnter`t" . (StrLen(nextEnt) > 50? SubStr(nextEnt,1,50) . "..." : nextEnt) . first12
matches := 1
Entry=
NotFirstPress=0
matchV := Object()
matchK := Object()
deleteK := {}
nmode=0
Winwaitactive, recLiner
Loop {
	Input, char, M L1, {enter}{esc}{bs}{f1}{f2}{f3}{f4}{f5}{f6}{f7}{f8}{f9}{f10}{f11}{f12}{up}{down}{left}{right}{delete}{home}{end}
	if browseKeys.HasKey(ErrorLevel) {
		nmode=1
		mark:=matches>1? matchK[1] : mark
		if (ErrorLevel="EndKey:Delete") && NotFirstPress
			if deleteK.HasKey(mark)
				deleteK.Remove(mark,"")
			else
				deleteK[mark]:=1
		mark+=browseKeys[ErrorLevel]*(NotFirstPress || ErrorLevel="EndKey:Home" || ErrorLevel="EndKey:End")
		mark:=mark>=logL? logL-1 : mark<0? 0 : mark
		Entry:=log[mark]
		start:=mark//12*12-1
		hist=
		Loop 12
			hist.="`n" . (A_Index+start=mark? ">" : " ") . (deleteK.HasKey(A_Index+start)? "X " : " ") . "F" . A_Index . "`t" . (A_Index+start) . " " . log[A_Index+start] 
		NotFirstPress=1
		matches=1
		GuiControl,,Console,% "> " . (StrLen(Entry)>50? "..." . SubStr(Entry,-50) : Entry) .  hist
		continue
	} else if (ErrorLevel="EndKey:Backspace") {
		StringTrimRight, Entry, Entry, 1
		nmode=0
	} else if (SubStr(ErrorLevel,1,8)="EndKey:F") {
		fN:=SubStr(ErrorLevel,9)
		if (nmode=1) {
			SendString(log[fN+start], fN+start)
		} else if (matches>fN) {
			SendString(matchV[fN], matchK[fN])
			mark:=matchK[fN]
		} else if (Entry="") {
			SendString(log[fN-1],fN-1)
		}
		Gosub, ProcDel
		if deletions>0
			ConsoleMsg(deletions . " entries removed`n(Press any key to continue)")
		break
	} else if (ErrorLevel="EndKey:Enter") {
		if (nmode=1) {
			Gosub, ProcDel
			if deletions>0
				ConsoleMsg(deletions . " entries removed`n(Press any key to continue)")
			else
				SendString(Entry)
		} else if (matches>1) {
			SendString(matchV[1],matchK[1])
			mark:=matchK[1]
		} else if (Entry="") {
			mark := next
			SendString(nextEnt,next)
		} else
			SendString(Entry)
		break
	} else if (ErrorLevel!="Max") {
		Sleep 99
		break
	} else if (char>ctrZ) {
		Entry.=char
		NotFirstPress=0
	} else if (char=ctrU)
		Entry := ""
	else if (char=ctrS) { 
		Gosub, WriteLog
		GoSub, ProcDel
		ConsoleMsg(logL . " logs written to recliner.log`n(Press any key to continue)")
		break
	} else if (char=ctrV)
		Entry=%clipboard%
	matches:=1
	if Entry
	{	
		EntryL:=StrLen(Entry)
		print := "> " . (EntryL>70? "..." . SubStr(Entry,-70) : Entry)
		if Entry is integer
		{
			ix := Entry<0? Entry>-logL? logL+Entry : 0 : Entry>=logL? logL-1 : Entry
			print.="`n F" . matches . "`t" . (matchK[matches] := ix) . " " . (matchV[matches] := log[ix])
			matches++
		}
		key := -1
		while (key<logL && matches<=12) {
			key++
			value := log[key]
			StringGetPos,pos,value,%Entry%
			if (pos=-1)
				continue
			matchV[matches] := value
			matchK[matches] := key
			len:=StrLen(value)
			print.="`n F" . matches . "`t" . key . " " . (pos<=60 || len<100? Substr(value,1,pos) . "[[" . Substr(value, pos+1, EntryL) . "]]" . SubStr(value,pos+1+EntryL) : "..." . SubStr(value,pos-50,51) . "[[" . SubStr(value,pos+1,EntryL) . "]]" . SubStr(value,pos+EntryL+1))
			matches++
		}
		GuiControl,,Console, % print
	} else
		GuiControl,,Console, % ">`nEnter`t" . (StrLen(nextDisP) > 50? SubStr(nextEnt,1,50) . "..." : nextEnt) . first12
}
Gui, hide
return

ProcDel:
	deletions=0
	for key in deleteK {
		deletions++
		log.Remove(key)
	}
	return

SendString(string, ix:=-1) {
	global log
	Gui, hide
	WinWaitNotActive, RecGUI
	NUM:=InStr(string,"\NUM") 
	if NUM <> 0
	{
		END:=InStr(string," ",,NUM)
		if END = 0
			END := StrLen(string)
		COUNTER:=SubStr(string,NUM+4,END-NUM-4)
		COUNTER++

		if ix <> -1
			log[ix]:=SubStr(string,1,NUM-1) . "\NUM" . COUNTER . SubStr(string,END)

		string:=SubStr(string,1,NUM-1) . COUNTER . SubStr(string,END)
	}
	Send % SubStr(string,1,3)="###"? SubStr(string,4) : "{Raw}" . string
}
