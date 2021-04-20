#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.2
 Author:         Timboli

 Script Function:  Extract game titles from a saved ZOOM Platform web page
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Functions
; DropBoxGUI(), DisplayTitles($drop = ""), ExtractTitles($drop = "")

#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <StaticConstants.au3>
#include <ColorConstants.au3>
#include <Misc.au3>
#include <File.au3>
#include <Date.au3>
#include <Array.au3>

_Singleton("get-game-titles-timboli")

Global $a, $array, $date, $drop, $exists, $found, $game, $gamelist, $games, $gamesfile, $i, $inifle, $line, $new, $oldlist
Global $path, $s, $sect, $target, $tot, $version, $webpage

$gamelist = @ScriptDir & "\Games.txt"
$gamesfile = @ScriptDir & "\Games.ini"
$inifle = @ScriptDir & "\Settings.ini"
$oldlist = @ScriptDir & "\Oldgames.txt"
$version = "v1.2"
; April 2021

$games = ""
If $CmdLine[0] = "" Then
	;$webpage = @ScriptDir & "\Zoom Platform.html"
	$target = @LF & "Drag && Drop" & @LF & "The Saved" & @LF & "ZOOM Platform" & @LF & "Web Page" & @LF & "File HERE"
	DropBox()
Else
	$path = $CmdLine[1]
	If FileExists($path) Then
		$webpage = $path
		ExtractTitles()
		DisplayTitles()
	EndIf
EndIf

Exit

