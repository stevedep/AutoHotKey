#SingleInstance,Force ;ensure only 1 version running
SetTitleMatchMode, 3 ;to make sure winMinimize and Sending Control C to ConsoleWindowClass works down below
DetectHiddenWindows,On ;Added becauase minimizing the window

; General Documentation := https://ffmpeg.org/ffmpeg-devices.html#gdigrab  Documentation on gdigrab from ffmpeg
; Get list of devices ffmpeg:= ffmpeg -list_devices true -f dshow -i dummy
; Cropping specific area := https://stackoverflow.com/questions/6766333/capture-windows-screen-with-ffmpeg/47591299
;********************Control+Shift+R=Start Recording***********************************
^+r::
FileDelete, %A_ScriptDir%\temp.mkv
sleep, 50

ff_params = -f gdigrab -i desktop -framerate 30 -f dshow -i audio="Microphone Array (Synaptics Audio)" -f dshow -i audio="CABLE Output (VB-Audio Virtual Cable)" -filter_complex "[1:a]volume=1[a1];[2:a]adelay=2550|2550,volume=1[a2]; [a1][a2]amix[a]" -map 0:v -map "[a]" -c:v h264_nvenc -b:v 5M temp.mkv

run ffmpeg %ff_params% ;run ffmpeg with command parameters

sleep, 500 ;Wait for Command window to appear
WinMinimize, ahk_class ConsoleWindowClass ;minimize the CMD window
return

;********************Control+Shift+S= Stop Recording***********************************
^+s::
ControlSend, , ^c, ahk_class ConsoleWindowClass  ; send ctrl-c to command window which stops the recording
sleep, 500
InputBox, New_File_Name,File name,What would you like to name your .mp4 file?,,300,130 ;Get a file name for your new video
if (New_File_Name = "") or (Error = 1) ;If you don't give it a name, it won't rename it and won't run it
	return 


FileMove, %A_ScriptDir%\temp.mkv, %A_ScriptDir%\%New_File_Name%.mkv  ; Rename the temp file to your new file.
return

;********************F6 open sound volume***********************************
*F6::
Run, mmsys.cpl
WinWait,Sound
ControlSend,SysListView321,{Down 5}
Send !p 
WinWait,Speakers Properties
CoordMode, Mouse, RelativeTo
MouseClick, right, 78, 19

;********************F5 open file in notepad++***********************************
*F7::
Clipboard = 
Send ^c
ClipWait ;waits for the clipboard to have content
Run, C:\Program Files (x86)\Notepad++\notepad++.exe `"%clipboard%`"
Sleep, 3000
Send !q
Send ^c
Run, C:\Program Files\Microsoft Office\root\Office16\WINWORD.EXE

