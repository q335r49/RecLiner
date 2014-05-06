#NoEnv
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;figure out weird file writing bug
;some way to set and save global hotkey (options file, as before?)
;need setting to change min length
;any way to send multiple lines??
;need to make sure that i am explicitly specifying `r`n when reading too
;make sure enters are properly being converted

ASC127:=chr(127)
ASC8  :=chr(8)
ASC1  :=chr(1)
min_chars=14

dict:=Object()
size=0
if !FileExist("atk2.log")
	MsgBox % "Warning: atk2.log not found in " . A_ScriptDir . "`nTo save log between sessions, right click on tray menu"
else {
	Loop, Read, atk2.log
	{
		dict[size]:=A_LoopReadLine
		size++
	}
	MsgBox % size . " lines read from " . A_ScriptDir . "\atk2.log"
}
Menu, tray, Add,
Menu, tray, Add, Autotextkeeper help..., Help
Menu, tray, Add, Write log to atk2.log, Save
Menu, tray, Add, Open atk2.log, OpenLog
Gosub, StartLog
return





!f1::Send, % dict[0]
!f2::Send, % dict[1]
!f3::Send, % dict[2]

OpenLog:
	Run, atk2.log
return

Save:
	Log := FileOpen("atk2.log","w `r`n")
	for key,value in dict
		Log.WriteLine(value)
	Log.close()
	MsgBox % size . " lines written to " . A_ScriptDir . "\atk2.log"
return

Help:
return

#s::
	ToolTip, (Enter fragment),10,7
	matches=0
	index=1
	best=
	CurrentEntry=
	Loop
	{
		Input, char, L1, {enter}{esc}{tab}{bs}
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
				matchstring=
			}
			else if pos {
				if !best
					best:=value
				else if (StrLen(value)>50)
					matchstring.="`n" . SubStr(value,1,50) . "..."
				else
					matchstring.="`n" . value
				matches++
				if matches>5
					break
			} else {
				best:=value
				break
			}
		}
		if (!matches and !best)
			Tooltip,% CurrentEntry ":`n(no matches)",10,7
		else if (StrLen(best)>50)
			Tooltip,% CurrentEntry ":`n" SubStr(best,1,50) . "..." . matchstring,10,7 
		else
			Tooltip,% CurrentEntry ":`n" best . matchstring,10,7
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