Func DropBox()
	Local $Button_display, $Button_go, $Button_list, $Item_one, $Label_drop, $Label_status, $Menu_go
	Local $atts, $DropboxGUI, $left, $onetab, $srcfle, $style, $top, $winpos
	;
	$left = IniRead($inifle, "Program Window", "left", -1)
	$top = IniRead($inifle, "Program Window", "top", -1)
	$style = $WS_CAPTION + $WS_POPUP + $WS_CLIPSIBLINGS + $WS_SYSMENU
	$DropboxGUI = GUICreate("ZOOM Checker  " & $version, 215, 160, $left, $top, $style, $WS_EX_TOPMOST + $WS_EX_ACCEPTFILES)
	;
	; CONTROLS
	$Label_drop = GUICtrlCreateLabel($target, 1, 1, 213, 107, $SS_CENTER)
	GUICtrlSetFont($Label_drop, 9, 600)
	GUICtrlSetState($Label_drop, $GUI_DROPACCEPTED)
	GUICtrlSetTip($Label_drop, "Drag & Drop saved ZOOM Platform web page file here!")
	;
	$Label_status = GUICtrlCreateLabel("Click GO to go to the Games web page", 1, 108, 213, 18, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetFont($Label_status, 7, 600, 0, "Small Fonts")
	GUICtrlSetBkColor($Label_status, $COLOR_LIME)
	GUICtrlSetColor($Label_status, $COLOR_BLACK)
	;
	$Button_display = GUICtrlCreateButton("DISPLAY", 2, 132, 70, 23)
	GUICtrlSetFont($Button_display, 7, 600, 0, "Small Fonts")
	GUICtrlSetTip($Button_display, "Display the list of titles!")
	;
	$Button_list = GUICtrlCreateButton("Titles List", 81, 132, 70, 23)
	GUICtrlSetFont($Button_list, 7, 600, 0, "Small Fonts")
	GUICtrlSetTip($Button_list, "View the Titles List file!")
	;
	$Button_go = GUICtrlCreateButton("GO", 160, 132, 52, 23)
	GUICtrlSetFont($Button_go, 7, 600, 0, "Small Fonts")
	GUICtrlSetTip($Button_go, "Go to Games page at ZOOM Platform!")
	;
	; CONTEXT MENU
	$Menu_go = GUICtrlCreateContextMenu($Button_go)
	$Item_one = GUICtrlCreateMenuItem("One TAB", $Menu_go, -1, 0)
	;
	; SETTINGS
	$onetab = IniRead($inifle, "GO Button", "one_tab", "")
	If $onetab = "" Then
		$onetab = 4
		IniWrite($inifle, "GO Button", "one_tab", $onetab)
	EndIf
	GUICtrlSetState($Item_one, $onetab)
	;
	; Testing
	;GUICtrlSetData($Label_status, "Please wait for all pages to fully load")
	;
	GUICtrlSetBkColor($Label_drop, $COLOR_BLUE)
	GUICtrlSetColor($Label_drop, $COLOR_YELLOW)

	GUISetState(@SW_SHOW)
	While True
		$msg = GUIGetMsg()
		Select
			Case $msg = $GUI_EVENT_CLOSE
				; Exit or Close dropbox
				$winpos = WinGetPos($DropboxGUI, "")
				$left = $winpos[0]
				If $left < 0 Then
					$left = 2
				ElseIf $left > @DesktopWidth - $winpos[2] Then
					$left = @DesktopWidth - $winpos[2]
				EndIf
				IniWrite($inifle, "Program Window", "left", $left)
				$top = $winpos[1]
				If $top < 0 Then
					$top = 2
				ElseIf $top > @DesktopHeight - $winpos[3] Then
					$top = @DesktopHeight - $winpos[3]
				EndIf
				IniWrite($inifle, "Program Window", "top", $top)
				;
				GUIDelete($DropboxGUI)
				ExitLoop
			Case $msg = $GUI_EVENT_DROPPED
				$srcfle = @GUI_DragFile
				$atts = FileGetAttrib($srcfle)
				If StringInStr($atts, "D") > 0 Then
					MsgBox(262192, "Source Error", "Not a file!", 0, $DropboxGUI)
				Else
					$webpage = $srcfle
					GUICtrlSetBkColor($Label_drop, $COLOR_RED)
					GUICtrlSetData($Label_drop, @LF & @LF & @LF & "Please Wait")
					;GUICtrlSetData($Label_drop, @LF & @LF & @LF & "Extracting")
					ExtractTitles("drop")
					GUICtrlSetBkColor($Label_drop, $COLOR_GREEN)
					GUICtrlSetData($Label_drop, @LF & @LF & @LF & "Display Viewer")
					DisplayTitles("drop")
					GUICtrlSetData($Label_drop, $target)
					GUICtrlSetBkColor($Label_drop, $COLOR_BLUE)
				EndIf
			Case $msg = $Button_list
				; View the Titles List file
				If FileExists($gamelist) Then ShellExecute($gamelist)
			Case $msg = $Button_go
				; Go to Games page at ZOOM Platform
				$buttxt = GUICtrlRead($Button_go)
				If _IsPressed("11") Then
					If $buttxt = "GO" Then
						GUICtrlSetBkColor($Label_status, $COLOR_YELLOW)
						If $onetab = 1 Then
							GUICtrlSetData($Button_go, "LOAD")
							GUICtrlSetData($Label_status, "Click LOAD to load all game pages")
						Else
							GUICtrlSetData($Button_go, "TAB")
							$tabs = 0
							GUICtrlSetData($Label_status, "Click TAB to load the next section")
						EndIf
					ElseIf $buttxt = "TAB" Or $buttxt = "LOAD" Then
						GUICtrlSetData($Button_go, "SAVE")
						GUICtrlSetBkColor($Label_status, $COLOR_FUCHSIA)
						GUICtrlSetData($Label_status, "Click SAVE to save the web page")
					Else
						GUICtrlSetData($Button_go, "GO")
						GUICtrlSetBkColor($Label_status, $COLOR_LIME)
						GUICtrlSetData($Label_status, "Click GO to go to the Games web page")
					EndIf
				ElseIf $buttxt = "GO" Then
					ShellExecute("https://www.zoom-platform.com/search")
					GUICtrlSetBkColor($Label_status, $COLOR_GRAY)
					GUICtrlSetData($Label_status, "Please wait until page has fully loaded")
					Sleep(4000)
					GUICtrlSetBkColor($Label_status, $COLOR_YELLOW)
					If $onetab = 1 Then
						GUICtrlSetData($Button_go, "LOAD")
						GUICtrlSetData($Label_status, "Click LOAD to load all game pages")
					Else
						GUICtrlSetData($Button_go, "TAB")
						$tabs = 0
						GUICtrlSetData($Label_status, "Click TAB to load the next section")
					EndIf
				ElseIf $buttxt = "TAB" Or $buttxt = "LOAD" Then
					WinActivate("Zoom Platform", "")
					If $onetab = 1 Then
						Send("^f")
						Sleep(1000)
						Send("All Rights Reserved.")
						;Send("©")
						GUICtrlSetBkColor($Label_status, $COLOR_GRAY)
						GUICtrlSetData($Label_status, "Please wait for all pages to fully load")
						Sleep(3000)
						GUICtrlSetData($Button_go, "SAVE")
						GUICtrlSetBkColor($Label_status, $COLOR_FUCHSIA)
						GUICtrlSetData($Label_status, "Click SAVE to save the web page")
					Else
						If $tabs = 0 Then
							Send("+{TAB 2}")
							$tabs = 2
							GUICtrlSetBkColor($Label_status, $COLOR_GRAY)
							GUICtrlSetData($Label_status, "Please wait until section has loaded")
							Sleep(3000)
							GUICtrlSetBkColor($Label_status, $COLOR_YELLOW)
							GUICtrlSetData($Label_status, "Click TAB to load the next section")
						Else
							Send("+{TAB}")
							$tabs = $tabs + 1
							If $tabs = 6 Then
								GUICtrlSetData($Button_go, "SAVE")
								GUICtrlSetBkColor($Label_status, $COLOR_FUCHSIA)
								GUICtrlSetData($Label_status, "Click SAVE to save the web page")
							EndIf
						EndIf
					EndIf
				ElseIf $buttxt = "SAVE" Then
					WinActivate("Zoom Platform", "")
					Send("^s")
					GUICtrlSetBkColor($Label_status, $COLOR_SKYBLUE)
					GUICtrlSetData($Label_status, "CTRL with button click changes state")
				EndIf
			Case $msg = $Button_display
				; Display the list of titles
				DisplayTitles()
			Case $msg = $Item_one
				; GO Button - One TAB
				If $onetab = 4 Then
					$onetab = 1
				Else
					$onetab = 4
				EndIf
				GUICtrlSetState($Item_one, $onetab)
				IniWrite($inifle, "GO Button", "one_tab", $onetab)
			Case Else
		EndSelect
	WEnd
EndFunc ;=> DropBox


Func DisplayTitles($drop = "")
	$games = ""
	$found = IniRead($inifle, "Games Found", "total", 0)
	If FileExists($gamesfile) Then
		;MsgBox(262144, "Check", "1")
		_FileReadToArray($gamesfile, $array)
		If IsArray($array) Then
			;MsgBox(262144, "Check", "2")
			If $drop = "" Then SplashTextOn("", "Please Wait!", 140, 100, Default, Default, 33)
			For $s = 1 To $array[0]
				$sect = $array[$s]
				If StringLeft($sect, 1) = "[" Then
				;If $sect <> "" Then
					$game = StringSplit($sect, ']', 1)
					$game = $game[1]
					$game = StringTrimLeft($game, 1)
					If $game <> "" Then
						If $games = "" Then
							$games = $game
						Else
							$games = $games & @LF & $game
						EndIf
					EndIf
				ElseIf StringLeft($sect, 5) = "date=" Then
					$date = StringTrimLeft($sect, 5)
					$games = $games & "|" & $date
				EndIf
			Next
			$games = StringSplit($games, @LF, 1)
			_ArrayColInsert($games, 1)
			$tot = $games[0][0]
			For $i = 1 To $tot
				$sect = $games[$i][0]
				$game = StringSplit($sect, "|")
				$date = $game[2]
				$game = $game[1]
				$games[$i][0] = $game
				$games[$i][1] = $date
			Next
			IniWrite($inifle, "Games Listed", "total", $tot)
			_ArrayAdd($games, $found & " of " & $tot & " games exist.", 0)
			If $drop = "" Then SplashOff()
			_ArrayDisplay($games, "ZOOM Platform Game Titles", "", 32, "|2", "Game Titles  (order of discovery)|Date", 400)
		EndIf
	EndIf
EndFunc ;=> DisplayTitles

Func ExtractTitles($drop = "")
	If $drop = "" Then SplashTextOn("", "Please Wait!", 140, 100, Default, Default, 33)
	$found = 0
	_FileReadToArray($webpage, $array)
	If IsArray($array) Then
		If FileExists($gamelist) Then FileMove($gamelist, $oldlist, 1)
		$date = _NowDate()
		For $a = 1 To $array[0]
			$line = $array[$a]
			If StringInStr($line, '</div> <div class="text-gray-400 text-xs truncate">') > 0 Then
				$game = StringSplit($line, '</div> <div class="text-gray-400 text-xs truncate">', 1)
				$game = $game[1]
				$game =  StringSplit($game, '">', 1)
				$game = $game[$game[0]]
				If $game <> "" Then
					$found = $found + 1
					$exists = IniRead($gamesfile, $game, "date", "")
					If $exists = "" Then
						IniWrite($gamesfile, $game, "date", $date)
						$new = " (NEW)"
					Else
						$exists = StringSplit($exists, " (", 1)
						$exists = $exists[1]
						If $exists <> $date Then
							IniWrite($gamesfile, $game, "date", $exists & " (" & $date & ")")
						EndIf
						$new = ""
					EndIf
					If $games = "" Then
						$games = $game & $new
					Else
						$games = $games & @CRLF & $game & $new
					EndIf
				EndIf
			EndIf
		Next
		If $games <> "" Then
			_FileCreate($gamelist)
			FileWrite($gamelist, $games)
			IniWrite($inifle, "Last Checked", "date", $date)
			IniWrite($inifle, "Games Found", "total", $found)
		EndIf
	EndIf
	If $drop = "" Then SplashOff()
EndFunc ;=> ExtractTitles
