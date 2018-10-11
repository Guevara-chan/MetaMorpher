; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; MetaMorpher v1.03
; Developed in 2009 by Guevara-chan.
; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

IncludeFile "MetaForm.pb"
EnableExplicit

; --Constants--
#MaxMorph = 1 << 30
#VisMorph = #MaxMorph - 1
#Eng = "aceopxABCEHKMOPTX"
#Rus = "асеорхАВСЕНКМОРТХ"

; --Definitions--
Structure MorphPoint : *Pos.Character : Alt.C : EndStructure     ; Structurizer.
Define Nick.S, Accum, Res.s, Mask, *In.Character, *Out.Character ; Acuumulators.
Define MorphEdge = (?Term-?Tabl)/2-1, Normer, *WinPtr, Outer     ; Cachers.
NewList Morphology.MorphPoint()                                  ; Our main cacher.
Define Offset, *TMorph.MorphPoint                                ; Lister.
; --Macros--
Macro Announce(Text)  : AddGadgetItem(#OutList, -1, Text)  : EndMacro ; Partializer.
Macro ParseNick()     : Trim(Trim(GetGadgetText(#NickFeeder)), #TAB$)  : EndMacro ; Partializer.
Macro OnOff(State)    : DisableGadget(#Nickfeeder, State)  : DisableGadget(#GenButton, State) 
DisableGadget(#OutList, State) : DisableWindow(#MainWindow, State)     : EndMacro ; Partializer.
Macro Centrum(Gadget) : ResizeGadget(Gadget,(WW-GadgetWidth(Gadget))/2,#PB_Ignore,#PB_Ignore,#PB_Ignore)   : EndMacro
Macro Clicked()       : (EventType()=#PB_EventType_LeftClick Or EventType()=#PB_EventType_LeftDoubleClick) : EndMacro

; --Procedures--
Procedure Adjust()
Define WW = WindowWidth(#MainWindow)
Centrum(#AltTxt) : Centrum(#OrigTxt)
EndProcedure

; --MainLoop--
Open_MainWindow() : Adjust()
HideWindow(#MainWindow, #False)      ; Отображаем окно.
*WinPtr = WindowID(#MainWindow)      ; Записываем адрес.
Repeat : Select WaitWindowEvent()    ; Обработка событий.
Case #PB_Event_CloseWindow : End     ; Выход из программы.
Case #PB_Event_SizeWindow : Adjust() ; Выравниваем подписи.
Case #PB_Event_Gadget, #PB_Event_Menu : Accum = GetGadgetState(#OutList)   ; Основной обработчик.
If EventGadget() = #GenButton Or (EventMenu() = 0 And GetActiveGadget() = #NickFeeder) : Nick = ParseNick() ; Если событие.
If Nick And Nick <> Res ; Если есть о чем разговаривать вообще...
OnOff(#True) : Accum = 1  : *In = @Nick : ClearGadgetItems(#OutList)       ; Первичная подготовка.
While *In\C : *Out = ?Tabl : While *Out\C : If *In\C = *Out\C : Accum << 1 ; Тест символа.
AddElement(Morphology()) : *TMorph = @Morphology() : *TMorph\Pos = *In     ; Вписываем позицию...
If *Out - ?Tabl => MorphEdge : *Out - MorphEdge : Else : *Out + MorphEdge : EndIf ; Альтернативный знак (же).
*Tmorph\Alt = *Out\C : Break : EndIf                                      ; Записываем знак и выламываемся.
*Out + SizeOf(Character) : Wend : If Accum = #MaxMorph : Break : EndIf : *In + SizeOf(Character) : Wend
Accum - 1 : Select Accum ; Выводим аннотацию.
Case 0         : Announce("[NO] alternatives found. Try harder.") : OnOff(#False) : Continue ; Ничего не нашли и ладно.
Case #VisMorph : Announce("Morph edge encountered. It would be kind of long...") ; Wow !
Default        : Announce(Str(Accum) + " alternative(s) found:")                 ; Просто выводим список.
EndSelect : Res = Nick : Normer = Accum + 1 : Outer = 0 ; Аннотация выведена, приступаем к морфингу:
While Accum : Mask = 1 ; Для каждого варианта...
ForEach Morphology()   ; Перебираем морфологию...
If Accum & Mask : *TMorph = Morphology() : *TMorph\Pos\C = *TMorph\Alt : EndIf : Mask << 1 ; Перебиваем.
Next : Announce(Str(Normer-Accum) + ".⇒ " + Nick) : Accum - 1 : Nick = Res  ; Завершаем c насущным.
If Outer = 15 : Outer = 0 : UpdateWindow_(*WinPtr) : WindowEvent() : Else : Outer + 1 : EndIf ; Визуализация.
Wend : ClearList(Morphology()) : OnOff(#False) : EndIf ; Очищаем на прощание.
ElseIf Accum>0 And ((EventGadget() = #OutList And Clicked()) Or (EventMenu()=1 And GetActiveGadget()=#OutList))
SetClipboardText(Right(GetGadgetItemText(#OutList, Accum), Len(Nick))) ; Вывод в буффер обемна.
EndIf
EndSelect
ForEver

; --Data tables--
DataSection
Tabl: :Data.S #Eng+#Rus
Term: ; Ender for end.
EndDataSection
; IDE Options = PureBasic 5.40 LTS (Windows - x86)
; Folding = -
; EnableUnicode
; UseIcon = ..\res\Switch.ico
; Executable = MetaMorpher.exe
; CurrentDirectory = ..\