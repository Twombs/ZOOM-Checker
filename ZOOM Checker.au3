#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.2
 Author:         Timboli

 Script Function:  Extract game titles from a saved ZOOM Platform web page
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Functions
; MainGUI(), DetailGUI(), DropBoxGUI(), SettingsGUI()
; DisplayTitles($drop = ""), ExtractTitles($drop = ""), FixTheTitle(), LoadTheList(), SetStateOfControls($state)

#include <Constants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <ColorConstants.au3>
#include <EditConstants.au3>
#include <ListViewConstants.au3>
#include <StaticConstants.au3>
#include <GuiListView.au3>
#include <Misc.au3>
#include <File.au3>
#include <Date.au3>
#include <Array.au3>

_Singleton("zoom-platform-checker-timboli")

Global $Button_apply, $Button_check, $Button_detail, $Button_fav, $Button_info, $Button_log, $Button_own, $Button_quit
Global $Button_save, $Button_web, $Combo_own, $Group_games, $Label_status, $ListView_games, $Radio_box, $Radio_gui

Global $a, $ans, $array, $blurb, $blurbs, $case, $checked, $CheckerGUI, $clip, $date, $detail, $drop, $e, $entries, $entry
Global $exists, $favorite, $found, $game, $gamelist, $games, $gamesfile, $high, $i, $idx, $images, $imgfle, $inifle, $last
Global $left, $line, $logfle, $low, $method, $new, $numb, $nums, $oldlist, $owned, $path, $ping, $price, $prior, $r, $read
Global $remfile, $removals, $remove, $s, $savefile, $savpth, $sect, $start, $state, $style, $target, $templist, $title
Global $top, $tot, $update, $usepth, $version, $webpage, $window, $wintit, $zoomfold, $zoomlist

$blurbs = @ScriptDir & "\Blurbs.ini"
$gamelist = @ScriptDir & "\Games.txt"
$gamesfile = @ScriptDir & "\Games.ini"
$images = @ScriptDir & "\Images"
$inifle = @ScriptDir & "\Settings.ini"
$logfle = @ScriptDir & "\Record.log"
$oldlist = @ScriptDir & "\Oldgames.txt"
$remfile = @ScriptDir & "\Removals.ini"
$savefile = @ScriptDir & "\Saved.html"
$templist = @ScriptDir & "\List.txt"
$zoomlist = @ScriptDir & "\Games.csv"

$update = "(updated February 2022)"
$version = "v1.7"

If Not FileExists($images) Then DirCreate($images)

$games = ""
If $CmdLine[0] = "" Then
	$method = IniRead($inifle, "Program", "method", "")
	If $method = "" Then
		;$method = "dropbox"
		$method = "gui"
		IniWrite($inifle, "Program", "method", $method)
	EndIf
	$window = ""
	If $method = "dropbox" Then
		$ans = MsgBox(262177, "Program Method Query", _
			"This program can be used in two different ways." & @LF & @LF & _
			"OK = Dropbox (original method)." & @LF & _
			"CANCEL = Window (new method)." & @LF & @LF & _
			"NOTE - Window has fully automated checking." & @LF & @LF & _
			"(Defaults after 9 seconds to Dropbox)", 9)
		If $ans = 2 Then
			$window = "gui"
		EndIf
	EndIf
	If $method = "dropbox" And $window = "" Then
		Global $DropboxGUI
		;
		$target = @LF & "Drag && Drop" & @LF & "The Saved" & @LF & "ZOOM Platform" & @LF & "Web Page" & @LF & "File HERE"
		DropBox()
	ElseIf $method = "gui" Or $window = "gui" Then
		Global $CheckerGUI
		;
		MainGUI()
	EndIf
Else
	$path = $CmdLine[1]
	If FileExists($path) Then
		$webpage = $path
		ExtractTitles()
		DisplayTitles()
	EndIf
EndIf

Exit

