; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; MetaMorpher's v1.03 visual interface.
; Developed in 2009 by Guevara-chan.
; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

IncludeFile "nxResize.pbi"
UsePNGImageDecoder()

;- Window Constants
Enumeration
#MainWindow
EndEnumeration

;- Gadget Constants
Enumeration
#OrigTxt
#AltTxt
#NickFeeder
#GenButton
#OutList
#Buser
EndEnumeration

Procedure Open_MainWindow()
LoadFont(1, "Palatino Linotype", 8.5)
LoadFont(2, "Palatino Linotype", 9, #PB_Font_Bold)
OpenWindow(#MainWindow, 300, 200, 280, 278, "=[MetaMorpher v1.03]=", 281935873)
TextGadget(#AltTxt, 0, 40, 80, 20, "Alternatives:", #PB_Text_Center)
TextGadget(#OrigTxt, 0, 0, 80, 20, "Original nick:", #PB_Text_Center)
AddKeyboardShortcut(#MainWindow, #PB_Shortcut_Return, 0)
AddKeyboardShortcut(#MainWindow, #PB_Shortcut_Space, 1)
ButtonGadget(#GenButton, 215, 20, 60, 20, "Generate", #BS_FLAT)
StringGadget(#NickFeeder, 5, 20, 215, 20, "", #PB_String_BorderLess | #WS_BORDER)
ListViewGadget(#OutList, 5, 60, 270, 213)
SetGadgetFont(#GenButton, FontID(1))
SetGadgetFont(#OrigTxt, FontID(2))
SetGadgetFont(#AltTxt, FontID(2))
SetActiveGadget(#NickFeeder)
nxResize_SetResize(#OutList, #nxResize_AnchorAll)
nxResize_SetResize(#GenButton, #nxResize_AnchorRight)
nxResize_SetResize(#NickFeeder, #nxResize_AnchorRight | #nxResize_AnchorLeft)
SmartWindowRefresh(#MainWindow, #True) : WindowBounds(#MainWindow, 241, 212, #PB_Ignore, #PB_Ignore)
SetWindowLong_(WindowID(#MainWindow),#GWL_EXSTYLE,GetWindowLong_(WindowID(#MainWindow), #GWL_EXSTYLE)|#WS_EX_COMPOSITED)
EndProcedure
; IDE Options = PureBasic 5.40 LTS (Windows - x86)
; CursorPosition = 2
; Folding = -
; Executable = ..\MetaMorpher.exe