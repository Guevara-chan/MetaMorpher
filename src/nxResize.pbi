CompilerIf Defined(INCLUDE_NXRESIZE, #PB_Constant)=0
#INCLUDE_NXRESIZE=1
;/////////////////////////////////////////////////////////////////////////////////
;***nxResize***
;*
;*©nxSoftWare 2008  (www.nxSoftware.com)
;*======================================
;*   Stephen Rodriguez (srod)
;*   Created with Purebasic 4.3 for Windows.
;*
;*   Platforms:  NT/2000/XP/VISTA.
;*               No promises with 'early' versions of Windows!
;/////////////////////////////////////////////////////////////////////////////////


EnableExplicit

;//////////////////////////////////////////////////////////////////////////////////////////////////////////
;-DECLARES \ PROTOTYPES.
  Declare.i nxResize_GetResize(gadget)
  Declare.i nxResize_SetResize(gadget, flags)

  Declare.i nxResize_ParentProc(hwnd, uMsg, wParam, lParam)
  Declare.i nxResize_Proc(hwnd, uMsg, wParam, lParam)
;//////////////////////////////////////////////////////////////////////////////////////////////////////////


;//////////////////////////////////////////////////////////////////////////////////////////////////////////
;-CONSTANTS \ STRUCTURES.

  #nxResize_PROPOldProc = "nxResize_OldProc"
  #nxResize_PROP = "nxResize_ptr"

  Enumeration
    #nxResize_AnchorLeft = 1
    #nxResize_AnchorTop = 2
    #nxResize_AnchorRight = 4
    #nxResize_AnchorBottom = 8
    #nxResize_AnchorAll = #nxResize_AnchorLeft + #nxResize_AnchorTop + #nxResize_AnchorRight + #nxResize_AnchorBottom
  EndEnumeration

  ;The following structure is used by each gadget being resized dynamically. 
  ;On top of this a gadget being dynamically sized can also be a container for
  ;other gadgets being dynamically sized.
  ;We thus need to subclass carefully.
    Structure _nxResize
      flags.i               ;Combinations of #nxResize_AnchorLeft etc.
      leftmargin.i
      topmargin.i
      rightmargin.i
      bottommargin.i
      oldProc.i
    EndStructure
;//////////////////////////////////////////////////////////////////////////////////////////////////////////


;-LIBRARY FUNCTIONS.

;//////////////////////////////////////////////////////////////////////////////////////////////////////////
;The following function returns a gadget's dynamic resizing attributes.
;It returns a combination of #nxResize_AnchorLeft, #nxResize_AnchorTop, #nxResize_AnchorRight
;#nxResize_AnchorBottom and #nxResize_AnchorAll.
;Returns zero if no attributes are set.
Procedure.i nxResize_GetResize(gadget)
  Protected result, *ptr._nxResize
  If IsGadget(gadget)
    *ptr = GetProp_(GadgetID(gadget), #nxResize_PROP)
    If *ptr
      ProcedureReturn *ptr\flags
    EndIf
  EndIf
  ProcedureReturn 0
EndProcedure
;//////////////////////////////////////////////////////////////////////////////////////////////////////////


;//////////////////////////////////////////////////////////////////////////////////////////////////////////
;The following function sets a gadget for auto resizing.
;If flags = 0 then the resizing is cancelled.
;Returns zero if an error.
ProcedureDLL.i nxResize_SetResize(gadget, flags)
  Protected result, hwnd, parenthWnd, *ptr._nxResize
  Protected rc.RECT
  If IsGadget(gadget)
    hwnd = GadgetID(gadget)
    ;If flags = 0 then the dynamic resizing is to be cancelled.
    ;However, we can only remove the #nxResize_PROP if this gadget is not a container
    ;to others being dynamically sized because of the possible 'chained' subclassing.
      If flags = 0
        *ptr = GetProp_(hwnd, #nxResize_PROP)
        If GetProp_(hwnd, #nxResize_PROPOldProc) = 0 ;Not a container to other gadgets being resized.
          RemoveProp_(hwnd, #nxResize_PROP)
          If *ptr
            SetWindowLongPtr_(hwnd, #GWL_WNDPROC, *ptr\oldProc)
            FreeMemory(*ptr)
          EndIf
        ElseIf *ptr
          *ptr\flags = 0
        EndIf
        result = 1
      Else ;Some form of dynamic resizing is to be enabled.
        ;Has dynamic resizing already been enabled for this gadget?
        *ptr = GetProp_(hwnd, #nxResize_PROP)
        If *ptr = 0 ;No!
          *ptr = AllocateMemory(SizeOf(_nxResize))
          If *ptr
            ;Create a property in which to store a pointer to this structure.
              If SetProp_(hwnd, #nxResize_PROP, *ptr) = 0
                FreeMemory(*ptr)
                ProcedureReturn 0
              EndIf
            ;Subclass the gadget.
              *ptr\oldProc = SetWindowLongPtr_(hwnd, #GWL_WNDPROC, @nxResize_Proc())
          Else
            ProcedureReturn 0
          EndIf
        EndIf
        ;Set the remaining fields of the structure.
          parenthWnd = GetParent_(hwnd)
          GetClientRect_(parenthWnd, rc)
          With *ptr
            \flags = flags
            \leftmargin = GadgetX(gadget)
            \topmargin = GadgetY(gadget)
            \rightmargin = rc\right - \leftmargin - GadgetWidth(gadget)
            \bottommargin = rc\bottom - \topmargin - GadgetHeight(gadget)
          EndWith
        ;Subclass the parent window if not already done through another call to this function.
          If GetProp_(parenthWnd, #nxResize_PROPOldProc) = 0
            SetProp_(parenthWnd, #nxResize_PROPOldProc, SetWindowLongPtr_(parenthWnd, #GWL_WNDPROC, @nxResize_ParentProc()))
          EndIf
        result = 1
      EndIf
  EndIf
  ProcedureReturn result
EndProcedure
;//////////////////////////////////////////////////////////////////////////////////////////////////////////


;-INTERNAL FUNCTIONS.

;//////////////////////////////////////////////////////////////////////////////////////////////////////////
;The following function is the EnumChildProc callback.
Procedure.i nxResize_EnumChilds(hwnd, parenthWnd)
  Protected *ptr._nxResize, ctrlID, l, t, r, b
  Protected parentrc.RECT
  ;Check that the control is an 'immediate child' of the parent.
  If GetParent_(hwnd) = parenthWnd
    ;Check if the child window is set for dynamic resizing.
      *ptr = GetProp_(hwnd, #nxResize_PROP)
      If *ptr And *ptr\flags
        ctrlID = GetDlgCtrlID_(hwnd)
        l = GadgetX(ctrlID) : t = GadgetY(ctrlID) : r = l + GadgetWidth(ctrlID) : b = t + GadgetHeight(ctrlID)
        GetClientRect_(parenthWnd, parentrc)
        If *ptr\flags & #nxResize_AnchorRight
          r = parentrc\right - *ptr\rightmargin
        EndIf
        If *ptr\flags & #nxResize_AnchorLeft = 0
          l = r - GadgetWidth(ctrlID)
        EndIf
        If *ptr\flags & #nxResize_AnchorBottom
          b = parentrc\bottom - *ptr\bottommargin
        EndIf
        If *ptr\flags & #nxResize_AnchorTop = 0
          t = b - GadgetHeight(ctrlID)
        EndIf
        ResizeGadget(ctrlID, l, t, r-l, b-t)
      EndIf
  EndIf
  ProcedureReturn 1
EndProcedure
;//////////////////////////////////////////////////////////////////////////////////////////////////////////


;//////////////////////////////////////////////////////////////////////////////////////////////////////////
;The following function is the subclass procedure for the parents of all gadgets being dynamically resized.
Procedure.i nxResize_ParentProc(hwnd, uMsg, wParam, lParam)
  Protected result, oldProc
  oldproc = GetProp_(hwnd, #nxResize_PROPOldProc)
  Select uMsg
    Case #WM_NCDESTROY
      RemoveProp_(hwnd, #nxResize_PROPOldProc)
    Case #WM_SIZE
      ;Here we loop through all immediate child windows and resize where appropriate.
        EnumChildWindows_(hwnd, @nxResize_EnumChilds(), hwnd)
  EndSelect
  If oldproc
    result = CallWindowProc_(oldproc, hwnd, uMsg, wParam, lParam)
  EndIf
  ProcedureReturn result
EndProcedure
;//////////////////////////////////////////////////////////////////////////////////////////////////////////


;//////////////////////////////////////////////////////////////////////////////////////////////////////////
;The following function is the subclass procedure for all gadgets being dynamically resized.
Procedure.i nxResize_Proc(hwnd, uMsg, wParam, lParam)
  Protected result, *ptr._nxResize, parenthWnd, rc.RECT, gadget, OldProc
  *ptr = GetProp_(hwnd, #nxResize_PROP)
  If *ptr
    oldProc = *ptr\oldproc
    Select uMsg
      Case #WM_NCDESTROY
        RemoveProp_(hwnd, #nxResize_PROP)
        FreeMemory(*ptr)
      Case #WM_MOVE, #WM_SIZE
        gadget = GetDlgCtrlID_(hwnd)
        ;This takes care of the user repositioning\resizing the gadget through ResizeGadget() etc.
        ;In such cases we do not prevent the move but reset the dynamic resizing properties.
        If *ptr\flags And GadgetWidth(gadget) And GadgetHeight(gadget)
          parenthWnd = GetParent_(hwnd)
          GetClientRect_(parenthWnd, rc)
           With *ptr
            \leftmargin = GadgetX(gadget)
            \topmargin = GadgetY(gadget)
            \rightmargin = rc\right - \leftmargin - GadgetWidth(gadget)
            \bottommargin = rc\bottom - \topmargin - GadgetHeight(gadget)
          EndWith
        EndIf
    EndSelect
    result = CallWindowProc_(oldproc, hwnd, uMsg, wParam, lParam)
  Else
    result = DefWindowProc_(hwnd, uMsg, wParam, lParam)
  EndIf  
  ProcedureReturn result
EndProcedure
;//////////////////////////////////////////////////////////////////////////////////////////////////////////

DisableExplicit
CompilerEndIf

; IDE Options = PureBasic 4.41 (Windows - x86)
; Folding = -