Func MainGUI()
	Local $Button_remove, $Group_method, $Group_status, $Input_dates, $Input_game
	;
	Local $added, $colnum, $dates, $download, $height, $icoI, $icoT, $icoW, $icoX, $imgurl, $ind, $lowid
	Local $released, $revamp, $shell, $store, $stores, $updated, $URL, $user32, $width
	;
	$width = 870
	$height = 405
	$left = IniRead($inifle, "GUI Window", "left", @DesktopWidth - $width - 25)
	$top = IniRead($inifle, "GUI Window", "top", @DesktopHeight - $height - 60)
	$style = $WS_OVERLAPPED + $WS_CAPTION + $WS_SYSMENU + $WS_MINIMIZEBOX + $WS_VISIBLE ; + $WS_POPUP
	$CheckerGUI = GuiCreate("ZOOM Checker " & $version, $width - 5, $height, $left, $top, $style, $WS_EX_TOPMOST) ; + $WS_SIZEBOX
	GUISetBkColor(0x00B95C, $CheckerGUI)
	; CONTROLS 0xBBFFBB
	$Group_games = GuiCtrlCreateGroup("Games", 10, 10, $width - 25, 322)
	;GUICtrlSetColor($Group_games, $COLOR_WHITE)
	$ListView_games = GUICtrlCreateListView("No.|Game|Start|Low|High|Prior|Price|State", 20, 30, $width - 45, 260, $LVS_SHOWSELALWAYS + $LVS_SINGLESEL + $LVS_REPORT, _
													$LVS_EX_FULLROWSELECT + $LVS_EX_GRIDLINES) ; + $LVS_NOCOLUMNHEADER + $LVS_EX_CHECKBOXES
	GUICtrlSetBkColor($ListView_games, 0xF0D0F0)
	GUICtrlSetState($ListView_games, $GUI_HIDE)
	;GUICtrlSetResizing($ListView_games, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKHEIGHT + $GUI_DOCKRIGHT)
	$Input_game = GUICtrlCreateInput("", 20, 300, $width - 360, 20)
	;GUICtrlSetResizing($Input_game, $GUI_DOCKLEFT + $GUI_DOCKAUTO)
	GUICtrlSetTip($Input_game, "Selected game title!")
	$Input_dates = GUICtrlCreateInput("", $width - 335, 300, 140, 20, $ES_CENTER)
	;GUICtrlSetResizing($Input_dates, $GUI_DOCKLEFT + $GUI_DOCKAUTO)
	GUICtrlSetTip($Input_dates, "Dates for selected game title!")
	;
	$Button_fav = GuiCtrlCreateButton("FAV", $width - 190, 299, 45, 22)
	GUICtrlSetFont($Button_fav, 7, 600, 0, "Small Fonts")
	;GUICtrlSetResizing($Button_fav, $GUI_DOCKRIGHT + $GUI_DOCKALL + $GUI_DOCKSIZE)
	GUICtrlSetTip($Button_fav, "Set selected game as a favorite!")
	;
	$Combo_own = GUICtrlCreateCombo("", $width - 140, 299, 70, 21)
	;GUICtrlSetResizing($Combo_own, $GUI_DOCKRIGHT + $GUI_DOCKALL + $GUI_DOCKSIZE)
	GUICtrlSetTip($Combo_own, "Store owned at!")
	$Button_own = GuiCtrlCreateButton("OWN", $width - 70, 298, 45, 23)
	GUICtrlSetFont($Button_own, 7, 600, 0, "Small Fonts")
	;GUICtrlSetResizing($Button_own, $GUI_DOCKRIGHT + $GUI_DOCKALL + $GUI_DOCKSIZE)
	GUICtrlSetTip($Button_own, "Set selected game as owned!")
	;
	$Group_method = GuiCtrlCreateGroup("Program Method", 10, $height - 65, 150, 55)
	;GUICtrlSetResizing($Group_method, $GUI_DOCKLEFT + $GUI_DOCKALL + $GUI_DOCKSIZE)
	$Radio_gui = GUICtrlCreateRadio("Window", 20, $height - 44,  60, 20)
	;GUICtrlSetBkColor($Radio_gui, $COLOR_WHITE)
	;GUICtrlSetResizing($Radio_gui, $GUI_DOCKLEFT + $GUI_DOCKALL + $GUI_DOCKSIZE)
	GUICtrlSetTip($Radio_gui, "Show this window when program runs!")
	$Radio_box = GUICtrlCreateRadio("Dropbox", 90, $height - 44,  60, 20)
	;GUICtrlSetResizing($Radio_box, $GUI_DOCKLEFT + $GUI_DOCKALL + $GUI_DOCKSIZE)
	GUICtrlSetTip($Radio_box, "Show the dropbox when program runs!")
	;
	$Group_status = GuiCtrlCreateGroup("Status", 170, $height - 65, 190, 55)
	;GUICtrlSetResizing($Group_status, $GUI_DOCKLEFT + $GUI_DOCKALL + $GUI_DOCKSIZE)
	$Label_status = GuiCtrlCreateLabel("", 180, $height - 45, 170, 20, $SS_CENTER + $SS_CENTERIMAGE + $SS_SUNKEN)
	;GUICtrlSetResizing($Label_status, $GUI_DOCKLEFT + $GUI_DOCKALL + $GUI_DOCKSIZE)
	GUICtrlSetBkColor($Label_status, $COLOR_WHITE)
	GUICtrlSetTip($Label_status, "Process Status!")
	;
	$Button_remove = GuiCtrlCreateButton("REMOVE", $width - 495, $height - 60, 75, 24)
	GUICtrlSetFont($Button_remove, 8, 600)
	;GUICtrlSetResizing($Button_remove, $GUI_DOCKRIGHT + $GUI_DOCKALL + $GUI_DOCKSIZE)
	GUICtrlSetTip($Button_remove, "Set the selected game for removal!")
	;
	$Button_apply = GuiCtrlCreateButton("APPLY", $width - 495, $height - 32, 75, 22)
	GUICtrlSetFont($Button_apply, 8, 600)
	;GUICtrlSetResizing($Button_save, $GUI_DOCKRIGHT + $GUI_DOCKALL + $GUI_DOCKSIZE)
	GUICtrlSetTip($Button_apply, "APPLY the removals!")
	;
	$Button_detail = GuiCtrlCreateButton("DETAIL", $width - 410, $height - 60, 70, 24)
	GUICtrlSetFont($Button_detail, 8, 600)
	;GUICtrlSetResizing($Button_detail, $GUI_DOCKRIGHT + $GUI_DOCKALL + $GUI_DOCKSIZE)
	GUICtrlSetTip($Button_detail, "Detail for selected game!")
	;
	$Button_save = GuiCtrlCreateButton("SAVE", $width - 410, $height - 32, 70, 22)
	GUICtrlSetFont($Button_save, 8, 600)
	;GUICtrlSetResizing($Button_save, $GUI_DOCKRIGHT + $GUI_DOCKALL + $GUI_DOCKSIZE)
	GUICtrlSetTip($Button_save, "SAVE detail for selected game!")
	;
	$Button_check = GuiCtrlCreateButton("CHECK", $width - 330, $height - 60, 75, 50)
	GUICtrlSetFont($Button_check, 9, 600)
	;GUICtrlSetResizing($Button_check, $GUI_DOCKRIGHT + $GUI_DOCKALL + $GUI_DOCKSIZE)
	GUICtrlSetTip($Button_check, "Check for current games & prices!")
	;
	$Button_web = GuiCtrlCreateButton("WEB", $width - 245, $height - 60, 50, 50, $BS_ICON)
	;GUICtrlSetResizing($Button_web, $GUI_DOCKRIGHT + $GUI_DOCKALL + $GUI_DOCKSIZE)
	GUICtrlSetTip($Button_web, "Go to the web page for selected game!")
	;
	$Button_log = GuiCtrlCreateButton("LOG", $width - 185, $height - 60, 50, 50, $BS_ICON)
	;GUICtrlSetResizing($Button_log, $GUI_DOCKRIGHT + $GUI_DOCKALL + $GUI_DOCKSIZE)
	GUICtrlSetTip($Button_log, "View the log record!")
	;
	$Button_info = GuiCtrlCreateButton("Info", $width - 125, $height - 60, 50, 50, $BS_ICON)
	;GUICtrlSetResizing($Button_info, $GUI_DOCKRIGHT + $GUI_DOCKALL + $GUI_DOCKSIZE)
	GUICtrlSetTip($Button_info, "Program Information!")
	;
	$Button_quit = GuiCtrlCreateButton("EXIT", $width - 65, $height - 60, 50, 50, $BS_ICON)
	;GUICtrlSetResizing($Button_quit, $GUI_DOCKRIGHT + $GUI_DOCKALL + $GUI_DOCKSIZE)
	GUICtrlSetTip($Button_quit, "Exit / Close / Quit the program!")
	;
	$lowid = $Button_quit + 1
	;
	; OS SETTINGS
	$user32 = @SystemDir & "\user32.dll"
	$shell = @SystemDir & "\shell32.dll"
	$icoI = -5
	$icoT = -71
	;$icoR = -239
	$icoW = -14
	$icoX = -4
	;
	; SETTINGS
	GUICtrlSetImage($Button_web, $shell, $icoW, 1)
	GUICtrlSetImage($Button_log, $shell, $icoT, 1)
	GUICtrlSetImage($Button_info, $user32, $icoI, 1)
	GUICtrlSetImage($Button_quit, $user32, $icoX, 1)
	;
	$stores = IniRead($inifle, "Game Stores", "names", "")
	If $stores = "" Then
		$stores = "||BigFish|Epic|GOG|Humble|IndieGala|Itch|Microsoft|Multiple|Steam|ZOOM|"
		IniWrite($inifle, "Game Stores", "names", $stores)
	EndIf
	GUICtrlSetData($Combo_own, $stores, "")
	;
	GUICtrlSetState($Button_remove, $GUI_DISABLE)
	;
	If $method = "gui" Then
		GUICtrlSetState($Radio_gui, $GUI_CHECKED)
	ElseIf $method = "dropbox" Then
		GUICtrlSetState($Radio_box, $GUI_CHECKED)
	EndIf
	;
	SetStateOfControls($GUI_DISABLE)
	$removals = "|"
	LoadTheList()
	SetStateOfControls($GUI_ENABLE)
	;
	GUICtrlSetState($ListView_games, $GUI_SHOW)

	GUISetState(@SW_SHOW)
	While True
		$msg = GUIGetMsg()
		Select
			Case $msg = $GUI_EVENT_CLOSE Or $msg = $Button_quit
				; Exit / Close / Quit the program
				$winpos = WinGetPos($CheckerGUI, "")
				$left = $winpos[0]
				If $left < 0 Then
					$left = 2
				ElseIf $left > @DesktopWidth - $winpos[2] Then
					$left = @DesktopWidth - $winpos[2]
				EndIf
				IniWrite($inifle, "GUI Window", "left", $left)
				$top = $winpos[1]
				If $top < 0 Then
					$top = 2
				ElseIf $top > @DesktopHeight - $winpos[3] Then
					$top = @DesktopHeight - $winpos[3]
				EndIf
				IniWrite($inifle, "GUI Window", "top", $top)
				;
				GUIDelete($CheckerGUI)
				ExitLoop
			Case $msg = $Button_web
				; Go to the web page for selected game
				$ind = _GUICtrlListView_GetSelectedIndices($ListView_games, True)
				If IsArray($ind) Then
					If $ind[0] > 0 Then
						$ind = $ind[1]
						If $ind > -1 Then
							$game = _GUICtrlListView_GetItemText($ListView_games, $ind, 1)
							FixTheTitle()
							$ping = Ping("zoom-platform.com", 5000)
							If $ping > 0 Then
								ShellExecute("https://zoom-platform.com/product/" & $title)
							Else
								MsgBox(262192, "Web Error", "No connection detected!", 0, $GOGcliGUI)
							EndIf
						EndIf
					Else
						MsgBox(262192, "Selection Error", "Please select a game title!", 0, $CheckerGUI)
					EndIf
				Else
					MsgBox(262192, "Selection Error", "Please select a game title!", 0, $CheckerGUI)
				EndIf
			Case $msg = $Button_save
				; SAVE detail for selected game
				$ind = _GUICtrlListView_GetSelectedIndices($ListView_games, True)
				If IsArray($ind) Then
					If $ind[0] > 0 Then
						$ind = $ind[1]
						If $ind > -1 Then
							$game = _GUICtrlListView_GetItemText($ListView_games, $ind, 1)
							FixTheTitle()
							GUICtrlSetData($Label_status, "Please Wait - Retrieving Data")
							;GUISetState($CheckerGUI, @SW_DISABLE)
							GUICtrlSetState($Button_remove, $GUI_DISABLE)
							GUICtrlSetData($Input_game, "")
							GUICtrlSetData($Input_dates, "")
							GUICtrlSetData($Combo_own, $stores, "")
							SetStateOfControls($GUI_DISABLE)
							$ping = Ping("zoom-platform.com", 5000)
							If $ping > 0 Then
								_FileWriteLog($logfle, "Retrieving Data - " & $game)
								_FileCreate($savefile)
								$URL = "https://zoom-platform.com/product/" & $title
								$download = InetGet($URL, $savefile, 0, 0)
								InetClose($download)
								_FileWriteLog($logfle, "Retrieving Finished.")
								If FileExists($savefile) Then
									$read = FileRead($savefile)
									If $read <> "" Then
										$blurb = StringSplit($read, '<meta name="description" content="', 1)
										If $blurb[0] = 2 Then
											$blurb = $blurb[2]
											$blurb = StringSplit($blurb, '">', 1)
											$blurb = $blurb[1]
											$blurb = StringReplace($blurb, "&#039;", "'")
											$blurb = StringReplace($blurb, 'â€“', '-')
											$blurb = StringReplace($blurb, 'â€œ', '"')
											$blurb = StringReplace($blurb, 'â€', '"')
											If $blurb <> "" Then
												_FileWriteLog($logfle, "Summary Downloaded - " & $game)
												IniWrite($blurbs, $game, "blurb", $blurb)
											EndIf
										EndIf
										$imgurl = StringSplit($read, '<meta property="og:image" content="', 1)
										If $imgurl[0] = 2 Then
											$imgurl = $imgurl[2]
											$imgurl = StringSplit($imgurl, '">', 1)
											$imgurl = $imgurl[1]
											If StringLeft($imgurl, 4) = "http" Then
												$imgfle = $images & "\" & $title & ".jpg"
												$download = InetGet($imgurl, $imgfle, 0, 0)
												InetClose($download)
												If FileExists($imgfle) Then
													_FileWriteLog($logfle, "Image Downloaded - " & $game)
													IniWrite($blurbs, $game, "image", $imgfle)
												EndIf
											EndIf
										EndIf
									EndIf
								EndIf
							Else
								MsgBox(262192, "Web Error", "No connection detected!", 0, $GOGcliGUI)
							EndIf
							SetStateOfControls($GUI_ENABLE)
							GUICtrlSetData($Label_status, "Retrieve Finished")
							;MsgBox(262192, "Feature Error", "Not yet complete!", 0, $CheckerGUI)
						EndIf
					Else
						MsgBox(262192, "Selection Error", "Please select a game title!", 0, $CheckerGUI)
					EndIf
				Else
					MsgBox(262192, "Selection Error", "Please select a game title!", 0, $CheckerGUI)
				EndIf
			Case $msg = $Button_remove
				; Set the selected game for removal
				$ind = _GUICtrlListView_GetSelectedIndices($ListView_games, True)
				If IsArray($ind) Then
					If $ind[0] > 0 Then
						$ind = $ind[1]
						If $ind > -1 Then
							$game = _GUICtrlListView_GetItemText($ListView_games, $ind, 1)
							;$idx = $lowid + $ind
							If $remove = 1 Then
								$remove = ""
								IniDelete($gamesfile, $game, "remove")
								$removals = StringReplace($removals, "|" & $game & "|", "|")
								;If $last <> $checked Then
									GUICtrlSetBkColor($idx, $COLOR_OLIVE)
								;EndIf
								GUICtrlSetData($Button_remove, "REMOVE")
							Else
								$remove = 1
								IniWrite($gamesfile, $game, "remove", $remove)
								$removals = $removals & $game & "|"
								GUICtrlSetBkColor($idx, $COLOR_BLACK)
								GUICtrlSetData($Button_remove, "UNSET")
							EndIf
						EndIf
					EndIf
				EndIf
			Case $msg = $Button_own
				; Set selected game as owned
				If $ind > -1 And $game <> "" Then
					;$idx = $lowid + $ind
					$owned = _GUICtrlListView_GetItemText($ListView_games, $ind, 7)
					If $owned <> "OWN" Then
						$owned = "OWN"
						GUICtrlSetBkColor($idx, $COLOR_SKYBLUE)
						$store = GUICtrlRead($Combo_own)
						If $store = "" Then
							$store = "ZOOM"
							GUICtrlSetData($Combo_own, $store)
						EndIf
						If StringInStr($stores, "|" & $store & "|") < 1 Then
							$stores = $stores & $store & "|"
							GUICtrlSetData($Combo_own, "", "")
							GUICtrlSetData($Combo_own, $stores, $store)
							IniWrite($inifle, "Game Stores", "names", $stores)
						EndIf
						IniWrite($gamesfile, $game, "owned", $owned)
						IniWrite($gamesfile, $game, "store", $store)
					Else
						$owned = ""
						If IsInt($idx / 2) = 1 Then
							GUICtrlSetBkColor($idx, 0xC0F0C0)
						Else
							GUICtrlSetBkColor($idx, 0xF0D0F0)
						EndIf
						$store = ""
						IniDelete($gamesfile, $game, "owned")
						IniDelete($gamesfile, $game, "store")
						GUICtrlSetData($Combo_own, $stores, $store)
					EndIf
					_GUICtrlListView_SetItemText($ListView_games, $ind, $owned, 7)
				EndIf
			Case $msg = $Button_log
				; View the log record
				If FileExists($logfle) Then ShellExecute($logfle)
			Case $msg = $Button_info
				; Program Information
				$ans = MsgBox(262209 + 256, "Program Information", _
					"This program downloads (checks for) a list of all games available" & @LF & _
					"at the ZOOM Platform store. It also keeps a record of important" & @LF & _
					"changes to a game (removal, rename, price)." & @LF & @LF & _
					"Columns can be sorted by clicking on the header." & @LF & @LF & _
					"Redundant entries can be removed (row color is Olive)." & @LF & _
					"A game entry marked for removal has a row color of Black." & @LF & _
					"REMOVE button marks a game for removal or (UNSET) restores." & @LF & _
					"APPLY button removes all listings marked for removal." & @LF & _
					"Removed games populate a file called 'Removals.ini'." & @LF & @LF & _
					"New additions to the list have a row color of Fuchsia, and should" & @LF & _
					"be shown at the end of the unsorted list. Game listings by default" & @LF & _
					"are not necessarily sorted alphanumeric, until the 'Game' column" & @LF & _
					"for title is clicked." & @LF & @LF & _
					"Games can be marked as owned (OWN) or a favorite (FAV), with" & @LF & _
					"the store or stores (Multiple) specified.  Any unlisted store name" & @LF & _
					"can be set, but best to keep them short (so abbreviate if needed)." & @LF & _
					"Row color is Skyblue (owned) or Yellow (favorite)." & @LF & @LF & _
					"Price changes are also indicated by a row color if different to the" & @LF & _
					"'Prior' value - Lime (less) or Red (more)." & @LF & @LF & _
					"The SAVE button uses a web connection to download the web" & @LF & _
					"page for the selected game, extracting & saving the summary." & @LF & _
					"It also downloads the image file. DETAIL button shows both." & @LF & @LF & _
					"A log record is kept for some processes." & @LF & @LF & _
					"BIG THANKS to Adam @ ZOOM Platform for the 'CHECK' link." & @LF & @LF & _
					"© April 2021 by Timboli (aka TheSaint) (updated October 2021)." & @LF & @LF & _
					"OK = View the list of removed games.", 0, $CheckerGUI)
				If $ans = 1 Then
					ShellExecute($remfile)
				EndIf
			Case $msg = $Button_fav
				; Set selected game as a favorite
				$ind = _GUICtrlListView_GetSelectedIndices($ListView_games, True)
				If IsArray($ind) Then
					If $ind[0] > 0 Then
						$ind = $ind[1]
						If $ind > -1 Then
							$game = _GUICtrlListView_GetItemText($ListView_games, $ind, 1)
							$favorite = _GUICtrlListView_GetItemText($ListView_games, $ind, 7)
							If $favorite <> "FAV" Then
								$favorite = "FAV"
								IniWrite($gamesfile, $game, "favorite", $favorite)
								GUICtrlSetBkColor($idx, $COLOR_YELLOW)
							Else
								$favorite = ""
								IniDelete($gamesfile, $game, "favorite")
								If IsInt($idx / 2) = 1 Then
									GUICtrlSetBkColor($idx, 0xC0F0C0)
								Else
									GUICtrlSetBkColor($idx, 0xF0D0F0)
								EndIf
							EndIf
							_GUICtrlListView_SetItemText($ListView_games, $ind, $favorite, 7)
						EndIf
					Else
						MsgBox(262192, "Selection Error", "Please select a game title!", 0, $CheckerGUI)
					EndIf
				Else
					MsgBox(262192, "Selection Error", "Please select a game title!", 0, $CheckerGUI)
				EndIf
			Case $msg = $Button_detail
				; Detail for selected game
				$ind = _GUICtrlListView_GetSelectedIndices($ListView_games, True)
				If IsArray($ind) Then
					If $ind[0] > 0 Then
						$ind = $ind[1]
						If $ind > -1 Then
							$game = _GUICtrlListView_GetItemText($ListView_games, $ind, 1)
							$start = _GUICtrlListView_GetItemText($ListView_games, $ind, 2)
							$low = _GUICtrlListView_GetItemText($ListView_games, $ind, 3)
							$high = _GUICtrlListView_GetItemText($ListView_games, $ind, 4)
							$prior = _GUICtrlListView_GetItemText($ListView_games, $ind, 5)
							$price = _GUICtrlListView_GetItemText($ListView_games, $ind, 6)
							$dates = IniRead($gamesfile, $game, "date", "")
							$added = StringSplit($dates, " ", 1)
							If $added[0] = 2 Then
								$checked = $added[2]
							Else
								$checked = $added[1]
							EndIf
							$added = $added[1]
							$store = IniRead($gamesfile, $game, "store", "")
							$released = IniRead($gamesfile, $game, "released", "")
							$updated = IniRead($gamesfile, $game, "updated", "")
							$detail = "Title = " & $game
							$detail = $detail & @LF & "Added = " & $added
							$detail = $detail & @LF & "Last Checked = " & $checked
							$detail = $detail & @LF & "Released = " & $released
							$detail = $detail & @LF & "Last Updated = " & $updated
							$detail = $detail & @LF & "Starting Price = " & $start
							$detail = $detail & @LF & "Lowest Price = " & $low
							$detail = $detail & @LF & "Highest Price = " & $high
							$detail = $detail & @LF & "Previous Price = " & $prior
							$detail = $detail & @LF & "Current Price = " & $price
							If $store <> "" Then
								$detail = $detail & @LF & "Game Owned At Store = " & $store
							EndIf
							$blurb = IniRead($blurbs, $game, "blurb", "")
							$imgfle = IniRead($blurbs, $game, "image", "")
							If $imgfle <> "" And FileExists($imgfle) Then
								$detail = StringReplace($detail, @LF, @CRLF)
								DetailGUI()
							Else
								$detail = $detail & @LF & "Summary = " & $blurb
								MsgBox(262208 + 256, "Game Details", $detail, 0, $CheckerGUI)
							EndIf
						EndIf
					Else
						MsgBox(262192, "Selection Error", "Please select a game title!", 0, $CheckerGUI)
					EndIf
				Else
					MsgBox(262192, "Selection Error", "Please select a game title!", 0, $CheckerGUI)
				EndIf
			Case $msg = $Button_check
				; Check for current games & prices
				GUICtrlSetData($Label_status, "Please Wait - Retrieving List")
				;GUISetState($CheckerGUI, @SW_DISABLE)
				GUICtrlSetState($Button_remove, $GUI_DISABLE)
				GUICtrlSetData($Input_game, "")
				GUICtrlSetData($Input_dates, "")
				GUICtrlSetData($Combo_own, $stores, "")
				SetStateOfControls($GUI_DISABLE)
				$ping = Ping("zoom-platform.com", 5000)
				If $ping > 0 Then
					_FileWriteLog($logfle, "Checking Started.")
					$date = _NowDate()
					IniWrite($inifle, "Last Checked", "date", $date)
					$URL = "https://zoom-platform.com/gamedata.csv"
					$download = InetGet($URL, $zoomlist, 0, 0)
					InetClose($download)
					$read = FileRead($gamesfile)
					If StringInStr($read, "released=") > 0 Then
						$revamp = ""
					Else
						$revamp = 1
					EndIf
					$found = 0
					GUICtrlSetData($Label_status, "Please Wait - Parsing List")
					_FileReadToArray($zoomlist, $array)
					For $a = 2 To $array[0]
						$line = $array[$a]
						;$line = StringSplit($line, ',"', 1)
						$line = StringSplit($line, ',', 1)
						If $line[0] = 4 Then
							$game = $line[1]
							$game = StringReplace($game, '"', '')
							$game = StringStripWS($game, 7)
							If $game <> "" Then
								$released = $line[2]
								$released = StringReplace($released, '"', '')
								;$line = $line[3]
								;$line = StringSplit($line, '",', 1)
								;$updated = $line[1]
								$updated = $line[3]
								$updated = StringReplace($updated, '"', '')
								;$price = $line[2]
								$price = $line[4]
								$price = StringReplace($price, '"', '')
								If $price = 0 Then $price = "0.00"
								If $read = "" Then
									; ADD game to list. List created for first time.
									IniWrite($gamesfile, $game, "date", $date)
									IniWrite($gamesfile, $game, "released", $released)
									IniWrite($gamesfile, $game, "updated", $updated)
									;$price = "$" & $price
									IniWrite($gamesfile, $game, "price", $price)
									$start = $price
									IniWrite($gamesfile, $game, "start", $start)
									$low = $price
									IniWrite($gamesfile, $game, "low", $low)
									$high = $price
									IniWrite($gamesfile, $game, "high", $high)
									$prior = $price
									IniWrite($gamesfile, $game, "prior", $prior)
								Else
									; Check if game already exists on list.
									If StringInStr($read, "[" & $game & "]") > 0 Then
										; UPDATE game on list
										$exists = IniRead($gamesfile, $game, "date", "")
										$exists = StringSplit($exists, " ", 1)
										$exists = $exists[1]
										IniWrite($gamesfile, $game, "date", $exists & " (" & $date & ")")
										If $revamp = 1 Then IniWrite($gamesfile, $game, "released", $released)
										IniWrite($gamesfile, $game, "updated", $updated)
										If $revamp = 1 Then
											; ADD new values for the game
											;$price = "$" & $price
											IniWrite($gamesfile, $game, "price", $price)
											$start = $price
											IniWrite($gamesfile, $game, "start", $start)
											$low = $price
											IniWrite($gamesfile, $game, "low", $low)
											$high = $price
											IniWrite($gamesfile, $game, "high", $high)
											$prior = $price
											IniWrite($gamesfile, $game, "prior", $prior)
										Else
											; Check to update some values for the game.
											$last = IniRead($gamesfile, $game, "price", "")
											If $last <> $price Then
												IniWrite($gamesfile, $game, "price", $price)
												$low = IniRead($gamesfile, $game, "low", "")
												$high = IniRead($gamesfile, $game, "high", "")
												If $price < $low Then
													$low = $price
													IniWrite($gamesfile, $game, "low", $low)
												ElseIf $price > $high Then
													$high = $price
													IniWrite($gamesfile, $game, "high", $high)
												EndIf
												$prior = $last
												IniWrite($gamesfile, $game, "prior", $prior)
											EndIf
										EndIf
									Else
										; ADD game to list
										IniWrite($gamesfile, $game, "date", $date)
										IniWrite($gamesfile, $game, "released", $released)
										IniWrite($gamesfile, $game, "updated", $updated)
										;$price = "$" & $price
										IniWrite($gamesfile, $game, "price", $price)
										$start = $price
										IniWrite($gamesfile, $game, "start", $start)
										$low = $price
										IniWrite($gamesfile, $game, "low", $low)
										$high = $price
										IniWrite($gamesfile, $game, "high", $high)
										$prior = $price
										IniWrite($gamesfile, $game, "prior", $prior)
									EndIf
								EndIf
								$found = $found + 1
							EndIf
						Else
							MsgBox(262192, "Split Issue", $line & @LF & @LF & "(game entry skipped)", 0, $CheckerGUI)
						EndIf
					Next
					_FileWriteLog($logfle, "Checking Finished.")
					_FileWriteLog($logfle, "Games Found = " & $found)
					GUICtrlSetData($Label_status, "Retrieved List")
					_GUICtrlListView_BeginUpdate($ListView_games)
					_GUICtrlListView_DeleteAllItems($ListView_games)
					_GUICtrlListView_EndUpdate($ListView_games)
					;GUISetState($CheckerGUI, @SW_ENABLE)
					LoadTheList()
					IniWrite($inifle, "Games Found", "total", $found)
					MsgBox(262208 + 256, "Check Result", $found & " games were discovered.", 0, $CheckerGUI)
				Else
					MsgBox(262192, "Web Error", "No connection detected!", 0, $GOGcliGUI)
				EndIf
				SetStateOfControls($GUI_ENABLE)
			Case $msg = $Button_apply
				; APPLY the removals
				If $removals = "|" Then
					MsgBox(262192, "Removals Error", "No entries are marked for removal!", 0, $CheckerGUI)
				Else
					$ans = MsgBox(262193, "Removals Query", _
						"Remove all games marked for removal?" & @LF & @LF & _
						"OK = Continue with removals." & @LF & _
						"CANCEL = Abort any removals." & @LF & @LF & _
						"NOTE - This will be permanent, but a copy" & @LF & _
						"is kept in the 'Removals.ini' file." & @LF & @LF & _
						"ADVICE - It is recommended to sort by game" & @LF & _
						"title before removing a game. Those games" & @LF & _
						"eligible for removal, either no longer exist at" & @LF & _
						"the store or have been renamed.  Duplicate," & @LF & _
						"but not quite identical names can be listed," & @LF & _
						"and you may only wish to remove one type" & @LF & _
						"of redundant entry. Some titles may not be" & @LF & _
						"identical enough to be sorted together, as" & @LF & _
						"can be the case when a period is involved" & @LF & _
						"(i.e. AIM and A.I.M.).", 0, $CheckerGUI)
					If $ans = 1 Then
						GUICtrlSetData($Label_status, "Removing Marked Entries")
						GUICtrlSetData($Button_remove, "REMOVE")
						GUICtrlSetState($Button_remove, $GUI_DISABLE)
						GUICtrlSetData($Input_game, "")
						GUICtrlSetData($Input_dates, "")
						GUICtrlSetData($Combo_own, $stores, "")
						SetStateOfControls($GUI_DISABLE)
						_GUICtrlListView_BeginUpdate($ListView_games)
						_GUICtrlListView_DeleteAllItems($ListView_games)
						_GUICtrlListView_EndUpdate($ListView_games)
						$removed = 0
						$sect = StringSplit($removals, "|", 1)
						For $s = 2 To $sect[0] - 1
							$game = $sect[$s]
							If $game <> "" Then
								$entry = IniReadSection($gamesfile, $game)
								If @error = 0 Then
									IniWriteSection($remfile, $game, $entry)
									IniDelete($remfile, $game, "remove")
									If IniRead($remfile, $game, "date", "") <> "" Then
										IniDelete($gamesfile, $game)
										_FileWriteLog($logfle, "Game Removed = " & $game)
										$removals = StringReplace($removals, "|" & $game & "|", "|")
										$removed = $removed + 1
									Else
										_FileWriteLog($logfle, "Removal Error = " & $game)
									EndIf
								Else
									_FileWriteLog($logfle, "Removal Error = " & $game)
								EndIf
							EndIf
						Next
						LoadTheList()
						SetStateOfControls($GUI_ENABLE)
						MsgBox(262208 + 256, "Removals Result", "Game entries removed = " & $removed, 0, $CheckerGUI)
					EndIf
				EndIf
			Case $msg = $ListView_games Or $msg > $Button_quit
				; Games To Check
				If $msg = $ListView_games Then
					$colnum = GUICtrlGetState($ListView_games)
					If StringInStr("01234567", $colnum) > 0 Then
						GUICtrlSetData($Label_status, "Please Wait - Sorting")
						;GUISetState($CheckerGUI, @SW_LOCK + @SW_DISABLE)
						SetStateOfControls($GUI_DISABLE)
						_GUICtrlListView_BeginUpdate($ListView_games)
						_GUICtrlListView_SimpleSort($ListView_games, False, $colnum)
						_GUICtrlListView_EndUpdate($ListView_games)
						;GUISetState($CheckerGUI, @SW_ENABLE + @SW_UNLOCK)
						SetStateOfControls($GUI_ENABLE)
						GUICtrlSetData($Label_status, "List Sorted")
					EndIf
				Else
					$ind = _GUICtrlListView_GetSelectedIndices($ListView_games, True)
					If IsArray($ind) Then
						If $ind[0] > 0 Then
							$ind = $ind[1]
							If $ind > -1 Then
								$game = _GUICtrlListView_GetItemText($ListView_games, $ind, 1)
								GUICtrlSetData($Input_game, $game)
								$dates = IniRead($gamesfile, $game, "date", "")
								GUICtrlSetData($Input_dates, $dates)
								$store = IniRead($gamesfile, $game, "store", "")
								If $store = "" Then
									GUICtrlSetData($Combo_own, $stores, $store)
								Else
									;GUICtrlSetData($Combo_own, "", "")
									;GUICtrlSetData($Combo_own, $stores, $store)
									GUICtrlSetData($Combo_own, $store)
								EndIf
								$remove = IniRead($gamesfile, $game, "remove", "")
								$last = IniRead($inifle, "Last Checked", "date", "")
								$checked = StringSplit($dates, " ", 1)
								If $checked[0] = 2 Then
									$checked = $checked[2]
									$checked = StringReplace($checked, "(", "")
									$checked = StringReplace($checked, ")", "")
									$checked = StringStripWS($checked, 7)
								Else
									$checked = $checked[1]
								EndIf
								;If StringInStr($dates, " ") < 1 Then
								;	If $last = $dates Then
									If $last = $checked Then
										GUICtrlSetState($Button_remove, $GUI_DISABLE)
										GUICtrlSetData($Button_remove, "REMOVE")
									Else
										GUICtrlSetState($Button_remove, $GUI_ENABLE)
										If $remove = 1 Then
											GUICtrlSetData($Button_remove, "UNSET")
										Else
											GUICtrlSetData($Button_remove, "REMOVE")
										EndIf
									EndIf
								;Else
								;	GUICtrlSetState($Button_remove, $GUI_DISABLE)
								;EndIf
							Else
								$game = ""
								GUICtrlSetData($Input_game, $game)
								$dates = ""
								GUICtrlSetData($Input_dates, $dates)
								$store = ""
								GUICtrlSetData($Combo_own, $stores, $store)
								$checked = ""
								$remove = ""
								GUICtrlSetData($Button_remove, "REMOVE")
							EndIf
						EndIf
					EndIf
					;MsgBox(262192, "Selected", $msg, 0, $CheckerGUI)
					$idx = $msg
				EndIf
			Case $msg = $Radio_gui
				; Show this window when program runs
				$method = "gui"
				IniWrite($inifle, "Program", "method", $method)
			Case $msg = $Radio_box
				; Show the dropbox when program runs
				$method = "dropbox"
				IniWrite($inifle, "Program", "method", $method)
				MsgBox(262192, "Advice & Warning", "To go back to using the older 'Dropbox' method," & @LF & _
					"you now need to close and restart this program." & @LF & @LF & _
					"WARNING - This program update is still in the" & @LF & _
					"development stage, so it is not recommended" & @LF & _
					"to swap between methods right now.", 0, $CheckerGUI)
			Case Else
		EndSelect
	WEnd
EndFunc ;=> MainGUI

Func DetailGUI()
	Local $Button_blurb, $Button_image, $Edit_blurb, $Edit_detail, $Group_blurb, $Group_detail, $Group_image, $Pic_image
	Local $DetailsGUI, $imgfile, $pos, $pth, $res, $savfold, $sumfile
	;
	$DetailsGUI = GUICreate("Game Details", 520, 500, Default, Default, $WS_CAPTION + $WS_POPUP + $WS_CLIPSIBLINGS + $WS_SYSMENU, $WS_EX_TOPMOST)
	;
	; CONTROLS
	$Group_image = GUICtrlCreateGroup("Game Image", 10, 10, 220, 335)
	$Pic_image = GUICtrlCreatePic($imgfle, 20, 30, 200, 300)
	;
	$Group_detail = GUICtrlCreateGroup("Other Details", 240, 10, 270, 225)
	$Edit_detail = GUICtrlCreateEdit($detail, 250, 30, 250, 190, $ES_WANTRETURN)
	;
	$Button_image = GUICtrlCreateButton("SAVE IMAGE FILE TO SELECTED LOCATION", 240, 245, 270, 45)
	GUICtrlSetFont($Button_image, 7, 600, 0, "Small Fonts")
	GUICtrlSetTip($Button_image, "Save the game image to a selected location!")
	;
	$Button_blurb = GUICtrlCreateButton("SAVE SUMMARY TO SELECTED LOCATION", 240, 300, 270, 45)
	GUICtrlSetFont($Button_blurb, 7, 600, 0, "Small Fonts")
	GUICtrlSetTip($Button_blurb, "Save the game summary to a selected location!")
	;
	$Group_blurb = GUICtrlCreateGroup("Summary", 10, 355, 500, 135)
	$Edit_blurb = GUICtrlCreateEdit($blurb, 20, 375, 480, 100, $ES_WANTRETURN + $WS_VSCROLL + $ES_AUTOVSCROLL)
	;
	; SETTINGS
	GUICtrlSetState($Pic_image, $GUI_FOCUS)
	;
	FixTheTitle()
	$imgfile = IniRead($inifle, "Save Image", "path", $title & ".jpg")
	$sumfile = IniRead($inifle, "Save Summary", "path", "Summary.txt")

	GUISetState(@SW_SHOW)
	While True
		$msg = GUIGetMsg()
		Select
			Case $msg = $GUI_EVENT_CLOSE
				; Exit or Close the window
				GUIDelete($DetailsGUI)
				ExitLoop
			Case $msg = $Button_image
				; Save the game image to a selected location
				If FileExists($imgfle) Then
					If $savfold = "" Or Not FileExists($savfold) Then
						$savfold = "::{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
					EndIf
					$pth = FileSaveDialog("Browse to save the image file.", $savfold, "Image files (*.jpg)", 18, $imgfile, $DetailsGUI)
					If Not @error And StringMid($pth, 2, 2) = ":\" Then
						$imgfile = $pth
						IniWrite($inifle, "Save Image", "path", $imgfile)
						$res = FileCopy($imgfle, $imgfile, 1)
						If $res = 0 Then
							MsgBox(262192, "Save Error", "Copy failed, perhaps due to permissions!", 0, $DetailsGUI)
						Else
							_FileWriteLog($logfle, "Image Saved - " & $game)
						EndIf
					EndIf
				Else
					MsgBox(262192, "Save Error", "The image file is not set or doesn't exist!", 0, $DetailsGUI)
				EndIf
				GUICtrlSetState($Pic_image, $GUI_FOCUS)
			Case $msg = $Button_blurb
				; Save the game summary to a selected location
				If $blurb <> "" Then
					If $savfold = "" Or Not FileExists($savfold) Then
						$savfold = "::{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
					EndIf
					$pth = FileSaveDialog("Browse to save a summary file.", $savfold, "Text files (*.txt)", 18, $sumfile, $DetailsGUI)
					If Not @error And StringMid($pth, 2, 2) = ":\" Then
						$sumfile = $pth
						_FileCreate($sumfile)
						IniWrite($inifle, "Save Summary", "path", $sumfile)
						FileWrite($sumfile, $game & @CRLF & $blurb & @CRLF)
						_FileWriteLog($logfle, "Summary Saved - " & $game)
					EndIf
				Else
					MsgBox(262192, "Save Error", "No summary to save!", 0, $DetailsGUI)
				EndIf
				GUICtrlSetState($Pic_image, $GUI_FOCUS)
			Case Else
		EndSelect
	WEnd
EndFunc ;=> DetailGUI

Func DropBox()
	Local $Button_display, $Button_go, $Combo_list, $Item_one, $Label_drop, $Label_status, $Menu_go
	Local $atts, $list, $lists, $listfle, $onetab, $srcfle, $winpos
	;
	$left = IniRead($inifle, "Program Window", "left", -1)
	$top = IniRead($inifle, "Program Window", "top", -1)
	$style = $WS_CAPTION + $WS_POPUP + $WS_CLIPSIBLINGS + $WS_SYSMENU
	$DropboxGUI = GUICreate("ZOOM Checker  " & $version, 225, 160, $left, $top, $style, $WS_EX_TOPMOST + $WS_EX_ACCEPTFILES)
	;
	; CONTROLS
	$Label_drop = GUICtrlCreateLabel($target, 1, 1, 223, 107, $SS_CENTER)
	GUICtrlSetFont($Label_drop, 9, 600)
	GUICtrlSetState($Label_drop, $GUI_DROPACCEPTED)
	GUICtrlSetTip($Label_drop, "Drag & Drop saved ZOOM Platform web page file here!")
	;
	$Label_status = GUICtrlCreateLabel("Click GO to go to the Games web page", 1, 108, 223, 18, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetFont($Label_status, 7, 600, 0, "Small Fonts")
	GUICtrlSetBkColor($Label_status, $COLOR_LIME)
	GUICtrlSetColor($Label_status, $COLOR_BLACK)
	;
	$Button_display = GUICtrlCreateButton("DISPLAY", 2, 132, 70, 23)
	GUICtrlSetFont($Button_display, 7, 600, 0, "Small Fonts")
	GUICtrlSetTip($Button_display, "Display the list of titles!")
	;
	$Combo_list = GUICtrlCreateCombo("", 81, 133, 80, 21)
	GUICtrlSetTip($Combo_list, "View a List file!")
	;
	$Button_go = GUICtrlCreateButton("GO", 170, 132, 52, 23)
	GUICtrlSetFont($Button_go, 7, 600, 0, "Small Fonts")
	GUICtrlSetTip($Button_go, "Go to Games page at ZOOM Platform!")
	;
	; CONTEXT MENU
	$Menu_go = GUICtrlCreateContextMenu($Button_go)
	$Item_one = GUICtrlCreateMenuItem("One TAB", $Menu_go, -1, 0)
	;
	; SETTINGS
	$lists = "||SETTINGS|Titles List|Removed|Added"
	GUICtrlSetData($Combo_list, $lists, "")
	;
	$onetab = IniRead($inifle, "GO Button", "one_tab", "")
	If $onetab = "" Then
		$onetab = 4
		IniWrite($inifle, "GO Button", "one_tab", $onetab)
	EndIf
	GUICtrlSetState($Item_one, $onetab)
	;
	$zoomfold = IniRead($inifle, "SAVE", "path", "")
	$usepth = IniRead($inifle, "SAVE", "use_path", "")
	If $usepth = "" Or $zoomfold = "" Then
		$usepth = 4
		IniWrite($inifle, "SAVE", "use_path", $usepth)
	EndIf
	;
	$wintit = IniRead($inifle, "Save Dialog", "title", "")
	$clip = IniRead($inifle, "Save Dialog", "clipboard", "")
	If $clip = "" Then
		$clip = 4
		IniWrite($inifle, "Save Dialog", "clipboard", $clip)
	EndIf
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
					ElseIf $buttxt = "SAVE" And $usepth = 1 Then
						GUICtrlSetData($Button_go, "READ")
						GUICtrlSetBkColor($Label_status, $COLOR_MONEYGREEN)
						GUICtrlSetData($Label_status, "Click READ to parse the saved web page")
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
					If $usepth = 1 And FileExists($zoomfold) Then
						$savpth = $zoomfold & "\Zoom Platform.html"
						ClipPut($savpth)
						If $wintit <> "" And $clip = 4 Then
							BlockInput(1)
							WinWaitActive($wintit, "", 7)
							If WinExists($wintit, "") Then
								WinActivate($wintit, "")
								Send($savpth)
							EndIf
							BlockInput(0)
						;Else
						;	ClipPut($savpth)
						EndIf
						GUICtrlSetData($Button_go, "READ")
						GUICtrlSetBkColor($Label_status, $COLOR_MONEYGREEN)
						GUICtrlSetData($Label_status, "Click READ to parse the saved web page")
					Else
						GUICtrlSetBkColor($Label_status, $COLOR_SKYBLUE)
						GUICtrlSetData($Label_status, "CTRL with button click changes state")
					EndIf
				ElseIf $buttxt = "READ" Then
					If FileExists($zoomfold) Then
						$webpage = $zoomfold & "\Zoom Platform.html"
						If FileExists($webpage) Then
							GUICtrlSetBkColor($Label_drop, $COLOR_RED)
							GUICtrlSetData($Label_drop, @LF & @LF & @LF & "Please Wait")
							ExtractTitles("drop")
							GUICtrlSetBkColor($Label_drop, $COLOR_GREEN)
							GUICtrlSetData($Label_drop, @LF & @LF & @LF & "Display Viewer")
							DisplayTitles("drop")
							GUICtrlSetData($Label_drop, $target)
							GUICtrlSetBkColor($Label_drop, $COLOR_BLUE)
						Else
							MsgBox(262192, "Read Error", "Saved web page file not found!", 0, $DropboxGUI)
						EndIf
					Else
						MsgBox(262192, "Read Error", "Save folder path does not exist!", 0, $DropboxGUI)
					EndIf
					;
					GUICtrlSetBkColor($Label_status, $COLOR_SKYBLUE)
					GUICtrlSetData($Label_status, "CTRL with button click changes state")
				EndIf
			Case $msg = $Button_display
				; Display the list of titles
				DisplayTitles()
			Case $msg = $Combo_list
				; View a List file
				$list = GUICtrlRead($Combo_list)
				If $list <> "" Then
					If $list = "SETTINGS" Then
						SettingsGUI()
						GUICtrlSetData($Combo_list, $lists, "")
					Else
						If $list = "Titles List" Then
							; View the Titles List file
							$listfle = $gamelist
						Else
							If FileExists($gamesfile) Then
								SplashTextOn("", "Please Wait!", 140, 100, Default, Default, 33)
								$listfle = $templist
								$games = ""
								_FileCreate($templist)
								$read = FileRead($gamesfile)
								$read = StringSplit($read, "[", 1)
								For $r = 2 To $read[0]
									$sect = $read[$r]
									$game = StringSplit($sect, "]", 1)
									$game = $game[1]
									$date = StringSplit($sect, "date=", 1)
									$date = $date[2]
									$date = StringStripWS($date, 3)
									If $list = "Removed" Then
										; View the Removed List
										$last = IniRead($inifle, "Last Checked", "date", "")
										If StringInStr($date, $last) < 1 Then
											$game = $game & " - " & $date & @CRLF
											If $games = "" Then
												$games = $game
											Else
												$games = $games & $game
											EndIf
										EndIf
									ElseIf $list = "Added" Then
										; View the Added List
										If StringInStr($date, " (") < 1 Then
											$game = $game & " - " & $date & @CRLF
											If $games = "" Then
												$games = $game
											Else
												$games = $games & $game
											EndIf
										EndIf
									EndIf
								Next
								;MsgBox(262144, "$games", $games)
								FileWrite($listfle, $games)
								SplashOff()
							Else
								ContinueLoop
							EndIf
						EndIf
						If FileExists($listfle) Then ShellExecute($listfle)
					EndIf
				EndIf
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

Func SettingsGUI()
	Local $Button_info, $Button_path, $Checkbox_clip, $Checkbox_path, $Group_path, $Group_title, $Input_path, $Input_title
	Local $pth, $Settings
	;
	$Settings = GUICreate("Settings", 225, 160, $left, $top, $style, $WS_EX_TOPMOST, $DropboxGUI)
	;
	; CONTROLS
	$Group_path = GUICtrlCreateGroup("Save Path", 5, 5, 215, 70)
	$Input_path = GUICtrlCreateInput("", 15, 23, 170, 20)
	GUICtrlSetTip($Input_path, "The save path for the 'Zoom Platform.html' file!")
	$Button_path = GUICtrlCreateButton("B", 190, 23, 20, 20)
	GUICtrlSetFont($Button_path, 7, 600, 0, "Small Fonts")
	GUICtrlSetTip($Button_path, "Browse to set the save path!")
	$Checkbox_path = GUICtrlCreateCheckbox("Enable use of the stored save path", 22, 48, 190, 20)
	GUICtrlSetTip($Checkbox_path, "Enable use of the save path with SAVE and READ!")
	;
	$Group_title = GUICtrlCreateGroup("Save Dialog Title", 5, 82, 215, 70)
	$Input_title = GUICtrlCreateInput("", 15, 100, 170, 20)
	GUICtrlSetTip($Input_title, "The title of the Save Dialog window!")
	$Button_info = GUICtrlCreateButton("I", 190, 100, 20, 20)
	GUICtrlSetFont($Button_info, 7, 600, 0, "Small Fonts")
	GUICtrlSetTip($Button_info, "Information about saving!")
	$Checkbox_clip = GUICtrlCreateCheckbox("Enable use of the clipboard instead", 22, 125, 190, 20)
	GUICtrlSetTip($Checkbox_clip, "Enable use of the clipboard to paste the save path!")
	;
	; SETTINGS
	GUICtrlSetData($Input_path, $zoomfold)
	GUICtrlSetState($Checkbox_path, $usepth)
	If $zoomfold = "" Then GUICtrlSetState($Checkbox_path, $GUI_DISABLE)
	;
	GUICtrlSetData($Input_title, $wintit)
	GUICtrlSetState($Checkbox_clip, $clip)
	If $clip = 1 Then GUICtrlSetState($Input_title, $GUI_DISABLE)

	GUISetState(@SW_SHOW)
	While True
		$msg = GUIGetMsg()
		Select
			Case $msg = $GUI_EVENT_CLOSE
				; Exit or Close window
				$zoomfold = GUICtrlRead($Input_path)
				IniWrite($inifle, "SAVE", "path", $zoomfold)
				$wintit = GUICtrlRead($Input_title)
				IniWrite($inifle, "Save Dialog", "title", $wintit)
				;
				GUIDelete($Settings)
				ExitLoop
			Case $msg = $Button_path
				; Browse to set the save path
				$pth = FileSelectFolder("Browse to select the Save folder path.", $zoomfold, 7, "", $Settings)
				If Not @error And StringMid($pth, 2, 2) = ":\" Then
					$zoomfold = $pth
					GUICtrlSetData($Input_path, $zoomfold)
					IniWrite($inifle, "SAVE", "path", $zoomfold)
					GUICtrlSetState($Checkbox_path, $GUI_ENABLE)
				EndIf
			Case $msg = $Button_info
				; Information about saving
				MsgBox(262208 + 256, "Save Information", _
					"Enabling some of the Save options can provide a degree" & @LF & _
					"of automation when it comes to saving the web page. A" & @LF & _
					"larger degree of automation is possible by supplying the" & @LF & _
					"title of the popup 'Save As' dialog window as well. If you" & @LF & _
					"want more control, you can elect to manually paste the" & @LF & _
					"Save folder path and file name, into the 'Save As' dialog" & @LF & _
					"window, which will have been automatically copied to" & @LF & _
					"the clipboard for you." & @LF & @LF & _
					"NOTE - Keyboard & Mouse are briefly disabled during" & @LF & _
					"maximum automation, maybe up to several seconds.", 0, $Settings)
			Case $msg = $Checkbox_path
				; Enable use of the save path with SAVE and READ
				If GUICtrlRead($Checkbox_path) = $GUI_CHECKED Then
					$usepth = 1
				Else
					$usepth = 4
				EndIf
				IniWrite($inifle, "SAVE", "use_path", $usepth)
			Case $msg = $Checkbox_clip
				; Enable use of the clipboard to paste the save pat
				If GUICtrlRead($Checkbox_clip) = $GUI_CHECKED Then
					$clip = 1
					GUICtrlSetState($Input_title, $GUI_DISABLE)
				Else
					$clip = 4
					GUICtrlSetState($Input_title, $GUI_ENABLE)
				EndIf
				IniWrite($inifle, "Save Dialog", "clipboard", $clip)
			Case Else
				;
		EndSelect
	WEnd
EndFunc ;=> SettingsGUI


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
		If FileExists($gamesfile) Then FileCopy($gamesfile, $gamesfile & ".bak", 1)
		$date = _NowDate()
		For $a = 1 To $array[0]
			$line = $array[$a]
			If StringInStr($line, '</div> <div class="text-gray-400 text-xs truncate">') > 0 Then
				$game = StringSplit($line, '</div> <div class="text-gray-400 text-xs truncate">', 1)
				$game = $game[1]
				$game =  StringSplit($game, '">', 1)
				$game = $game[$game[0]]
			ElseIf StringInStr($line, '<span class="truncate" title="') > 0 Then
				$game = StringSplit($line, '<span class="truncate" title="', 1)
				$game = $game[2]
				$game =  StringSplit($game, '">', 1)
				$game = $game[1]
				$game = StringReplace($game, "&#39;", "'")
			EndIf
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
				$game = ""
			EndIf
		Next
		If $games <> "" Then
			_FileCreate($gamelist)
			FileWrite($gamelist, $games)
			IniWrite($inifle, "Last Checked", "date", $date)
			IniWrite($inifle, "Games Found", "total", $found)
		Else
			MsgBox(262192, "Extract Error", "Could not detect any games!", 0, $DropboxGUI)
		EndIf
	Else
		MsgBox(262192, "Read Error", "Could not create an array!", 0, $DropboxGUI)
	EndIf
	If $drop = "" Then SplashOff()
EndFunc ;=> ExtractTitles

Func FixTheTitle()
	$title = StringLower($game)
	$title = StringReplace($title, " - ", " ")
	$title = StringReplace($title, "&", "")
	$title = StringReplace($title, "_", "")
	$title = StringReplace($title, ".", "")
	$title = StringReplace($title, ",", "")
	$title = StringReplace($title, ":", "")
	$title = StringReplace($title, ";", "")
	$title = StringReplace($title, "(", "")
	$title = StringReplace($title, ")", "")
	$title = StringReplace($title, "{", "")
	$title = StringReplace($title, "}", "")
	$title = StringReplace($title, "[", "")
	$title = StringReplace($title, "]", "")
	$title = StringReplace($title, "\", "")
	$title = StringReplace($title, "/", "")
	$title = StringReplace($title, "<", "")
	$title = StringReplace($title, ">", "")
	$title = StringReplace($title, "'", "")
	$title = StringReplace($title, '"', '')
	$title = StringReplace($title, "!", "")
	$title = StringReplace($title, "?", "")
	$title = StringReplace($title, "#", "")
	$title = StringReplace($title, "+", "")
	$title = StringReplace($title, "|", "")
	$title = StringReplace($title, "=", "")
	$title = StringReplace($title, "*", "")
	$title = StringReplace($title, "%", "")
	$title = StringReplace($title, "$", "")
	$title = StringReplace($title, "@", "")
	$title = StringReplace($title, "~", "")
	$title = StringReplace($title, "^", "")
	$title = StringReplace($title, "`", "")
	$title = StringStripWS($title, 7)
	$title = StringReplace($title, " ", "-")
EndFunc ;=> FixTheTitle

Func LoadTheList()
	$nums = 0
	If FileExists($gamesfile) Then
		GUICtrlSetData($Label_status, "Please Wait - Loading List")
		;GUISetState($CheckerGUI, @SW_DISABLE)
		_GUICtrlListView_BeginUpdate($ListView_games)
		$last = IniRead($inifle, "Last Checked", "date", "")
		$read = FileRead($gamesfile)
		$entries = StringSplit($read, @CRLF & "[", 1)
		For $e = 1 To $entries[0]
			$entry = $entries[$e]
			If $entry <> "" Then
				$game = StringSplit($entry, "]" & @CRLF, 1)
				$game = $game[1]
				If $e = 1 Then $game = StringTrimLeft($game, 1)
				If StringInStr($entry, "start=") > 0 Then
					$start = StringSplit($entry, "start=", 1)
					$start = $start[2]
					$start = StringSplit($start, @CRLF, 1)
					$start = $start[1]
					$low = StringSplit($entry, "low=", 1)
					$low = $low[2]
					$low = StringSplit($low, @CRLF, 1)
					$low = $low[1]
					$high = StringSplit($entry, "high=", 1)
					$high = $high[2]
					$high = StringSplit($high, @CRLF, 1)
					$high = $high[1]
					$prior = StringSplit($entry, "prior=", 1)
					$prior = $prior[2]
					$prior = StringSplit($prior, @CRLF, 1)
					$prior = $prior[1]
					$price = StringSplit($entry, "price=", 1)
					$price = $price[2]
					$price = StringSplit($price, @CRLF, 1)
					$price = $price[1]
				Else
					$start = "0.00"
					$low = "0.00"
					$high = "0.00"
					$prior = "0.00"
					$price = "0.00"
				EndIf
				$date = StringSplit($entry, "date=", 1)
				$date = $date[2]
				$date = StringSplit($date, @CRLF, 1)
				$date = $date[1]
				$checked = StringSplit($date, " ", 1)
				If $checked[0] = 2 Then
					$checked = $checked[2]
					$checked = StringReplace($checked, "(", "")
					$checked = StringReplace($checked, ")", "")
					$checked = StringStripWS($checked, 7)
				Else
					$checked = $checked[1]
				EndIf
				;$favorite = IniRead($gamesfile, $game, "favorite", "")
				If StringInStr($entry, "favorite=") > 0 Then
					$favorite = StringSplit($entry, "favorite=", 1)
					$favorite = $favorite[2]
					$favorite = StringSplit($favorite, @CRLF, 1)
					$favorite = $favorite[1]
				Else
					$favorite = ""
				EndIf
				$case = $favorite
				;$owned = IniRead($gamesfile, $game, "owned", "")
				If StringInStr($entry, "owned=") > 0 Then
					$owned = StringSplit($entry, "owned=", 1)
					$owned = $owned[2]
					$owned = StringSplit($owned, @CRLF, 1)
					$owned = $owned[1]
				Else
					$owned = ""
				EndIf
				If $owned <> "" Then $case = $owned
				$nums = $nums + 1
				$numb = StringRight("000" & $nums, 4)
				$entry = $numb & "|" & $game & "|$" & $start & "|$" & $low & "|$" & $high & "|$" & $prior & "|$" & $price & "|" & $case
				$idx = GUICtrlCreateListViewItem($entry, $ListView_games)
				$remove = IniRead($gamesfile, $game, "remove", "")
				If $remove = 1 Then
					; Game entry has been marked for removal.
					$removals = $removals & $game & "|"
					GUICtrlSetBkColor($idx, $COLOR_BLACK)
				ElseIf StringInStr($date, " ") < 1 Then
					; New entry.
					If $last = $date Then
						; Added on last CHECK date.
						GUICtrlSetBkColor($idx, $COLOR_FUCHSIA)
					Else
						; Not detected on last CHECK. Game is either no longer available at ZP or has been renamed.
						GUICtrlSetBkColor($idx, $COLOR_OLIVE)
					EndIf
				ElseIf $last <> $checked Then
					; Not detected on last CHECK. Game is either no longer available at ZP or has been renamed.
					GUICtrlSetBkColor($idx, $COLOR_OLIVE)
				ElseIf Number($prior) > Number($price) Then
					; Game has been discounted.
					GUICtrlSetBkColor($idx, $COLOR_LIME)
				ElseIf Number($prior) < Number($price) Then
					; Game has been increased in price.
					GUICtrlSetBkColor($idx, $COLOR_RED)
				ElseIf $favorite <> "" Then
					; Game is a favorite
					GUICtrlSetBkColor($idx, $COLOR_YELLOW)
				ElseIf $owned <> "" Then
					; Game is owned at ZOOM Platform or elsewhere.
					GUICtrlSetBkColor($idx, $COLOR_SKYBLUE)
				Else
					; No price change detected.
					; Apply base color or alternate row base color.
					If IsInt($idx / 2) = 1 Then GUICtrlSetBkColor($idx, 0xC0F0C0)
				EndIf
			EndIf
		Next
		GUICtrlSetData($Label_status, "List Loaded")
		_GUICtrlListView_EndUpdate($ListView_games)
		;GUISetState($CheckerGUI, @SW_ENABLE)
	EndIf
	If $nums > 0 Then
		GUICtrlSetData($Group_games, "Games (" & $nums & ")")
	EndIf
	;
	_GUICtrlListView_JustifyColumn($ListView_games, 0, 2)	; No.
	_GUICtrlListView_JustifyColumn($ListView_games, 1, 0)	; Game
	_GUICtrlListView_JustifyColumn($ListView_games, 2, 2)	; Start
	_GUICtrlListView_JustifyColumn($ListView_games, 3, 2)	; Low
	_GUICtrlListView_JustifyColumn($ListView_games, 4, 2)	; High
	_GUICtrlListView_JustifyColumn($ListView_games, 5, 2)	; Prior
	_GUICtrlListView_JustifyColumn($ListView_games, 6, 2)	; Price
	_GUICtrlListView_JustifyColumn($ListView_games, 7, 2)	; Case
	_GUICtrlListView_SetColumnWidth($ListView_games, 0, 45)		; No.
	_GUICtrlListView_SetColumnWidth($ListView_games, 1, 400)	; Game
	_GUICtrlListView_SetColumnWidth($ListView_games, 2, 60)		; Start
	_GUICtrlListView_SetColumnWidth($ListView_games, 3, 60)		; Low
	_GUICtrlListView_SetColumnWidth($ListView_games, 4, 60)		; High
	_GUICtrlListView_SetColumnWidth($ListView_games, 5, 60)		; Prior
	_GUICtrlListView_SetColumnWidth($ListView_games, 6, 60)		; Price
	_GUICtrlListView_SetColumnWidth($ListView_games, 7, 50)		; Case
EndFunc ;=> LoadTheList

Func SetStateOfControls($state)
	GUICtrlSetState($ListView_games, $state)
	GUICtrlSetState($Button_fav, $state)
	GUICtrlSetState($Combo_own, $state)
	GUICtrlSetState($Button_own, $state)
	GUICtrlSetState($Radio_gui, $state)
	GUICtrlSetState($Radio_box, $state)
	;GUICtrlSetState($Button_remove, $state)
	GUICtrlSetState($Button_apply, $state)
	GUICtrlSetState($Button_detail, $state)
	GUICtrlSetState($Button_save, $state)
	GUICtrlSetState($Button_check, $state)
	GUICtrlSetState($Button_web, $state)
	GUICtrlSetState($Button_log, $state)
	GUICtrlSetState($Button_info, $state)
	GUICtrlSetState($Button_quit, $state)
EndFunc ;=> SetStateOfControls
