###########################################################
# Name:    win.tcl
# Author:  Daniele Bonini  (posta@elettronica.lol)
# Date:    26/11/2023
# Desc:    Win namespace of RadXIDE.
#
#          Win namespace scaffolding and most of the code 
#          here presented and distributed contains excerpts 
#          from [alited](https://github.com/aplsimple/alited
#          by Alex Plotnikov and contributors to the project.
#          The original code of these excerpts could be 
#          borrowed from other sources which the author
#          and the contributors to this RadXIDE have no 
#          knowledge about.
#
# License: MIT. Copyrights 5 Mode (Last implementation and adaptations.)
#               Copyright (c) 2021-2023 Alex Plotnikov https://aplsimple.github.io (original scaffolding and excerpts.)
#
###########################################################


namespace eval win {

  array set _PU_opts [list -NONE =NONE=]
  set _PU_opts(_MODALWIN_) [list]
  variable _AP_Properties; array set _AP_Properties [list]
  variable _AP_ICO { none folder OpenFile SaveFile saveall print font color \
    date help home misc terminal run tools file find replace other view \
    categories actions config pin cut copy paste plus minus add delete \
    change diagram box trash double more undo redo up down previous next \
    previous2 next2 upload download tag tagoff tree lock light restricted \
    attach share mail www map umbrella gulls sound heart clock people info \
    err warn ques retry yes no ok cancel exit }
  variable _AP_IMG;  array set _AP_IMG [list]
  variable _AP_VARS; array set _AP_VARS [list]  
  variable UFF "\uFFFF"
  variable querydlg {}
  variable CheckNomore
  array set msgarray [list]
  set Dlgpath ""
  set Dlgname ""  
  set dlg(PATH) ""
  set dlg(NAME) ""
  set dlg(FIELDS) {}
  set Indexdlg 0	
  set _savedvv [list]
  set MODALWINDOW {}
  set Foundstr {}
#  array set data [list]
#  set data(en1) {}
#  set data(docheck) yes 
  set Foundstr {}   ;# current found string
  set HLstring {}   ;# current selected string
  set Widgetopts [list]
  
  set _Defaults [dict create \
    bts {{} {}} \
    but {{} {}} \
    buT {{} {-width -20 -pady 1}} \
    btT {{} {-width -20 -pady 1 -relief flat -overrelief raised -highlightthickness 0 -takefocus 0}} \
    can {{} {}} \
    chb {{} {}} \
    swi {{} {}} \
    chB {{} {-relief sunken -padx 6 -pady 2}} \
    cbx {{} {}} \
    fco {{} {}} \
    ent {{} {}} \
    enT {{} {-insertwidth $::apave::cursorwidth -insertofftime 250 -insertontime 750}} \
    fil {{} {}} \
    fis {{} {}} \
    dir {{} {}} \
    fon {{} {}} \
    clr {{} {}} \
    dat {{} {}} \
    fiL {{} {}} \
    fiS {{} {}} \
    diR {{} {}} \
    foN {{} {}} \
    clR {{} {}} \
    daT {{} {}} \
    sta {{} {}} \
    too {{} {}} \
    fra {{} {}} \
    ftx {{} {}} \
    frA {{} {}} \
    gut {{} {-width 0 -highlightthickness 1}} \
    lab {{-sticky w} {}} \
    laB {{-sticky w} {}} \
    lfr {{} {}} \
    lfR {{} {-relief groove}} \
    lbx {{} {-activestyle none -exportselection 0 -selectmode browse}} \
    flb {{} {}} \
    meb {{} {}} \
    meB {{} {}} \
    nbk {{} {}} \
    opc {{} {}} \
    pan {{} {}} \
    pro {{} {}} \
    rad {{} {}} \
    raD {{} {-padx 6 -pady 2}} \
    sca {{} {-orient horizontal -takefocus 0}} \
    scA {{} {-orient horizontal -takefocus 0}} \
    sbh {{-sticky ew} {-orient horizontal -takefocus 0}} \
    sbH {{-sticky ew} {-orient horizontal -takefocus 0}} \
    sbv {{-sticky ns} {-orient vertical -takefocus 0}} \
    sbV {{-sticky ns} {-orient vertical -takefocus 0}} \
    scf {{} {}} \
    seh {{-sticky ew} {-orient horizontal -takefocus 0}} \
    sev {{-sticky ns} {-orient vertical -takefocus 0}} \
    siz {{} {}} \
    spx {{} {}} \
    spX {{} {}} \
    tbl {{} {-selectborderwidth 1 -highlightthickness 2 \
          -labelcommand tablelist::sortByColumn -stretch all \
          -showseparators 1}} \
    tex {{} {-undo 1 -maxundo 0 -highlightthickness 2 -insertofftime 250 -insertontime 750 -insertwidth $::apave::cursorwidth -wrap word -selborderwidth 1 -exportselection 0}} \
    tre {{} {-selectmode browse}} \
    h_ {{-sticky ew -csz 3 -padx 3} {}} \
    v_ {{-sticky ns -rsz 3 -pady 3} {}}]
  
    
  set TexM {}

# __________________________ AddButtonIcon _________________________ #


  proc AddButtonIcon {w attrsName} {
    # Gets the button's icon based on its text and name (e.g. butOK) and
    # appends it to the attributes of button.
    #   w - button's name
    #   attrsName - name of variable containing attributes of the button

    upvar 1 $attrsName attrs
    set com [getOption -com {*}$attrs]
    if {[string is integer -strict $com]} {
      extractOptions attrs -com {}
      append attrs " -com {::radxide::win::res {} $com}" ;# returned integer result
    }
    if {[getOption -image {*}$attrs] ne {}} return
    set txt [getOption -t {*}$attrs]
    if {$txt eq {}} { set txt [getOption -text {*}$attrs] }
    set im {}
    set icolist [list {exit abort} {exit close} \
      {SaveFile save} {OpenFile open}]
    # ok, yes, cancel, apply buttons should be at the end of list
    # as their texts can be renamed (e.g. "Help" in e_menu's "About")
    lappend icolist {*}[iconImage] {yes apply}
    foreach icon $icolist {
      lassign $icon ic1 ic2
      # text of button is of highest priority at defining its icon
      if {[string match -nocase $ic1 $txt] || \
      [string match -nocase b*t$ic1 $w] || ($ic2 ne {} && ( \
      [string match -nocase b*t$ic2 $w] || [string match -nocase $ic2 $txt]))} {
        if {[string match -nocase btT* $w]} {
          set cmpd none
        } else {
          set cmpd left
        }
        append attrs " [iconA $ic1 small $cmpd]"
        break
      }
    }
    return
  }

# __________________ AddPopupAttr ________________#


  proc AddPopupAttr {w attrsName atRO isRO args} {
    # Adds the attribute to call a popup menu for an editable widget.
    #   w - widget's name
    #   attrsName - variable name for attributes of widget
    #   atRO - "readonly" attribute (internally used)
    #   isRO - flag of readonly widget
    #   args - widget states to be checked

    upvar 1 $attrsName attrs
    lassign $args state state2
    if {$state2 ne {}} {
      if {[getOption -state {*}$attrs] eq $state2} return
      set isRO [expr {$isRO || [getOption -state {*}$attrs] eq $state}]
    }
    if {$isRO} {append atRO RO}
    append attrs " $atRO $w"
    return
  }

# __________________________ AppendButtons _________________________ #


  proc AppendButtons {widlistName buttons neighbor pos defb timeout win modal} {
    # Adds buttons to the widget list from a position of neighbor widget.
    #   widlistName - variable name for widget list
    #   buttons - buttons to add
    #   neighbor - neighbor widget
    #   pos - position of neighbor widget
    #   defb - default button
    #   timeout  - timeout (to count down seconds and invoke a button)
    #   win - dialogue's path
    #   modal - yes if the window is modal
    # Returns list of "Help" button's name and command.

    upvar $widlistName widlist
    namespace upvar ::radxide dan dan
    variable Dlgpath
 
    set Defb1 [set Defb2 [set bhlist {}]]
    foreach {but txt res} $buttons {
      #set com "res $Dlgpath"
      #set com "::radxide::win::res $Dlgpath"
      #if {[info commands $res] eq {}} {
      #  set com "$com $res"
      #} else {
      #  if {$res eq {destroy}} {
      #    # for compatibility with old modal windows
      #    if {$modal} {set res "$com 0"} {set res "destroy $win"}
      #  }
      #  set com $res  ;# "res" is set as a command
      #}
      set com $res
      if {$but eq {butHELP}} {
        # Help button contains the command in "res"
        set com [string map "%w $win" $res]
        set bhlist [list $but $com]
      } elseif {$Defb1 eq {}} {
        set Defb1 $but
      } elseif {$Defb2 eq {}} {
        set Defb2 $but
      }
      if {[set _ [string first "::" $txt]]>-1} {
        set tt " -tip {[string range $txt $_+2 end]}"
        set txt [string range $txt 0 $_-1]
      } else {
        set tt {}
      }
      if {$timeout ne {} && ($defb eq $but || $defb eq {})} {
        set tmo "-timeout {$timeout}"
      } else {
        set tmo {}
      }
      if {$but eq {butHELP}} {
        set neighbor [lindex $widlist end 1]
        set widlist [lreplace $widlist end end]
        lappend widlist [list $but $neighbor T 1 1 {-st w} \
          "-t \"$txt\" -com \"$com\"$tt $tmo -tip F1"]
        set h h_Help
        lappend widlist [list $h $but L 1 94 {-st we}]
        set neighbor $h
      } else {
        lappend widlist [list $but $neighbor $pos 1 1 {-st we} \
          "-t \"$txt\" -com \"$com\"$tt $tmo"]
        set neighbor $but
      }
      set pos L
    }
    lassign [LowercaseWidgetName $Dlgpath.fra.$Defb1] Defb1
    lassign [LowercaseWidgetName $Dlgpath.fra.$Defb2] Defb2
    return $bhlist
  }

# __________________________ appendDialogField _________________________ #  
  
  
  proc addDialogField {fldname oldval newval} {
    
    variable dlg
    
    set newlist [list $fldname $oldval $newval]
    
    set dlg(FIELDS) [linsert $dlg(FIELDS) end $newlist]

  }

# __________________________ basicFontSize _________________________ #


  proc basicFontSize {{fs 0} {ds 0}} {
    # Gets/Sets a basic size of font used in apave
    #    fs - font size
    #    ds - incr/decr of size
    # If 'fs' is omitted or ==0, this method gets it.
    # If 'fs' >0, this method sets it.

    namespace upvar ::radxide dan dan 

    #if {$fs} {
    #  set ::radxide::_CS_(fs) [expr {$fs + $ds}]
    #  my create_Fonts
    #  return $::radxide::_CS_(fs)
    #} else {
    #  return [expr {$::radxide::_CS_(fs) + $ds}]
    #}
    
    return $dan(CHARSIZE)
    
  }

# __________________________ basicDefFont _________________________ #


  proc basicDefFont {{deffont ""}} {
    # Gets/Sets a basic default font.
    #    deffont - font
    # If 'deffont' is omitted or =="", this method gets it.
    # If 'deffont' is set, this method sets it.

    namespace upvar ::radxide dan dan

    #if {$deffont ne ""} {
    #  return [set ::apave::_CS_(defFont) $deffont]
    #} else {
    #  return $::apave::_CS_(defFont)
    #}
    
    return $dan(CHARFAMILY)
  }

# __________________________ basicTextFont _________________________ #


  proc basicTextFont {{textfont ""}} {
    # Gets/Sets a basic font used in editing/viewing text widget.
    #    textfont - font
    # If 'textfont' is omitted or =="", this method gets it.
    # If 'textfont' is set, this method sets it.

    namespace upvar ::radxide dan dan

    #if {$textfont ne ""} {
    #  return [set ::apave::_CS_(textFont) $textfont]
    #} else {
    #  return $::apave::_CS_(textFont)
    #}
    
    return $dan(CHARFAMILY)
  }
  
# __________________________ checkXY _________________________ #

	proc checkXY {win w h x y} {
		# Checks the coordinates of window (against the screen).
		#   w - width of window
		#   h - height of window
		#   x - window's X coordinate
		#   y - window's Y coordinate
		# Returns new coordinates in +X+Y form.

		# check for left/right edge of screen (accounting decors)
		set scrw [expr {[winfo vrootwidth $win] - 12}]
		set scrh [expr {[winfo vrootheight $win] - 36}]
		if {($x + $w) > $scrw } {
		  set x [expr {$scrw - $w}]
		}
		if {($y + $h) > $scrh } {
		  set y [expr {$scrh - $h}]
		}
		if {![string match -* $x]} {set x +[string trimleft $x +]}
		if {![string match -* $y]} {set y +[string trimleft $y +]}
		return ${x}x${y}
	}

# _________________________ centeredXY ________________________ #

	proc centeredXY {win rw rh rx ry w h} {
		# Gets the coordinates of centered window (against its parent).
		#   rw - parent's width
		#   rh - parent's height
		#   rx - parent's X coordinate
		#   ry - parent's Y coordinate
		#   w - width of window to be centered
		#   h - height of window to be centered
		# Returns centered coordinates in +X+Y form.

		set x [expr {max(0, $rx + ($rw - $w) / 2)}]
		set y [expr {max(0,$ry + ($rh - $h) / 2)}]
		return [checkXY $win $w $h $x $y]
	}


# ________________________ centerWin _________________________ #


  proc centerWin {win wwidth wheight} {
  
    namespace upvar ::radxide dan dan
  
		set screen_width [winfo screenwidth $win]
		set screen_height [winfo screenheight $win]
		#tk_messageBox -title $dan(TITLE) -icon error -message $screen_width
		set half_screen_w [expr {0}]
		if {[expr {$screen_width/$screen_height} > 2]} {
		  set half_screen_w [expr {$screen_width/2}]
		  set wrong_geo [centeredXY $win $half_screen_w $screen_height 0 0 $wwidth $wheight]
		} else {  
		  set wrong_geo [centeredXY $win $screen_width $screen_height 0 0 $wwidth $wheight]
		}  
		#set geo [string map {x ""} $geo]
		#wm geometry $dan(WIN) "=$dan(WIDTH)x$dan(HEIGHT)$geo"
		wm geometry $win =${wwidth}x${wheight}
		# Lets do it modal:
		set offsetx [winfo x $win]
		set offsety [winfo y $win]		
		set disinfox [winfo pointerx [winfo parent $win]]
		#tk_messageBox -title $dan(TITLE) -icon error -message $disinfox
		#tk_messageBox -title $dan(TITLE) -icon error -message $half_screen_w
		set display [expr {1}]
		if { $disinfox>$half_screen_w } { 
		  set display [expr {2}]
		} 
		#tk_messageBox -title $dan(TITLE) -icon error -message $display
		set newx [expr {($half_screen_w-$wwidth)/2}]
		if {$display>1} {
  		set newx [expr {$half_screen_w+(($half_screen_w-$wwidth)/2)}]
  	}	
  	#tk_messageBox -title $dan(TITLE) -icon error -message newx=$newx
		set newy [expr {70}]
		wm geometry $win +$newx+$newy
  }


#_______________________ CheckData _______________________ #

#	proc CheckData {op} {
#		# Checks if the find/replace data are valid.
#		#   op - if "repl", checks for "Replace" operation
#		# Return "yes", if the input data are valid.
#
#    namespace upvar :radxide dan dan
#
#		variable data
#		
#		# this means "no checks when used outside of the dialogue":
#		if {!$data(docheck)} {return yes}
#
#		set ret yes
#    if {[set data(en1)] eq {}} { set ret no }
#    if {[set data(en1)] > $dan(MAXFINDLENGTH)} { set ret no }
#    
#		if {$ret eq no} {
#		  # if find/replace field is empty, let the bell tolls for him
#		  bell
#		  return no
#		}
#		return yes
#	}

# ________________________ CleanUps _________________________ #


  proc CleanUps {{wr ""}} {

  }


  proc danInitDialogs {} {

    namespace upvar ::radxide dan dan

    variable Dlgpath
    variable Dlgname  
    variable dlg
    variable Indexdlg
 
    set Dlgpath ""
    set Dlgname ""  
    set dlg(PATH) ""
    set dlg(NAME) ""
    set dlg(FIELDS) {}
    set Indexdlg 0
  
  }

# ________________________ defaultATTRS _________________________ #

  proc defaultATTRS {{type ""} {opts ""} {atrs ""} {widget ""}} {
    # Sets, gets or registers default options and attributes for widget type.
    #   type - widget type
    #   opts - new default grid/pack options
    #   atrs - new default attributes
    #   widget - Tcl/Tk command for the new registered widget type
    # The *type* should be a three letter unique string.
    # If the *type* is absent in the registered types and *opts* and/or *atrs*
    # is not set to "", defaultATTRS registers the new *type* with its grid/pack
    # options and attributes. At that *widget* is a command for the new widget
    # type. For example, to register "toolbutton" widget:
    #   my defaultATTRS tbt {} {-style Toolbutton -compound top} ttk::button
    # Options and attributes may contain data (variables and commands)
    # to be processed by [subst].
    # Returns:
    #   - if not set *type*: a full list of options and attributes of all types
    #   - if set *type* only: a list of options, attributes and *widget*
    #   - else: a list of updated options, attributes and *widget*

    variable _Defaults

    if {$type eq {}} {return $_Defaults}
    set optatr "$opts$atrs"
    if {[catch {set def1 [dict get $_Defaults $type]}]} {
      if {$optatr eq {}} {
        set err "[self method]: \"$type\" widget type not registered."
        puts -nonewline stderr $err
        return -code error $err
      }
      set def1 [list $opts $atrs $widget]
    }
    if {$optatr eq {}} {return [subst $def1]}
    lassign $def1 defopts defatrs widget
    if {[catch {set defopts [dict replace $defopts {*}$opts]}]} {
      set defopts [string trim "$defopts $opts"]
    }
    if {[catch {set defatrs [dict replace $defatrs {*}$atrs]}]} {
      set defatrs [string trim "$defatrs $atrs"]
    }
    set newval [list $defopts $defatrs $widget]
    dict set _Defaults $type $newval
    return $newval
  }

# ________________________ defaultAttrs _________________________ #


  proc defaultAttrs {{type ""} {opts ""} {atrs ""} {widget ""}} {
    # Sets, gets or registers default options and attributes for widget type.
    #   type - widget type
    #   opts - new default grid/pack options
    #   atrs - new default attributes
    #   widget - Tcl/Tk command for the new registered widget type
    # See also: APaveBase::defaultATTRS

    return [defaultATTRS $type $opts $atrs $widget]
  }

# ________________________ dlgPath _________________________ #


  proc dlgPath {}  {
    # Gets a current dialogue's path.
    # In fact, it does the same as [my dlgPath], but it can be
    # called outside of apave dialogue object (useful sometimes).
    
    namespace upvar ::radxide dan dan
    
    #variable Dlgpath
    # xxx
    variable Dlgname
    
    variable Indexdlg
    
    set Winpath $dan(WIN)
    
    # xxx
    #set wdia $Winpath.dia    
    set wdia $Winpath.dia$Dlgname$Indexdlg
    return [set dlg(PATH) [set Dlgpath $wdia]]
  }

# ________________________ DiaWidgetNameter _________________________ #


  proc DiaWidgetName {w} {
    # Gets a widget name of apave dialogue.
    #   w - name of widget
    # The name of widget may be partial. In this case it's prepended
    # the current dialogue's frame path.
    # Useful in "input" dialogue when -method option is present
    # or widget names are uppercased.
    # See also: MakeWidgetName, input

    if {[string index $w 0] eq {.}} {return $w}
    return $Dlgpath.fra.$w
  }

# ________________________ displayTaggedText _________________________ #

  proc displayTaggedText {w contsName {tags ""}} {
    # Sets the text widget's contents using tags (ornamental details).
    #   w - text widget's name
    #   contsName - variable name for contents to be set in the widget
    #   tags - list of tags to be applied to the text
    # The lines in *text contents* are divided by \n and can include
    # *tags* like in a html layout, e.g. <red>RED ARMY</red>.
    # The *tags* is a list of "name/value" pairs. 1st is a tag's name, 2nd
    # is a tag's value.
    # The tag's name is "pure" one (without <>) so e.g.for <b>..</b> the tag
    # list contains "b".
    # The tag's value is a string of text attributes (-font etc.).
    # If the tag's name is FG, FG2, BG or BG2, then it is really a link color.

  }

# ________________________ displayText _________________________ #


  proc displayText {w conts {pos 1.0}} {
    # Sets the text widget's contents.
    #   w - text widget's name
    #   conts - contents to be set in the widget

    if {[set state [$w cget -state]] ne {normal}} {
      $w configure -state normal
    }
    $w replace 1.0 end $conts
    $w edit reset; $w edit modified no
    if {$state eq {normal}} {
      ::tk::TextSetCursor $w $pos
    } else {
      $w configure -state $state
    }
    return
  }

# __________________________ editDialogField _________________________ #  
  
  
  proc editDialogField {index fldname oldval newval} {
    
    namespace upvar ::radxide dan dan
    
    variable dlg
    
    set newlist {$fldname $oldval $newval}
    
    lset dlg(FIELDS) $index $newlist
    
  }

# ________________________ ExpandOptions _________________________ #


  proc ExpandOptions {options} {
    # Expands shortened options.

    set options [string map {
      { -st } { -sticky }
      { -com } { -command }
      { -t } { -text }
      { -w } { -width }
      { -h } { -height }
      { -var } { -variable }
      { -tvar } { -textvariable }
      { -lvar } { -listvariable }
      { -ro } { -readonly }
    } " $options"]
    return $options
  }

# ________________________ error _________________________ #


	proc error {{fileName ""}} {
		# Gets the error's message at reading/writing.
		#   fileName - if set, return a full error messageat opening file

		variable _PU_opts
		if {$fileName eq ""} {
		  return $_PU_opts(_ERROR_)
		}
		return "Error of access to\n\"$fileName\"\n\n$_PU_opts(_ERROR_)"
	}

# ________________________ extractOption _________________________ #


	proc extractOptions {optsVar args} {
		# Gets options' values and removes the options from the input list.
		#  optsVar - variable name for the list of options and values
		#  args  - list of "option / default value" pairs
		# Returns a list of options' values, according to args.
		# See also: parseOptions

		upvar 1 $optsVar opts
		set retlist [parseOptions $opts {*}$args]
		foreach {o v} $args {
		  set opts [removeOptions $opts $o]
		}
		return $retlist
	}

# ________________________ FCfieldAttrs _________________________ #


  proc FCfieldAttrs {wnamefull attrs varopt} {
    # Fills the non-standard attributes of file content widget.
    #   wnamefull - a widget name
    #   attrs - a list of all attributes
    #   varopt - a variable option
    # The *varopt* refers to a variable part such as tvar, lvar:
    #  * -inpval option means an initial value of the field
    #  * -retpos option has p1:p2 format (e.g. 0:10) to cut a substring from a returned value
    # Returns *attrs* without -inpval and -retpos options.

    # xxx
    variable Widgetopts

    lassign [parseOptions $attrs $varopt {} -retpos {} -inpval {}] \
      vn rp iv
    if {[string first {-state disabled} $attrs]<0 && $vn ne {}} {
      set all {}
      if {$varopt eq {-lvar}} {
        lassign [extractOptions attrs -values {} -ALL 0] iv a
        if {[string is boolean -strict $a] && $a} {set all ALL}
        lappend Widgetopts "-lbxname$all $wnamefull $vn"
      }
      if {$rp ne {}} {
        if {$all ne {}} {set rp 0:end}
        lappend Widgetopts "-retpos $wnamefull $vn $rp"
      }
    }
    if {$iv ne {}} { set $vn $iv }
    return [removeOptions $attrs -retpos -inpval]
  }

# ________________________ FCfieldValues _________________________ #


  proc FCfieldValues {wnamefull attrs} {
    # Fills the file content widget's values.
    #   wnamefull - name (path) of fco widget
    #   attrs - attributes of the widget

  ; proc readFCO {fname} {
      # Reads a file's content.
      # Returns a list of (non-empty) lines of the file.
      if {$fname eq {}} {
        set retval {{}}
      } else {
        set retval {}
        foreach ln [split [readTextFile $fname {} 1] \n] {
          # probably, it's bad idea to have braces in the file of contents
          set ln [string map [list \\ \\\\ \{ \\\{ \} \\\}] $ln]
          if {$ln ne {}} {lappend retval $ln}
        }
      }
      return $retval
    }

  ; proc contFCO {fline opts edge args} {
      # Given a file's line and options,
      # cuts a substring from the line.
      
      # xxx
      variable Widgetopts
      
      lassign [parseOptionsFile 1 $opts {*}$args] opts
      lassign $opts - - - div1 - div2 - pos - len - RE - ret
      set ldv1 [string length $div1]
      set ldv2 [string length $div2]
      set i1 [expr {[string first $div1 $fline]+$ldv1}]
      set i2 [expr {[string first $div2 $fline]-1}]
      set filterfile yes
      if {$ldv1 && $ldv2} {
        if {$i1<0 || $i2<0} {return $edge}
        set retval [string range $fline $i1 $i2]
      } elseif {$ldv1} {
        if {$i1<0} {return $edge}
        set retval [string range $fline $i1 end]
      } elseif {$ldv2} {
        if {$i2<0} {return $edge}
        set retval [string range $fline 0 $i2]
      } elseif {$pos ne {} && $len ne {}} {
        set retval [string range $fline $pos $pos+[incr len -1]]
      } elseif {$pos ne {}} {
        set retval [string range $fline $pos end]
      } elseif {$len ne {}} {
        set retval [string range $fline 0 $len-1]
      } elseif {$RE ne {}} {
        set retval [regexp -inline $RE $fline]
        if {[llength $retval]>1} {
          foreach r [lrange $retval 1 end] {append retval_tmp $r}
          set retval $retval_tmp
        } else {
          set retval [lindex $retval 0]
        }
      } else {
        set retval $fline
        set filterfile no
      }
      if {$retval eq {} && $filterfile} {return $edge}
      set retval [string map [list "\}" "\\\}"  "\{" "\\\{"] $retval]
      return [list $retval $ret]
    }

    set edge $Edge
    set ldv1 [string length $edge]
    set filecontents {}
    set optionlists {}
    set tplvalues {}
    set retpos {}
    set values [getOption -values {*}$attrs]
    if {[string first $edge $values]<0} { ;# if 1 file, edge
      set values "$edge$values$edge"      ;# may be omitted
    }
    # get: files' contents, files' options, template line
    set lopts {-list {} -div1 {} -div2 {} -pos {} -len {} -RE {} -ret 0}
    while {1} {
      set i1 [string first $edge $values]
      set i2 [string first $edge $values $i1+1]
      if {$i1>=0 && $i2>=0} {
        incr i1 $ldv1
        append tplvalues [string range $values 0 $i1-1]
        set fdata [string range $values $i1 $i2-1]
        lassign [parseOptionsFile 1 $fdata {*}$lopts] fopts fname
        lappend filecontents [readFCO $fname]
        lappend optionlists $fopts
        set values [string range $values $i2+$ldv1 end]
      } else {
        append tplvalues $values
        break
      }
    }
    # fill the combobox lines, using files' contents and options
    if {[set leno [llength $optionlists]]} {
      set newvalues {}
      set ilin 0
      lassign $filecontents firstFCO
      foreach fline $firstFCO { ;# lines of first file for a base
        set line {}
        set tplline $tplvalues
        for {set io 0} {$io<$leno} {incr io} {
          set opts [lindex $optionlists $io]
          if {$ilin==0} {  ;# 1st cycle: add items from -list option
            lassign $opts - list1  ;# -list option goes first
            if {[llength $list1]} {
              foreach l1 $list1 {append newvalues "\{$l1\} "}
              lappend Widgetopts "-list $wnamefull [list $list1]"
            }
          }
          set i1 [string first $edge $tplline]
          if {$i1>=0} {
            lassign [contFCO $fline $opts $edge {*}$lopts] retline ret
            if {$ret ne "0" && $retline ne $edge && \
            [string first $edge $line]<0} {
              set p1 [expr {[string length $line]+$i1}]
              if {$io<($leno-1)} {
                set p2 [expr {$p1+[string length $retline]-1}]
              } else {
                set p2 end
              }
              set retpos "-retpos $p1:$p2"
            }
            append line [string range $tplline 0 $i1-1] $retline
            set tplline [string range $tplline $i1+$ldv1 end]
          } else {
            break
          }
          set fline [lindex [lindex $filecontents $io+1] $ilin]
        }
        if {[string first $edge $line]<0} {
          # put only valid lines into the list of values
          append newvalues "\{$line$tplline\} "
        }
        incr ilin
      }
      # replace old 'values' attribute with the new 'values'
      lassign [parseOptionsFile 2 $attrs -values \
        [string trimright $newvalues]] attrs
    }
    return "$attrs $retpos"
  }

# ________________________ fillGutter _________________________ #


  proc fillGutter {txt {canvas ""} {width ""} {shift ""} fg bg} {
    # Fills a gutter of text with the text's line numbers.
    #  txt - path to the text widget
    #  canvas - canvas of the gutter
    #  width - width of the gutter, in chars
    #  shift - addition to the width (to shift from the left side)
    #  args - additional arguments for tracing
    # The code is borrowed from open source tedit project.
    
    namespace upvar ::radxide dan dan
    
    $canvas configure -state normal
    
    if {$canvas eq {}} {
      event generate $txt <Configure> ;# repaints the gutter
      return
    }

    set i 1
    set gcont [list]
    set totlines [expr [$txt count -lines 0.0 end]]
    while true {
      if {$i > $totlines} break
      #set dline [$txt dlineinfo $i] ;# xxx
      set dline [$txt get [lindex [split $i .] 0].0 [lindex [split $i .] 0].end]         
      #if {[llength $dline] == 0} break
      #set height [lindex $dline 3] ;# xxx
      #set y [expr {[lindex $dline 1]}] ;# xxx
      set linenum [format "%${width}d" [lindex [split $i .] 0]]
      #set i [$txt index "$i +1 lines linestart"] # xxx
      #lappend gcont [list $y $linenum\n]
      lappend gcont [list [lindex [split $i .] 0] [expr {$linenum}]\n]
      incr i
    }

    set newwidth $dan(GUTTERWIDTH); 

    $canvas delete 1.0 end
    set y [expr {0}]
    foreach g $gcont {
      lassign $g y linenum
      $canvas insert [expr {$y}].0 $linenum
    }

    $canvas configure -state disabled
  }


# ________________________ FieldName _________________________ #


  proc FieldName {name} {
    # Gets a field name.

    return fraM.fra$name.$name
  }

# ________________________ findInText ___________________________ #


  proc findInText {{donext 0} {txt ""} {varFind ""} {dobell yes}} {
    # Finds a string in text widget.
    #   donext - "1" means 'from a current position'
    #   txt - path to the text widget
    #   varFind - variable
    #   dobell - if yes, bells
    # Returns yes, if found (or nothing to find), otherwise returns "no";
    # also, if there was a real search, the search string is added.

    namespace upvar ::radxide dan dan

    variable Foundstr

    if {$txt eq {}} {
      set txt $dan(TEXT)
      set sel $Foundstr
    } elseif {$donext && [set sel [get_HighlightedString]] ne {}} {
      # find a string got with alt+left/right
    } elseif {$varFind eq {}} {
      set sel $Foundstr
    } else {
      set sel [set $varFind]
    }
    if {$donext} {
      set pos [$txt index insert]
      if {{sel} in [$txt tag names $pos]} {
        set pos [$txt index "$pos + 1 chars"]
      }
      set pos [$txt search -- $sel $pos end]
    } else {
      set pos {}
      set_HighlightedString {}
    }
    if {![string length "$pos"]} {
      set pos [$txt search -- $sel 1.0 end]
    }
    if {[string length "$pos"]} {
      ::tk::TextSetCursor $txt $pos
      $txt tag add sel $pos [$txt index "$pos + [string length $sel] chars"]
      #focus $txt
      set res yes
    } else {
      if {$dobell} bell
      set res no
    }
    return [list $res $sel]
  }

# ________________________ findTextOK _________________________ #


  proc findTextOK {} {
  
    namespace upvar ::radxide dan dan

    variable dlg
    variable data
    variable Foundstr
    
    set wt $dan(TEXT) 
    
    #if {$inv>-1} {set data(lastinvoke) $inv}    
    
    #set t $Dlgpath.fra.fraM.fraent.ent
    set t [dlgPath].fra.[FieldName [lindex [getDialogField 0] 0]]
    #tk_messageBox -title $dan(TITLE) -icon info -message textbox=$t
    set varname [lindex [getDialogField end] 0]
    #tk_messageBox -title $dan(TITLE) -icon info -message varname=$varname
    set oldsearchtext [lindex [getDialogField end] 1]
    #tk_messageBox -title $dan(TITLE) -icon info -message oldsearchtext=$oldsearchtext
    set newsearchtext [string trim [$t get]]
    #tk_messageBox -title $dan(TITLE) -icon info -message newsearchtext=$newsearchtext
  
    set Foundstr $newsearchtext
   
    findInText 1 $wt
  
    #ShowResults1 [FindAll $wt]
  
    return 1
  }


# ________________________ findTextCancel _________________________ #


  proc findTextCancel {} {
  
    #catch {[destroy .danwin.diaRenameFile1]}    
    catch {[destroy [dlgPath]]}
        
    return 0
  }

# ________________________ GetAttrs _________________________ #


  proc GetAttrs {options {nam3 ""} {disabled 0} } {
    # Expands attributes' values.
    #   options - list of attributes and values
    #   nam3 - first three letters (type) of widget's name
    #   disabled - flag of "disabled" state
    # Returns expanded attributes.

    set opts [list]
    foreach {opt val} [list {*}$options] {
      switch -exact -- $opt {
        -t - -text {
          ;# these options need translating \\n to \n
          # catch {set val [subst -nocommands -novariables $val]}
          set val [string map [list \\n \n \\t \t] $val]
          set opt -text
        }
        -st {set opt -sticky}
        -com {set opt -command}
        -w {set opt -width}
        -h {set opt -height}
        -var {set opt -variable}
        -tvar {set opt -textvariable}
        -lvar {set opt -listvariable}
        -ro {set opt -readonly}
      }
      lappend opts $opt \{$val\}
    }
    if {$disabled} {
      append opts [NonTtkStyle $nam3 1]
    }
    return $opts
  }

# ________________________ get_HighlightedString _________________________ #


  proc get_HighlightedString {} {
    # Returns a string got from highlighting by Alt+left/right/q/w.

    variable HLstring

    if {[info exists HLstring]} {
      return $HLstring
    }
    return {}
  }

# ________________________ GetIntOptions _________________________ #


  proc GetIntOptions {w options row rowspan col colspan} {
    # Gets specific integer options. Then expands other options.
    #   w - widget's name
    #   options - grid options
    #   row, rowspan - row and its span of thw widget
    #   col, colspan - column and its span of thw widget
    # The options are set in grid options as "-rw <int>", "-cw <int>" etc.
    # Returns the resulting grid options.

    set opts {}
    foreach {opt val} [list {*}$options] {
      switch -exact -- $opt {
        -rw  {SpanConfig $w row $row $rowspan -weight $val}
        -cw  {SpanConfig $w column $col $colspan -weight $val}
        -rsz {SpanConfig $w row $row $rowspan -minsize $val}
        -csz {SpanConfig $w column $col $colspan -minsize $val}
        -ro  {SpanConfig $w column $col $colspan -readonly $val}
        default {append opts " $opt $val"}
      }
    }
    # Get other grid options
    return [ExpandOptions $opts]
  }

# ________________________ GetLinkLab _________________________ #


  proc GetLinkLab {m} {
    # Gets a link for label.
    #   m - label with possible link (between <link> and </link>)
    # Returns: list of "pure" message and link for label.

    if {[set i1 [string first "<link>" $m]]<0} {
      return [list $m]
    }
    set i2 [string first "</link>" $m]
    set link [string range $m $i1+6 $i2-1]
    set m [string range $m 0 $i1-1][string range $m $i2+7 end]
    return [list $m [list -link $link]]
  }

# ________________________ getOption _________________________ #


	proc getOption {optname args} {
		# Extracts one option from an option list.
		#   optname - option name
		#   args - option list
		# Returns an option value or "".
		# Example:
		#     set options [list -name some -value "any value" -tip "some tip"]
		#     set optvalue [::apave::getOption -tip {*}$options]

		set optvalue [lindex [parseOptions $args $optname ""] 0]
		return $optvalue
	}

# ________________________ GetOutputValues _________________________ #


  proc GetOutputValues {} {
    # Makes output values for some widgets (lbx, fco).
    # Some i/o widgets need a special method to get their returned values.

    # xxx
    variable Widgetopts

    foreach aop $Widgetopts {
      lassign $aop optnam vn v1 v2
      switch -glob -- $optnam {
        -lbxname* {
          # To get a listbox's value, its methods are used.
          # The widget may not exist when an apave object is used for
          # several dialogs which is a bad style (very very bad).
          if {[winfo exists $vn]} {
            lassign [$vn curselection] s1
            if {$s1 eq {}} {set s1 0}
            set w [string range $vn [string last . $vn]+1 end]
            if {[catch {set v0 [$vn get $s1]}]} {set v0 {}}
            if {$optnam eq {-lbxnameALL}} {
              # when -ALL option is set to 1, listbox returns
              # a list of 3 items - sel index, sel contents and all contents
              set $v1 [list $s1 $v0 [set $v1]]
            } else {
              set $v1 $v0
            }
          }
        }
        -retpos { ;# a range to cut from -tvar/-lvar variable
          lassign [split $v2 :] p1 p2
          set val1 [set $v1]
          # there may be -list option for this widget
          # then if the value is from the list, it's fully returned
          foreach aop2 $Widgetopts {
            lassign $aop2 optnam2 vn2 lst2
            if {$optnam2 eq {-list} && $vn eq $vn2} {
              foreach val2 $lst2 {
                if {$val1 eq $val2} {
                  set p1 0
                  set p2 end
                  break
                }
              }
              break
            }
          }
          set $v1 [string range $val1 $p1 $p2]
        }
      }
    }
    return
  }

# __________________________ getDialogField _________________________ #  
  
  
  proc getDialogField {index} {

    variable dlg

    set ret [lindex $dlg(FIELDS) $index] 

    return $ret
    
  }

#_______________________ getProperty _______________________#


	proc getProperty {name {defvalue ""}} {
		# Gets a property's value as "application-wide".
		#   name - name of property
		#   defvalue - default value
		# If the property had been set, the method returns its value.
		# Otherwise, the method returns the default value (`$defvalue`).

		variable _AP_Properties
		if {[info exists _AP_Properties($name)]} {
		  return $_AP_Properties($name)
		}
		return $defvalue
	}

# ________________________ getShowOption _________________________ #


  proc getShowOption {name {defval ""}} {
    # Gets a default show option, used in showModal.
    #   name - name of option
    #   defval - default value
    # See also: showModal

    getProperty [ShowOption $name] $defval
  }

# ________________________ GetVarsValues _________________________ #


  proc GetVarsValues {lwidgets} {
    # Gets values of entries passed (or set) in -tvar.
    #   lwidgets - list of widget items

    set res [set vars [list]]
    foreach wl $lwidgets {
      set ownname [ownWName [lindex $wl 0]]
      set vv [varName $ownname]
      set attrs [lindex $wl 6]
      if {[string match "ra*" $ownname]} {
        # only for widgets with a common variable (e.g. radiobuttons):
        foreach t {-var -tvar} {
          if {[set v [getOption $t {*}$attrs]] ne {}} {
            array set a $attrs
            set vv $v
          }
        }
      }
      if {[info exist $vv] && [lsearch $vars $vv]==-1} {
        lappend res [set $vv]
        lappend vars $vv
      }
    }
    return $res
  }

# ________________________ GotoLineOK _________________________ #


  proc GotoLineOK {} {
  
    namespace upvar ::radxide dan dan

    variable dlg
    
    set wt $dan(TEXT) 
    set lmax [expr {int([$wt index "end -1c"])}]
    
    #set t $Dlgpath.fra.fraM.fraent.ent
    set t [dlgPath].fra.[FieldName [lindex [getDialogField 0] 0]]
    #tk_messageBox -title $dan(TITLE) -icon info -message textbox=$t
    set varname [lindex [getDialogField end] 0]
    #tk_messageBox -title $dan(TITLE) -icon info -message varname=$varname
    set oldlinenumber [lindex [getDialogField end] 1]
    #tk_messageBox -title $dan(TITLE) -icon info -message oldlinenumber=$oldlinenumber
    set newlinenumber [string trim [$t get]]
    #tk_messageBox -title $dan(TITLE) -icon info -message newlinenumber=$newlinenumber

    if {$newlinenumber>$lmax} {
      tk_messageBox -title $dan(TITLE) -icon info -message "Line $newlinenumber doesn't exist $newlinenumber>MAXLINES."
      return 0
    }

    ::tk::TextSetCursor $wt 0.0
    after 200 "tk::TextSetCursor $wt [expr $newlinenumber].0"
          
    catch {[destroy [dlgPath]]}
  
    return 1
  }


# ________________________ GotoLineCancel _________________________ #


  proc GotoLineCancel {} {
  
    #catch {[destroy .danwin.diaRenameFile1]}    
    catch {[destroy [dlgPath]]}
        
    return 0
  }



# ________________________ iconImage _________________________ #

  proc iconA {icon {iconset small} {cmpd left}} {
    # Gets icon attributes for buttons, menus etc.
    #   icon - name of icon
    #   iconset - one of small/middle/large
    #   cmpd - value of -compound option
    # The *iconset* is "small" for menus (recommended and default).

    return "-image [iconImage $icon $iconset] -compound $cmpd"
  }

# ________________________ iconifyOption _________________________ #


	proc iconifyOption {args} {
		# Gets/sets "-iconify" option.
		#   args - if contains no arguments, gets "-iconify" option; otherwise sets it
		# Option values mean:
		#   none - do nothing: no withdraw/deiconify
		#   Linux - do withdraw/deiconify for Linux
		#   Windows - do withdraw/deiconify for Windows
		#   default - do withdraw/deiconify depending on the platform
		# See also: withdraw, deiconify

		if {[llength $args]} {
		  set iconify [setShowOption -iconify $args]
		} else {
		  set iconify [getShowOption -iconify]
		}
		return $iconify
	}

# ________________________ iconImage _________________________ #


  proc iconImage {{icon ""} {iconset "small"} {doit no}} {
    # Gets a defined icon's image or list of icons.
    # If *icon* equals to "-init", initializes apave's icon set.
    #   icon - icon's name
    #   iconset - one of small/middle/large
    #   doit - force the initialization
    # Returns the icon's image or, if *icon* is blank, a list of icons
    # available in *apave*.

    variable _AP_IMG
    variable _AP_ICO
    
    return folder
#    if {$icon eq {}} {return $_AP_ICO}
#  ; proc imagename {icon} {   # Get a defined icon's image name
#      return _AP_IMG(img$icon)
#    }
#    variable apaveDir
#    if {![array size _AP_IMG] || $doit} {
#      # Make images of icons
#      source [file join $apaveDir apaveimg.tcl]
#      if {$iconset ne "small"} {
#       foreach ic $_AP_ICO {  ;# small icons best fit for menus
#          set _AP_IMG($ic-small) [set _AP_IMG($ic)]
#        }
#        if {$iconset eq "middle"} {
#          source [file join $apaveDir apaveimg2.tcl]
#        } else {
#          source [file join $apaveDir apaveimg2.tcl] ;# TODO
#        }
#      }
#      foreach ic $_AP_ICO {
#        if {[catch {image create photo [imagename $ic] -data [set _AP_IMG($ic)]}]} {
#          # some png issues on old Tk
#          image create photo [imagename $ic] -data [set _AP_IMG(none)]
#        } elseif {$iconset ne "small"} {
#          image create photo [imagename $ic-small] -data [set _AP_IMG($ic-small)]
#        }
#      }
#    }
#    if {$icon eq "-init"} {return $_AP_ICO} ;# just to get to icons
#    if {$icon ni $_AP_ICO} {set icon [lindex $_AP_ICO 0]}
#    if {$iconset eq "small" && "_AP_IMG(img$icon-small)" in [image names]} {
#      set icon $icon-small
#    }
#    return [imagename $icon]
  }

# ________________________ InfoFind _________________________ #


	proc InfoFind {w modal} {
		# Searches data of a window in a list of registered windows.
		#   w - root window's path
		#   modal - yes, if the window is modal
		# Returns: the window's path or "" if not found.
		# See also: InfoWindow

		variable _PU_opts
		foreach winfo [lrange $_PU_opts(_MODALWIN_) 1 end] {  ;# skip 1st window
		  incr i
		  lassign $winfo w1 var1 modal1
		  if {[winfo exists $w1]} {
		    if {$w eq $w1 && ($modal && $modal1 || !$modal && !$modal1)} {
		      return $w1
		    }
		  } else {
		    catch {set _PU_opts(_MODALWIN_) [lreplace $_PU_opts(_MODALWIN_) $i $i]}
		  }
		}
		return {}
	}

# ________________________ InitFindInText _________________________ #


  proc InitFindInText { {ctrlf 0} {txt {}} } {
    # Initializes the search in the text.
    #   ctrlf - "1" means that the method is called by Ctrl+F
    #   txt - path to the text widget

    namespace upvar ::radxide dan dan

    variable Foundstr

    if {$txt eq {}} {set txt $dan(TEXT)}
    #if {$ctrlf} {  ;# Ctrl+F moves cursor 1 char ahead
    #  ::tk::TextSetCursor $txt [$txt index "insert -1 char"]
    #}
    if {[set seltxt [selectedWordText $txt]] ne {}} {
      set Foundstr $seltxt
    }
    return $Foundstr
  }

# ________________________ initInput _________________________ #


  proc initInput {} {
    # Initializes input and clears variables made in previous session.

    variable _savedvv
    # xxx   
    variable Widgetopts

    foreach {vn vv} $_savedvv {
      catch {unset $vn}
    }
    set _savedvv [list]
    set Widgetopts [list]

    return
  }

	proc InfoWindow {{val ""} {w .} {modal no} {var ""} {regist no}} {
		# Registers/unregisters windows. Also sets/gets 'count of open modal windows'.
		#   val - current number of open modal windows
		#   w - root window's path
		#   modal - yes, if the window is modal
		#   var - variable's name for tkwait
		#   regist - yes or no for registering/unregistering

		variable _PU_opts
		if {$modal || $regist} {
		  set info [list $w $var $modal]
		  set i [lsearch -exact $_PU_opts(_MODALWIN_) $info]
		  catch {set _PU_opts(_MODALWIN_) [lreplace $_PU_opts(_MODALWIN_) $i $i]}
		  if {$regist} {
		    lappend _PU_opts(_MODALWIN_) $info
		  }
		  set res [IntStatus . MODALS $val]
		} else {
		  set res [IntStatus . MODALS]
		}
		return $res
	}

# ________________________ input _________________________ #


  proc input {dlgname icon ttl iopts args} {
    # Makes and runs an input dialog.
    #  dlgname - dialog name
    #  icon - icon (omitted if equals to "")
    #  ttl - title of window
    #  iopts - list of widgets and their attributes
    #  args - list of dialog's attributes
    # The `iopts` contains lists of three items:
    #   name - name of widgets
    #   prompt - prompt for entering data
    #   valopts - value options
    # The `valopts` is a list specific for a widget's type, however
    # a first item of `valopts` is always an initial input value.

    namespace upvar ::radxide dan dan

    variable Indexdlg
    variable _savedvv 
    variable Dlgpath
    variable Dlgname
    variable dlg

    #tk_messageBox -title $dan(TITLE) -icon error -message "proc Input"

    danInitDialogs

    set Winpath $dan(WIN)
    set Dlgname [set dlg(NAME) $dlgname]
    set wdia $Winpath.dia$Dlgname[incr Indexdlg]
    set dlg(PATH) [set Dlgpath $wdia]
    if {$iopts ne {}} {
      initInput  ;# clear away all internal vars
    }
    set pady "-pady 2"
    if {[set focusopt [getOption -focus {*}$args]] ne {}} {
     set focusopt "-focus $focusopt"
    }
    lappend inopts [list fraM + T 1 98 "-st nsew $pady -rw 1"]
    set _savedvv [list]
    set frameprev {}
    foreach {name prompt valopts} $iopts {
      if {$name eq {}} continue
      lassign $prompt prompt gopts attrs
      lassign [extractOptions attrs -method {} -toprev {}] ismeth toprev
      if {[string toupper $name 0] eq $name} {
        set ismeth yes  ;# overcomes the above setting
        set name [string tolower $name 0]
      }
      set ismeth [string is true -strict $ismeth]
      set gopts "$pady $gopts"
      set typ [string tolower [string range $name 0 1]]
      if {$typ eq "v_" || $typ eq "se"} {
        lappend inopts [list fraM.$name - - - - "pack -fill x $gopts"]
        continue
      }
      set tvar "-tvar"
      switch -exact -- $typ {
        ch { set tvar "-var" }
        sp { set gopts "$gopts -expand 0 -side left"}
      }
      set framename fraM.fra$name
      if {$typ in {lb te tb}} {  ;# the widgets sized vertically
        lappend inopts [list $framename - - - - "pack -expand 1 -fill both"]
      } else {
        lappend inopts [list $framename - - - - "pack -fill x"]
      }
      set vv [::radxide::win::varName $name]
      #tk_messageBox -title $dan(TITLE) -icon info -message vv=$vv
      set ff [FieldName $name]
      set Name [string toupper $name 0]
      if {$ismeth && $typ ni {ra}} {
        # -method option forces making "WidgetName" method from "widgetName"
        MakeWidgetName $ff $Name -
      }
      if {$typ ne {la} && $toprev eq {}} {
        set takfoc [parseOptions $attrs -takefocus 1]
        if {$focusopt eq {} && $takfoc} {
          if {$typ in {fi di cl fo da}} {
            set _ en*$name  ;# 'entry-like mega-widgets'
          } elseif {$typ eq "ft"} {
            set _ te*$name  ;# ftx - 'text-like mega-widget'
          } else {
            set _ $name
          }
          set focusopt "-focus $_"
        }
        if {$typ in {lb tb te}} {set anc nw} {set anc w}
        lappend inopts [list fraM.fra$name.labB$name - - - - \
          "pack -side left -anchor $anc -padx 3" \
          "-t \"$prompt\" -font \
          \"-family {[basicTextFont]} -size [basicFontSize]\""]
      }
      # for most widgets:
      #   1st item of 'valopts' list is the current value
      #   2nd and the rest of 'valopts' are a list of values
      if {$typ ni {fc te la}} {
        # curr.value can be set with a variable, so 'subst' is applied
        set vsel [lindex $valopts 0]
        catch {set vsel [subst -nocommands -nobackslashes $vsel]}
        set vlist [lrange $valopts 1 end]
      }
      if {[set msgLab [getOption -msgLab {*}$attrs]] ne {}} {
        set attrs [removeOptions $attrs -msgLab]
      }
      # define a current widget's info
      switch -exact -- $typ {
        lb - tb {
          set $vv $vlist
          lappend attrs -lvar $vv
          if {$vsel ni {{} -}} {
            lappend attrs -lbxsel "$UFF$vsel$UFF"
          }
          lappend inopts [list $ff - - - - \
            "pack -side left -expand 1 -fill both $gopts" $attrs]
          lappend inopts [list fraM.fra$name.sbv$name $ff L - - "pack -fill y"]
        }
        cb {
          if {![info exist $vv]} {catch {set $vv $vsel}}
          lappend attrs -tvar $vv -values $vlist
          if {$vsel ni {{} -}} {
            lappend attrs -cbxsel $UFF$vsel$UFF
          }
          lappend inopts [list $ff - - - - "pack -side left -expand 1 -fill x $gopts" $attrs]
        }
        fc {
          if {![info exist $vv]} {catch {set $vv {}}}
          lappend inopts [list $ff - - - - "pack -side left -expand 1 -fill x $gopts" "-tvar $vv -values \{$valopts\} $attrs"]
        }
        op {
          set $vv $vsel
          lappend inopts [list $ff - - - - "pack -fill x $gopts" "$vv $vlist"]
        }
        ra {
          if {![info exist $vv]} {catch {set $vv $vsel}}
          set padx 0
          foreach vo $vlist {
            set name $name
            set FF $ff[incr nnn]
            lappend inopts [list $FF - - - - "pack -side left $gopts -padx $padx" "-var $vv -value \"$vo\" -t \"$vo\" $attrs"]
            if {$ismeth} {
              MakeWidgetName $FF $Name$nnn -
            }
            set padx [expr {$padx ? 0 : 9}]
          }
        }
        te {
          if {![info exist $vv]} {
            set valopts [string map [list \\n \n \\t \t] $valopts]
            set $vv [string map [list \\\\ \\ \\\} \} \\\{ \{] $valopts]
          }
          # xxx
          #tk_messageBox -title $dan(TITLE) -icon error -message $vv          
          if {[dict exist $attrs -state] && [dict get $attrs -state] eq "disabled"} \
          {
            # disabled text widget cannot be filled with a text, so we should
            # compensate this through a home-made attribute (-disabledtext)
            set disattr "-disabledtext \{[set $vv]\}"
          } elseif {[dict exist $attrs -readonly] && [dict get $attrs -readonly] || [dict exist $attrs -ro] && [dict get $attrs -ro]} {
            set disattr "-rotext \{[set $vv]\}"
            set attrs [removeOptions $attrs -readonly -ro]
          } else {
            set disattr {}
          }
          lappend inopts [list $ff - - - - "pack -side left -expand 1 -fill both $gopts" "$attrs $disattr"]
          lappend inopts [list fraM.fra$name.sbv$name $ff L - - "pack -fill y"]
        }
        la {
          if {$prompt ne {}} { set prompt "-t \"$prompt\" " } ;# prompt as -text
          lappend inopts [list $ff - - - - "pack -anchor w $gopts" "$prompt$attrs"]
          continue
        }
        bu - bt - ch {
          set prompt {}
          if {$toprev eq {}} {
            lappend inopts [list $ff - - - - \
              "pack -side left -expand 1 -fill both $gopts" "$tvar $vv $attrs"]
          } else {
            lappend inopts [list $frameprev.$name - - - - \
              "pack -side left $gopts" "$tvar $vv $attrs"]
          }
          if {$vv ne {}} {
            if {![info exist $vv]} {
              catch {
                if {$vsel eq {}} {set vsel 0}
                set $vv $vsel
              }
            }
          }
        }
        default {
          if {$vlist ne {}} {lappend attrs -values $vlist}
          lappend inopts [list $ff - - - - \
            "pack -side left -expand 1 -fill x $gopts" "$tvar $vv $attrs"]
          if {$vv ne {}} {
            if {![info exist $vv]} {catch {set $vv $vsel}}
          }
        }
      }
      if {$msgLab ne {}} {
        lassign $msgLab lab msg attlab
        set lab [parentWName [lindex $inopts end 0]].$lab
        if {$msg ne {}} {set msg "-t {$msg}"}
        append msg " $attlab"
        lappend inopts [list $lab - - - - "pack -side left -expand 1 -fill x" $msg]
      }
      if {![info exist $vv]} {set $vv {}}
      # xxx
      if {$typ eq "en"} {
        #tk_messageBox -title $dan(TITLE) -icon error -message setvv=[set $vv]
        addDialogField $name [set $vv] ""
      }        
      lappend _savedvv $vv [set $vv]
      set frameprev $framename
    }
    lassign [parseOptions $args -titleHELP {} -buttons {} -comOK 1 \
      -titleOK OK -titleCANCEL Cancel -centerme {}] \
      titleHELP buttons comOK titleOK titleCANCEL centerme
    if {$titleHELP eq {}} {
      set butHelp {}
    } else {
      lassign $titleHELP title command
      set butHelp [list butHELP $title $command]
    }
    if {$titleCANCEL eq {}} {
      set butCancel {}
    } else {
      set butCancel "butCANCEL $titleCANCEL destroy"
    }
    if {$centerme eq {}} {
      set centerme {-centerme 1}
    } else {
      set centerme "-centerme $centerme"
    }
    set args [removeOptions $args \
      -titleHELP -buttons -comOK -titleOK -titleCANCEL -centerme -modal]
    # xxx
    #set buttons [string map {"butOK OK 1" "" "butCANCEL Cancel destroy" ""} $buttons]

    #tk_messageBox -title $dan(TITLE) -icon info -message new_buttons=$buttons
    lappend args {*}$focusopt
    #lassign [PrepArgs {*}$args] args
    if {[catch { \
        lassign [PrepArgs {*}$args] args
        set res [Query $dlgname $icon $ttl {} \
        "$butHelp $buttons butOK $titleOK $comOK $butCancel" \
        butOK $inopts $args {} {*}$centerme -input yes]} e]} {
        
      catch {destroy $Dlgpath]}  ;# Query's window
      # ::apave::obj ok err "ERROR" "\n$e\n" \
      #   -t 1 -head "\nAPave returned an error: \n" -hfg red -weight bold
      
      #tk_messageBox -title $dan(TITLE) -icon info -message "::win returned an error:$e"
      
			set res 0
			set msg "\nERROR in win:"
			puts \n$msg\n\n$e$::errorInfo\n
			#set msg "$msg\n\n$e\n\nPlease, inform authors.\nDetails are in stdout."
			#tk_messageBox -title $dan(TITLE) -icon error -message $msg
			#exit 2
      
      return $res
    }
    if {![lindex $res 0]} {  ;# restore old values if OK not chosen
      foreach {vn vv} $_savedvv {
        # tk_optionCascade (destroyed now) was tracing its variable => catch
        catch {set $vn $vv}
      }
    }
    
    return $res
  }

# _______________________ insert tab amenities _______________ #

  proc insertTab {} {
  
    namespace upvar ::radxide dan dan
    
    set wt $dan(TEXT) 
  
    #set idx1 [$wt index {insert linestart}]
    #set idx2 [$wt index {insert lineend}]
    #set line [$wt get $idx1 $idx2]
    
    $wt insert {insert} $dan(TAB_IN_SPACE)
    
    return -code break
  
  }

# ________________________ IntStatus _________________________ #


  proc IntStatus {w {name "status"} {val ""}} {
    # Sets/gets a status of window. The status is an integer assigned to a name.
    #   w - window's path
    #   name - name of status
    #   val - if blank, to get a value of status; otherwise a value to set
    # Default value of status is 0.
    # Returns an old value of status.
    # See also: WindowStatus

    set old [WindowStatus $w $name {} 0]
    if {$val ne {}} {WindowStatus $w $name $val 1}
    return $old
  }

# ________________________ LbxSelect _________________________ #


	proc LbxSelect {w idx} {
		# Selects a listbox item.
		#   w - listbox's path
		#   idx - item index

		$w activate $idx
		$w see $idx
		if {[$w cget -selectmode] in {single browse}} {
		  $w selection clear 0 end
		  $w selection set $idx
		  event generate $w <<ListboxSelect>>
		}
	}

# ________________________ ListboxesAttrs _________________________ #


  proc ListboxesAttrs {w attrs} {
    # Appends selection attributes to listboxes.
    # Details:
    #   1. https://wiki.tcl-lang.org/page/listbox+selection
    #   2. https://stackoverflow.com, the question:
    #        the-tablelist-curselection-goes-at-calling-the-directory-dialog

    if {{-exportselection} ni $attrs} {
      append attrs " -ListboxSel $w -selectmode extended -exportselection 0"
    }
    return $attrs
  }

# ________________________ LowercaseWidgetName _________________________ #


  proc LowercaseWidgetName {name} {
    # Makes the widget name lowercased.
    #   name - widget's name
    # The widgets of widget list can have uppercased names which
    # means that the appropriate methods will be created to access
    # their full pathes with a command `my Name`.
    # This method gets a "normal" name of widget accepted by Tk.
    # See also: MakeWidgetName

    set root [ownWName $name]
    return [list [string range $name 0 [string last . $name]][string tolower $root 0 0] $root]
  }

# ________________________ NonTtkStyle _________________________ #


  proc NonTtkStyle {typ {dsbl 0}} {
    # Gets a style for non-ttk widgets.
    #   typ - the type of widget (in apave terms, i.e. but, buT etc.)
    #   dsbl - a mode to get style of disabled (1) or readonly (2) widgets
    # See also: widgetType
    # Method to be redefined in descendants/mixins.
    return
  }

# ________________________ NormalizeName _________________________ #


  proc NormalizeName {refname refi reflwidgets} {
    # Gets the real name of widget from *.name*.
    #   refname - variable name for widget name
    #   refi - variable name for index in widget list
    #   reflwidgets - variable name for widget list
    # The *.name* means "child of some previous" and should be normalized.
    # Example:
    #   If parent: fra.fra .....
    #      child: .but
    #   => normalized: fra.fra.but

    upvar $refname name $refi i $reflwidgets lwidgets
    set wname $name
    if {[string index $name 0] eq {.}} {
      for {set i2 [expr {$i-1}]} {$i2 >=0} {incr i2 -1} {
        lassign [lindex $lwidgets $i2] name2
        if {[string index $name2 0] ne {.}} {
          set name2 [lindex [LowercaseWidgetName $name2] 0]
          set wname "$name2$name"
          set name [lindex [LowercaseWidgetName $name] 0]
          set name "$name2$name"
          break
        }
      }
    }
    return [list $name $wname]
  }

# ________________________ makeMainWindow _________________________ #
  
  # Scrollbars amenities
  proc Yset {widgets master sb args} {
   
    #if {$master eq "master"} {
      #list $sb set [expr [lindex $args 0]] [expr [lindex $args 1]]
      
      set sb1 [lrange $sb 0 0]
      set sb2 [lrange $sb 1 1]
      
      $sb1 set {*}$args
      $sb2 set {*}$args
      
      set w1 [lrange $widgets 1 end]
    #} else {
      #set w1 [lrange $widgets 0 0]		    
    #} 
    
    ::radxide::win::Yview $w1 moveto [lindex $args 0]

  }
  
  proc Yview {widgets args} {
    foreach w $widgets {
      $w yview {*}$args
    }
  } 
  
  proc makeMainWindow {win ttl bg fg} {

    namespace upvar ::radxide dan dan

    set w [set wtop [string trimright $win .]]
    set withfr [expr {[set pp [string last . $w]]>0 && \
      [string match *.fra $w]}]
		if {$withfr} {
		  set wtop [string range $w 0 $pp-1]
		}
		
    # menu
		set m [::radxide::menu::menuScaf]
	  
		toplevel $wtop -menu $m

		if {$withfr} {
		
		  # main frame
		  pack [frame $w -background $bg ] -expand 1 -fill both
		  
		  # panedwindow
		  pack [set pan [ttk::panedwindow $w.pan -orient horizontal]] -side top -fill both -expand 1
		  
		  # tree pane (panL)
		  pack [set w1 [frame $pan.fra1 -background $bg ]] -side left -fill both ;#-expand 1 -fill both
		  set panL [$pan add $pan.fra1]
		  pack [set tree [ttk::treeview $w1.tree -selectmode extended]] -side left -fill both -expand 1
		  set dan(TREEVIEW) $w1.tree
		  $tree heading #0 -text "  Project" -anchor "w"
		  
		  # main pane (panR)
		  pack [set w2 [ttk::panedwindow $pan.fra2 -orient horizontal]] -side left -fill both -expand 1
		  set panR [$pan add $pan.fra2]
		  text $w2.gutText -background "lightgray" -foreground "#222223" -font "Monospace 10" -width 5
		  text $w2.text -background "#FFFFFF" -foreground "#222223" -font "monospace 10" -bd 0 -padx 13 -spacing1 0 -spacing2 0 -spacing3 0 -exportselection yes -width 115 -wrap none 
		  set ww [list .danwin.fra.pan.fra2.text .danwin.fra.pan.fra2.gutText]
		  $w2.text configure -xscrollcommand [list $w2.xscroll set]
		  scrollbar $w2.xscroll -orient horizontal \
		    -command [list $w2.text xview]
		  scrollbar $w2.yscroll1 -orient vertical \
		    -command [list ::radxide::win::Yview $ww]
		  scrollbar $w2.yscroll2 -orient vertical \
		    -command [list $w2.gutText yview]		    
		  set ssbb [list .danwin.fra.pan.fra2.yscroll1 .danwin.fra.pan.fra2.yscroll2]  
		  $w2.text configure -yscrollcommand [list ::radxide::win::Yset $ww master $ssbb]
		  $w2.gutText configure -yscrollcommand [list .danwin.fra.pan.fra2.yscroll2 set]		    
		  grid $w2.gutText $w2.text $w2.yscroll1 -sticky nsew
	   	grid $w2.xscroll -columnspan 2 -sticky nsew
		  grid rowconfigure $w2 0 -weight 1
		  grid columnconfigure $w2 1 -weight 1
			  
		  set dan(GUTTEXT) $w2.gutText
		  set dan(TEXT) $w2.text
		  $dan(GUTTEXT) configure -state disabled
		  $dan(TEXT) configure -state disabled
		  
		  # code library
		  pack [set w3 [frame $pan.fra3 -background $bg]] -side left -fill y -expand 1;
		  set panC [$pan add $pan.fra3]
		  ::radxide::eglib::create $w3
		  
		  # update gutter, key bindings     
      bind $dan(TEXT) "<KeyRelease>" {::radxide::win::fillGutter .danwin.fra.pan.fra2.text .danwin.fra.pan.fra2.gutText 5 1 "#FFFFFF" "#222223"}
      bind $tree "<ButtonPress>" {after idle {::radxide::tree::buttonPress %b %x %y %X %Y}}
      bind $tree "<ButtonRelease>" {after idle {::radxide::tree::buttonRelease %b %s %x %y %X %Y}}      
      
   	}
		#wm title $wtop ttl  
 	  
 	  # window shortcut bindings
    set canvas $w2.gutText 	  
 	  ::radxide::menu::defWinShortcuts $dan(TEXT) $canvas  
 	  ::radxide::menu::defWinShortcuts $dan(TREEVIEW) $canvas  

  }

# ________________________ MakeWidgetName _________________________ #


  proc MakeWidgetName {w name {an {}}} {
    # Makes an exported method named after root widget, if it's uppercased.
    #   w - name of root widget
    #   name - name of widget
    #   an - additional prefix for name (if "-", $w is full/partial name)
    # The created method used for easy access to the widget's path.
    # Example:
    #   fra1.fra2.fra3.Entry1
    #   => method Entry1 {} {...}
    #   ...
    #   my Entry1  ;# instead of .win.fra1.fra2.fra3.Entry1

    if {$an eq {-}} {
      set wnamefull "\[DiaWidgetName $w\]"
    } else {
      set wnamefull [WidgetNameFull $w $name $an]
      lassign [LowercaseWidgetName $wnamefull] wnamefull
    }
    set method [ownWName $name]
    set root1 [string index $method 0]
    #if {[string is upper $root1]} {
    #  oo::objdefine [self] "method $method {} {return $wnamefull} ; \
    #    export $method"
    #}
    return $wnamefull
  }

# ________________________ makeWindow _________________________ #


  proc makeWindow {w ttl args} {
    # Creates a toplevel window that has to be paved.
    #   w - window's name
    #   ttl - window's title
    #   args - options for 'toplevel' command
    # If $w matches "*.fra" then ttk::frame is created with name $w.

    namespace upvar ::radxide dan dan

    #CleanUps
    set w [set wtop [string trimright $w .]]
    set withfr [expr {[set pp [string last . $w]]>0 && \
      [string match *.fra $w]}]
    if {$withfr} {
      set wtop [string range $w 0 $pp-1]
    }
    catch {destroy $wtop}
    lassign [extractOptions args -type {}] type
    toplevel $wtop {*}$args
    withdraw $wtop ;# nice to hide all gui manipulations
    if {$type ne {} && [tk windowingsystem] eq {x11}} {
      wm attributes $wtop -type $type
    }
    if {$withfr} {
      pack [frame $w -background $dan(BG)] -expand 1 -fill both
    }
    wm title $wtop $ttl
    return $wtop
  }

# ________________________ ownWName _________________________ #


  proc ownWName {name} {
    # Gets a tail (last part) of widget's name
    #   name - name (path) of the widget

    return [lindex [split $name .] end]
  }

# ________________________ parentWName _________________________ #


  proc parentWName {name} {
    # Gets parent name of widget.
    #   name - name (path) of the widget

    return [string range $name 0 [string last . $name]-1]
  }

# ________________________ parseOptionsFile _________________________ #


	proc parseOptionsFile {strict inpargs args} {
		# Parses argument list containing options and (possibly) a file name.
		#   strict - if 0, 'args' options will be only counted for,
		#              other options are skipped
		#   strict - if 1, only 'args' options are allowed,
		#              all the rest of inpargs to be a file name
		#          - if 2, the 'args' options replace the
		#              appropriate options of 'inpargs'
		#   inpargs - list of options, values and a file name
		#   args  - list of default options
		#
		# The inpargs list contains:
		#   - option names beginning with "-"
		#   - option values following their names (may be missing)
		#   - "--" denoting the end of options
		#   - file name following the options (may be missing)
		#
		# The *args* parameter contains the pairs:
		#   - option name (e.g., "-dir")
		#   - option default value
		#
		# If the *args* option value is equal to =NONE=, the *inpargs* option
		# is considered to be a single option without a value and,
		# if present in inpargs, its value is returned as "yes".
		#
		# If any option of *inpargs* is absent in *args* and strict==1,
		# the rest of *inpargs* is considered to be a file name.
		#
		# The proc returns a list of two items:
		#   - an option list got from args/inpargs according to 'strict'
		#   - a file name from inpargs or {} if absent
		#
		# Examples see in tests/obbit.test.

		variable _PU_opts
		set actopts true
		array set argarray "$args yes yes" ;# maybe, tail option without value
		if {$strict==2} {
		  set retlist $inpargs
		} else {
		  set retlist $args
		}
		set retfile {}
		for {set i 0} {$i < [llength $inpargs]} {incr i} {
		  set parg [lindex $inpargs $i]
		  if {$actopts} {
		    if {$parg eq "--"} {
		      set actopts false
		    } elseif {[catch {set defval $argarray($parg)}]} {
		      if {$strict==1} {
		        set actopts false
		        append retfile $parg " "
		      } else {
		        incr i
		      }
		    } else {
		      if {$strict==2} {
		        if {$defval == $_PU_opts(-NONE)} {
		          set defval yes
		        }
		        incr i
		      } else {
		        if {$defval == $_PU_opts(-NONE)} {
		          set defval yes
		        } else {
		          set defval [lindex $inpargs [incr i]]
		        }
		      }
		      set ai [lsearch -exact $retlist $parg]
		      incr ai
		      set retlist [lreplace $retlist $ai $ai $defval]
		    }
		  } else {
		    append retfile $parg " "
		  }
		}
		return [list $retlist [string trimright $retfile]]
	}
	
# ________________________ parseOptions _________________________ #


	proc parseOptions {opts args} {
		# Parses argument list containing options.
		#  opts - list of options and values
		#  args - list of "option / default value" pairs
		# It's the same as parseOptionsFile, excluding the file name stuff.
		# Returns a list of options' values, according to args.
		# See also: parseOptionsFile

		lassign [parseOptionsFile 0 $opts {*}$args] tmp
		foreach {nam val} $tmp {
		  lappend retlist $val
		}
		return $retlist
	}

# ________________________ popupHighlightCommands _________________________ #


  proc popupHighlightCommands {{pop ""} {txt ""}} {
    # Returns highlighting commands for a popup menu on a text.
    #   pop - path to the menu
    #   txt - path to the text

    set res ""
 
    return $res
  }

# ________________________ Pre _________________________ #


  proc Pre {refattrs} {
    # "Pre" actions for the text widget and similar
    # which all require some actions before and after their creation e.g.:
    #   the text widget's text cannot be filled if disabled
    #   so, we must act this way:
    #     1. call Pre - to get a text of widget
    #     2. create the widget
    #     3. call Post - to enable, then fill it with a text, then disable it
    # It's only possible with Pre and Post methods.
    # See also: Post

    upvar 1 $refattrs attrs
    set attrs_ret [set Prepost [list]]
    foreach {a v} $attrs {
      switch -exact -- $a {
        -disabledtext - -rotext - -lbxsel - -cbxsel - -notebazook - \
        -entrypop - -entrypopRO - -textpop - -textpopRO - -ListboxSel - \
        -callF2 - -timeout - -bartabs - -onReturn - -linkcom - -selcombobox - \
        -afteridle - -gutter - -propagate - -columnoptions - -selborderwidth -
        -selected - -popup - -bindEC - -tags - -debug - -clearcom {
          # attributes specific to apave, processed below in "Post"
          set v2 [string trimleft $v \{]
          set v2 [string range $v2 0 end-[expr {[string length $v]-[string length $v2]}]]
          lappend Prepost [list $a $v2]
        }
        -myown {
          lappend Prepost [list $a [subst $v]]
        }
        -labelwidget { ;# widget path as a method
          set v [string trim $v \{\}]
          catch {set v [$::win::$v]}
          lappend attrs_ret $a $v
        }
        default {
          lappend attrs_ret $a $v
        }
      }
    }
    set attrs $attrs_ret
    return
  }

# ________________________ PrepArgs _________________________ #


  proc PrepArgs {args} {
    # Prepares a list of arguments.
    # Returns the list (wrapped in list) and a command for OK button.

    lassign [parseOptions $args -modal {} -ch {} -comOK {} -onclose {}] \
      modal ch comOK onclose
    if {[string is true -strict $modal]} {
      set com 1
    } elseif {$ch ne {}} {
      # some options are incompatible with -ch
      if {$onclose eq {destroy}} {set onclose {}}
      lappend args -modal 1 -onclose $onclose
      set com 1
    } elseif {$comOK eq {}} {
      set com destroy  ;# non-modal without -ch option
    } else {
      set com $comOK
    }
    return [list [list $args] $com]
  }

  ## ________________________ Query _________________________ ##

  proc Query {dlgname icon ttl msg buttons defb inopts argdia {precom ""} args} {
    # Makes a query (or a message) and gets the user's response.
    #   dlgname - dialog name
    #   icon    - icon name (info, warn, ques, err)
    #   ttl     - title
    #   msg     - message
    #   buttons - list of triples "button name, text, ID"
    #   defb    - default button (OK, YES, NO, CANCEL, RETRY, ABORT)
    #   inopts  - options for input dialog
    #   argdia - list of dialog's options
    #   precom - command(s) performed before showing the dialog
    #   args - additional options (message's font etc.)
    # The *argdia* may contain additional options of the query, like these:
    #   -checkbox text (-ch text) - makes the checkbox's text visible
    #   -geometry +x+y (-g +x+y) - sets the geometry of dialog
    #   -color cval    (-c cval) - sets the color of message
    # If "-geometry" option is set (even equaling "") the Query procedure
    # returns a list with chosen button's ID and a new geometry.
    # Otherwise it returns only the chosen button's ID.
    # See also:
    # [aplsimple.github.io](https://aplsimple.github.io/en/tcl/pave/index.html)

    namespace upvar ::radxide dan dan
    variable Indexdlg
    variable Foundstr
    variable Dlgpath    
    variable Dlgname
    variable dlg
    
    #tk_messageBox -title $dan(TITLE) -icon error -message "Query"

    set Winpath $dan(WIN)
    set Dlgname $dlg(NAME)
    set wdia $Winpath.dia$Dlgname
    #append wdia [lindex [split :] end] ;# be unique per apave object
    #set qdlg [set dlg(PATH) [set Dlgpath $wdia[incr Indexdlg]]]
    set qdlg $Dlgpath
    #tk_messageBox -title $dan(TITLE) -icon error -message $qdlg
    # remember the focus (to restore it after closing the dialog)
    set focusback [focus]
    set focusmatch {}
    # options of dialog
    lassign {} chmsg geometry optsLabel optsMisc optsFont optsFontM optsHead \
      root rotext head hsz binds postcom onclose timeout tab2 \
      tags cc themecolors optsGrid addpopup minsize
    set wasgeo [set textmode [set stay [set waitvar 0]]]
    set readonly [set hidefind [set scroll [set modal 1]]]
    set curpos {1.0}
    set CheckNomore 0
    foreach {opt val} {*}$argdia {
      if {$opt in {-c -color -fg -bg -fgS -bgS -cc -hfg -hbg}} {
        # take colors by their variables
        if {[info exist $val]} {set val [set $val]}
      }
      switch -- $opt {
        -H - -head {
          set head [string map {$ \$ \" \'\' \{ ( \} )} $val]
        }
        -help {
          set buttons "butHELP Help {$val} $buttons"
        }
        -ch - -checkbox {set chmsg "$val"}
        -g - -geometry {
          set geometry $val
          if {[set wasgeo [expr {[string first "pointer" $val]<0}]]} {
            lassign [splitGeometry $geometry] - - gx gy
          }
        }
        -c - -color {append optsLabel " -foreground {$val}"}
        -a { ;# additional grid options of message labels
          append optsGrid " $val" }
        -centerme - -ontop - -themed - -resizable - -checkgeometry - -onclose - -comOK - -transient {
          lappend args $opt $val ;# options delegated to showModal method
        }
        -parent - -root { ;# obsolete, used for compatibility
          lappend args -centerme $val
        }
        -t - -text {set textmode $val}
        -tags {
          upvar 2 $val _tags
          set tags $_tags
        }
        -ro - -readonly {set readonly [set hidefind $val]}
        -rotext {set hidefind 0; set rotext $val}
        -w - -width {set charwidth $val}
        -h - -height {set charheight $val}
        -fg {append optsMisc " -foreground {$val}"}
        -bg {append optsMisc " -background {$val}"}
        -fgS {append optsMisc " -selectforeground {$val}"}
        -bgS {append optsMisc " -selectbackground {$val}"}
        -cc {append optsMisc " -insertbackground {$val}"}
        -my - -myown {append optsMisc " -myown {$val}"}
        -pos {set curpos "$val"}
        -hfg {append optsHead " -foreground {$val}"}
        -hbg {append optsHead " -background {$val}"}
        -hsz {append hsz " -size $val"}
        -minsize {set minsize "-minsize {$val}"}
        -focus {set focusmatch "$val"}
        -theme {append themecolors " {$val}"}
        -post {set postcom $val}
        -popup {set addpopup [string map [list %w $qdlg.fra.texM] "$val"]}
        -timeout - -focusback - -scroll - -tab2 - -stay - -modal - -waitvar {
          set [string range $opt 1 end] $val
        }
        default {
          append optsFont " $opt $val"
          if {$opt ne "-family"} {
            append optsFontM " $opt $val"
          }
        }
      }
    }
    if {[set wprev [InfoFind $wdia $modal]] ne {}} {
      catch {
        wm withdraw $wprev
        wm deiconify $wprev
        puts "$wprev already exists: selected now"
      }
      return 0
    }
    set optsFont [string trim $optsFont]
    set optsHeadFont $optsFont
    set fs [basicFontSize]
    set textfont "-family {[basicTextFont]}"
    if {$optsFont ne {}} {
      if {[string first "-size " $optsFont]<0} {
        append optsFont " -size $fs"
      }
      if {[string first "-size " $optsFontM]<0} {
        append optsFontM " -size $fs"
      }
      if {[string first "-family " $optsFont]>=0} {
        set optsFont "-font \{$optsFont"
      } else {
        set optsFont "-font \{$optsFont -family {[basicDefFont]}"
      }
      append optsFont "\}"
    } else {
      set optsFont "-font {[basicDefFont] -size $fs}"
      set optsFontM "-size $fs"
    }
    set msgonly [expr {$readonly || $hidefind || $chmsg ne {}}]
    if {!$textmode || $msgonly} {
      set textfont "-family {[basicDefFont]}"
      if {!$textmode} {
        set msg [string map [list \\ \\\\ \{ \\\\\{ \} \\\\\}] $msg]
      }
    }
    set optsFontM [string trim $optsFontM]
    set optsFontM "-font \{$optsFontM $textfont\}"
    # layout: add the icon
    if {$icon ni {{} -}} {
      #tk_messageBox -title $dan(TITLE) -icon error -message "Yess!"
      set widlist [list [list labBimg - - 99 1 \
        {-st n -pady 7} "-image [iconImage $icon]"]]
      set prevl labBimg
    } else {
      set widlist [list [list labimg - - 99 1]]
      set prevl labimg ;# this trick would hide the prevw at all
    }
    set prevw labBimg
    #tk_messageBox -title $dan(TITLE) -icon info -message Header:$head
    if {$head ne {}} {
      # set the dialog's heading (-head option)
      if {$optsHeadFont ne {} || $hsz ne {}} {
        if {$hsz eq {}} {set hsz "-size [basicFontSize]"}
        set optsHeadFont [string trim "$optsHeadFont $hsz"]
        set optsHeadFont "-font \"$optsHeadFont\""
      }
      set optsFont {}
      set prevp L
      set head [string map {\\n \n} $head]
      foreach lh [split $head "\n"] {
        set labh "labheading[incr il]"
        lappend widlist [list $labh $prevw $prevp 1 99 {-st we} \
          "-t \"$lh\" $optsHeadFont $optsHead"]
        set prevw [set prevh $labh]
        set prevp T
      }
    } else {
      # add the upper (before the message) blank frame
      lappend widlist [list h_1 $prevw L 1 1 {-pady 3}]
      set prevw [set prevh h_1]
      set prevp T
    }
    # add the message lines
    set il [set maxw 0]
    if {$readonly && $rotext eq {}} {
      # only for messaging (not for editing/viewing texts):
      set msg [string map {\\\\n \\n \\n \n} $msg]
    }
    foreach m [split $msg \n] {
      set m [string map {$ \$ \" \'\'} $m]
      if {[set mw [string length $m]] > $maxw} {
        set maxw $mw
      }
      incr il
      if {!$textmode} {
        lassign [GetLinkLab $m] m link
        lappend widlist [list Lab$il $prevw $prevp 1 7 \
          "-st w -rw 1 $optsGrid" "-t \"$m \" $optsLabel $optsFont $link"]
      }
      set prevw Lab$il
      set prevp T
    }
    if {$inopts ne {}} {
      # here are widgets for input (in fraM frame)
      set io0 [lindex $inopts 0]
      lset io0 1 $prevh
      lset inopts 0 $io0
      foreach io $inopts {
        lappend widlist $io
      }
      set prevw fraM
    } elseif {$textmode} {
      # here is text widget (in fraM frame)
    ; proc vallimits {val lowlimit isset limits} {
        set val [expr {max($val,$lowlimit)}]
        if {$isset} {
          upvar $limits lim
          lassign $lim l1 l2
          set val [expr {min($val,$l1)}] ;# forced low
          if {$l2 ne {}} {set val [expr {max($val,$l2)}]} ;# forced high
        }
        return $val
      }
      set il [vallimits $il 1 [info exists charheight] charheight]
      incr maxw
      set maxw [vallimits $maxw 20 [info exists charwidth] charwidth]
      rename vallimits {}
      lappend widlist [list fraM $prevh T 10 12 {-st nswe -pady 3 -rw 1}]
      lappend widlist [list TexM - - 1 12 {pack -side left -expand 1 -fill both -in \
        $qdlg.fra.fraM} [list -h $il -w $maxw {*}$optsFontM {*}$optsMisc \
        -wrap word -textpop 0 -tabnext "$qdlg.fra.[lindex $buttons 0] *but0"]]
      if {$scroll} {
        lappend widlist {sbv texM L 1 1 {pack -in $qdlg.fra.fraM}}
      }
      set prevw fraM
    }
    # add the lower (after the message) blank frame
    lappend widlist [list h_2 $prevw T 1 1 {-pady 0 -ipady 0 -csz 0}]
    # underline the message
    lappend widlist [list seh $prevl T 1 99 {-st ew}]
    # add left frames and checkbox (before buttons)
    lappend widlist [list h_3 seh T 1 1 {-pady 0 -ipady 0 -csz 0}]
    if {$textmode} {
      # binds to the special popup menu of the text widget
      set wt "\[TexM\]"
      set binds "set pop $wt.popupMenu
        bind $wt <Button-3> \{[self] themePopup $wt.popupMenu; tk_popup $wt.popupMenu %X %Y \}"
      if {$msgonly} {
        append binds "
          menu \$pop
           \$pop add command [iconA copy] -accelerator Ctrl+C -label \"Copy\" \\
            -command \"event generate $wt <<Copy>>\""
        if {$hidefind || $chmsg ne {}} {
          append binds "
            \$pop configure -tearoff 0
            \$pop add separator
            \$pop add command [iconA none] -accelerator Ctrl+A \\
            -label \"Select All\" -command \"$wt tag add sel 1.0 end\"
             bind $wt <Control-a> \"$wt tag add sel 1.0 end; break\""
        }
      }
    }
    set appendHL no
    if {$chmsg eq {}} {
      if {$textmode} {
        set noIMG "[iconA none]"
        if {$hidefind} {
          lappend widlist [list h__ h_3 L 1 4 {-cw 1}]
        } else {
          lappend widlist [list labfnd h_3 L 1 1 "-st e" "-t {$::win::msgarray(find)}"]
          lappend widlist [list Entfind labfnd L 1 1 \
            {-st ew -cw 1} "-tvar [namespace current]::Foundstr -w 10"]
          lappend widlist [list labfnd2 Entfind L 1 1 "-cw 2" "-t {}"]
          lappend widlist [list h__ labfnd2 L 1 1]
          #append binds "
          #  bind \[[self] Entfind\] <Return> {[self] findInText}
          #  bind \[[self] Entfind\] <KP_Enter> {[self] findInText}
          #  bind \[[self] Entfind\] <FocusIn> {\[[self] Entfind\] selection range 0 end}
          #  bind $qdlg <F3> {[self] findInText 1}
          #  bind $qdlg <Control-f> \"InitFindInText 1; focus \[[self] Entfind\]; break\"
          #  bind $qdlg <Control-F> \"InitFindInText 1; focus \[[self] Entfind\]; break\""
        }
        if {$readonly} {
          if {!$hidefind} {
           # append binds "
           #  \$pop add separator
           #  \$pop add command [iconA find] -accelerator Ctrl+F -label \\
           #  \"Find First\" -command \"[self] InitFindInText; focus \[[self] Entfind\]\"
           #  \$pop add command $noIMG -accelerator F3 -label \"Find Next\" \\
           #   -command \"[self] findInText 1\"
           #  $addpopup
           #  \$pop add separator
           #  \$pop add command [iconA exit] -accelerator Esc -label \"Close\" \\
           #   -command \"\[[self] paveoptionValue Defb1\] invoke\"
           # "
          } else {
            set appendHL yes
          }
        } else {
          # make bindings and popup menu for text widget
          #after idle "set_highlight_matches \[TexM\]"
          #append binds "
          #  [setTextBinds $wt]
          #  menu \$pop
          #   \$pop add command [iconA cut] -accelerator Ctrl+X -label \"Cut\" \\
          #    -command \"event generate $wt <<Cut>>\"
          #   \$pop add command [iconA copy] -accelerator Ctrl+C -label \"Copy\" \\
          #    -command \"event generate $wt <<Copy>>\"
          #   \$pop add command [iconA paste] -accelerator Ctrl+V -label \"Paste\" \\
          #    -command \"event generate $wt <<Paste>>\"
          #   [popupBlockCommands \$pop $wt]
          #   [popupHighlightCommands \$pop $wt]
          #   [popupFindCommands \$pop $wt]
          #   $addpopup
          #   \$pop add separator
          #   \$pop add command [iconA SaveFile] -accelerator Ctrl+W \\
          #   -label \"Save and Close\" -command \"[self] res $qdlg 1\"
          #  "
        }
        #set onclose [namespace current]::exitEditor
        #oo::objdefine [self] export InitFindInText
      } else {
        lappend widlist [list h__ h_3 L 1 4 {-cw 1}]
      }
    } else {
      lappend widlist [list chb h_3 L 1 1 \
        {-st w} "-t {$chmsg} -var [namespace current]::CheckNomore"]
      lappend widlist [list h_ chb L 1 1]
      lappend widlist [list sev h_ L 1 1 {-st nse -cw 1}]
      lappend widlist [list h__ sev L 1 1]
      set appendHL $textmode
    }
    #if {$appendHL} {
    #  after idle "set_highlight_matches $wt"
    #  append binds "
    #  [popupHighlightCommands \$pop $wt]"
    #}
    # add the buttons
    
    # xxx
    if {$dlgname eq "RenameFile" || $dlgname eq "RenameFolder" || $dlgname eq "Find" || $dlgname eq "GotoLine"} {
      set buttons [string map {"butOK OK 1" "" "butCANCEL Cancel destroy" ""} $buttons]
    }
    lassign [AppendButtons widlist $buttons h__ L $defb $timeout $qdlg $modal] \
      bhelp bcomm
    # make the dialog's window
    set wtop [makeWindow $qdlg.fra $ttl]
    if {$bhelp ne {}} {
      bind $qdlg <F1> $bcomm
    }
    # pave the dialog's window
    if {$tab2 eq {}} {
      set widlist [rockWindow $qdlg.fra $widlist]
    } else {
      # pave with the notebook tabs (titl1 title2 [title3...] widlist2 [widlist3...])
      lassign $tab2 ttl1 ttl2 widlist2 ttl3 widlist3 ttl4 widlist4 ttl5 widlist5
      foreach nt {3 4 5} {
        set ttl ttl$nt
        set wdl widlist$nt
        if {[set _ [set $ttl]] ne {}} {
          set $ttl [list f$nt "-t {$_}"]
          set $wdl [list $qdlg.fra.nbk.f$nt "[set $wdl]"]
        }
      }
      set widlist0 [list [list nbk - - - - {pack -side top -expand 1 -fill both} [list \
        f1 "-t {$ttl1}" \
        f2 "-t {$ttl2}" \
        {*}$ttl3 \
        {*}$ttl4 \
        {*}$ttl5 \
      ]]]
    
      set widlist1 [list]
      foreach it $widlist {
        lassign $it w nei pos r c opt atr
        set opt [string map {$qdlg.fra $qdlg.fra.nbk.f1} $opt]
        lappend widlist1 [list $w $nei $pos $r $c $opt $atr]
      }
      set widlist [rockWindow $qdlg.fra $widlist0 \
        $qdlg.fra.nbk.f1 $widlist1 \
        $qdlg.fra.nbk.f2 $widlist2 \
        {*}$widlist3 \
        {*}$widlist4 \
        {*}$widlist5 \
      ]
      set tab2 nbk.f1.
    }
    if {$precom ne {}} {
      {*}$precom  ;# actions before showModal
    }
    # if {$themecolors ne {}} {
    #   # themed colors are set as sequentional '-theme' args
    #   if {[llength $themecolors]==2} {
    #     # when only 2 main fb/bg colors are set (esp. for TKE)
    #     lassign [::apave::parseOptions $optsMisc -foreground black \
    #       -background white -selectforeground black \
    #       -selectbackground gray -insertbackground black] v0 v1 v2 v3 v4
    #     # the rest colors should be added, namely:
    #     #   tfg2 tbg2 tfgS tbgS tfgD tbgD tcur bclr help fI bI fM bM fW bW bHL2
    #     lappend themecolors $v0 $v1 $v2 $v3 $v3 $v1 $v4 $v4 $v3 $v2 $v3 $v0 $v1 black #ffff9e $v1
    #   }
    #   catch {
    #     my themeWindow $qdlg $themecolors no
    #   }
    # }
    # after creating widgets - show dialog texts if any
    SetGetTexts set $qdlg.fra $inopts $widlist
    lassign [LowercaseWidgetName $qdlg.fra.$tab2$defb] focusnow
    if {$textmode} {
      displayTaggedText [TexM] msg $tags
      if {$defb eq "ButTEXT"} {
        if {$readonly} {
          lassign [LowercaseWidgetName $Defb1] focusnow
        } else {
          set focusnow [TexM]
          catch "::tk::TextSetCursor $focusnow $curpos"
          foreach k {w W} \
            {catch "bind $focusnow <Control-$k> {[self] res $qdlg 1; break}"}
        }
      }
      if {$readonly} {
        readonlyWidget ::[TexM] true false
      }
    }
    if {$focusmatch ne {}} {
      foreach w $widlist {
        lassign $w widname
        lassign [LowercaseWidgetName $widname] wn rn
        if {[string match $focusmatch $rn]} {
          lassign [LowercaseWidgetName $qdlg.fra.$wn] focusnow
          break
        }
      }
    }
    catch "$binds"
    set args [removeOptions $args -focus]
    set querydlg $qdlg
    showModal $qdlg -modal $modal -waitvar $waitvar -onclose $onclose \
      -focus $focusnow -geometry $geometry {*}$minsize {*}$args
    if {![winfo exists $qdlg] || (!$modal && !$waitvar)} {
      return 0
    }
    set pdgeometry [wm geometry $qdlg]
    # the dialog's result is defined by "pave res" + checkbox's value
    # xxx
    #tk_messageBox -title $dan(TITLE) -icon info -message $qdlg 
    set res [set result [::radxide::win::res $qdlg]]
    #tk_messageBox -title $dan(TITLE) -icon info -message resX=$res
    set chv $CheckNomore
    if { [string is integer $res] } {
      if {$res && $chv} { incr result 10 }
    } else {
      set res [expr {$result ne {} ? 1 : 0}]
      if {$res && $chv} { append result 10 }
    }
    if {$textmode && !$readonly} {
      set focusnow [TexM]
      set textcont [$focusnow get 1.0 end]
      if {$res && $postcom ne {}} {
        {*}$postcom textcont [TexM] ;# actions after showModal
      }
      set textcont " [$focusnow index insert] $textcont"
    } else {
      set textcont {}
    }
    if {$res && $inopts ne {}} {
      SetGetTexts get $qdlg.fra $inopts $widlist
      set inopts " [GetVarsValues $widlist]"
    } else {
      set inopts {}
    }
    if {$textmode && $rotext ne {}} {
      set $rotext [string trimright [TexM] get 1.0 end]]
    }
    if {!$stay} {
      destroy $qdlg
      update
      # pause a bit and restore the old focus
      if {$focusback ne {} && [winfo exists $focusback]} {
        set w ".[lindex [split $focusback .] 1]"
        after 50 [list if "\[winfo exist $focusback\]" "focus -force $focusback" elseif "\[winfo exist $w\]" "focus $w"]
      } else {
        after 50 list focus .
      }
    }
    if {$wasgeo} {
      lassign [splitGeometry $pdgeometry] w h x y
      catch {
        # geometry option can contain pointer/root etc.
        if {abs($x-$gx)<30} {set x $gx}
        if {abs($y-$gy)<30} {set y $gy}
      }
      return [list $result ${w}x$h$x$y $textcont [string trim $inopts]]
    }
    return "$result$textcont$inopts"
  }

# ________________________ readonlyWidget _________________________ #


  proc readonlyWidget {w {on yes} {popup yes}} {
    # Switches on/off a widget's readonly state for a text widget.
    #   w - text widget's path
    #   on - "on/off" boolean flag
    #   popup - "make popup menu" boolean flag
    # See also:
    #   [wiki.tcl-lang.org](https://wiki.tcl-lang.org/page/Read-only+text+widget)

    #my TextCommandForChange $w {} $on
    #if {$popup} {my makePopup $w $on yes}
    return
  }


	proc readTextFile {fileName {varName ""} {doErr 0} args} {
		# Reads a text file.
		#   fileName - file name
		#   varName - variable name for file content or ""
		#   doErr - if 'true', exit at errors with error message
		# Returns file contents or "".

		variable _PU_opts
		if {$varName ne {}} {upvar $varName fvar}
		if {[catch {set chan [open $fileName]} _PU_opts(_ERROR_)]} {
		  if {$doErr} {error [::radxide::win::error $fileName]}
		  set fvar {}
		} else {
		  set enc [getOption -encoding {*}$args]
		  set eol [string tolower [getOption -translation {*}$args]]
		  if {$eol eq {}} {set eol auto} ;# let EOL be autodetected by default
		  textChanConfigure $chan $enc $eol
		  set fvar [read $chan]
		  close $chan
		  logMessage "read $fileName"
		}
		return $fvar
	}

# ________________________ renameFileOK _________________________ #


  proc renameFileOK {} {
  
    namespace upvar ::radxide dan dan project project

    variable dlg
    
    #set t $Dlgpath.fra.fraM.fraent.ent
    set t [dlgPath].fra.[FieldName [lindex [getDialogField 0] 0]]
    #tk_messageBox -title $dan(TITLE) -icon info -message textbox=$t
    set varname [lindex [getDialogField end] 0]
    #tk_messageBox -title $dan(TITLE) -icon info -message varname=$varname
    set oldpath [lindex [getDialogField end] 1]
    #tk_messageBox -title $dan(TITLE) -icon info -message oldpath=$oldpath
    set newpath [string trim [$t get]]
    #tk_messageBox -title $dan(TITLE) -icon info -message newpath=$newpath

    set pathlength [expr [string length $newpath]-1] 
    if {[string range $newpath $pathlength $pathlength] eq "/"} {
      tk_messageBox -title $dan(TITLE) -icon info -message "Destination can't be a folder!"
      return 0
    }

    if {[string first $dan(WORKDIR) $newpath] eq -1} {
      tk_messageBox -title $dan(TITLE) -icon info -message "New file path outside the Working Dir!"
      return 0
    }

    if {[string first $project(ROOT) $newpath] eq -1} {
      tk_messageBox -title $dan(TITLE) -icon info -message "New file path outside the Project Dir!"
      return 0
    }
    
    if {[catch {file rename $oldpath $newpath} e]} {
			set msg "\nERROR in win:"
			puts \n$msg\n\n$e$::errorInfo\n
			set msg "$msg\n\n$e\n\nPlease, inform authors.\nDetails are in stdout."
			tk_messageBox -title $dan(TITLE) -icon error -message $msg  
			return 0 
    }
    
	  # saving {field oldval newval} for later use
	  editDialogField end $varname $oldpath $newpath

    ::radxide::tree::create
    
    # Workaround for an overwheling activation of the main text editor..
    if {$project(CUR_FILE_PATH) eq ""} {
      $dan(TEXT) configure -state disabled
    }
        
    catch {destroy [dlgPath]}

    return 1
  }

# ________________________ renameFileCancel _________________________ #


  proc renameFileCancel {} {
  
    #catch {[destroy .danwin.diaRenameFile1]}    
    catch {[destroy [dlgPath]]}
        
    return 0
  }

# ________________________ renameFolderOK _________________________ #


  proc renameFolderOK {} {
  
    namespace upvar ::radxide dan dan project project

    variable dlg
    
    #set t $Dlgpath.fra.fraM.fraent.ent
    set t [dlgPath].fra.[FieldName [lindex [getDialogField 0] 0]]
    #tk_messageBox -title $dan(TITLE) -icon info -message textbox=$t
    set varname [lindex [getDialogField end] 0]
    #tk_messageBox -title $dan(TITLE) -icon info -message varname=$varname
    set oldpath [lindex [getDialogField end] 1]
    #tk_messageBox -title $dan(TITLE) -icon info -message oldpath=$oldpath
    set newpath [string trim [$t get]]
    #tk_messageBox -title $dan(TITLE) -icon info -message newpath=$newpath
    set oldparent [string range $oldpath 0 [expr [string last "/" $oldpath]-1]]
    #tk_messageBox -title $dan(TITLE) -icon info -message oldparent=$oldparent
    set newparent [string range $newpath 0 [expr [string last "/" $newpath]-1]]
    #tk_messageBox -title $dan(TITLE) -icon info -message newparent=$newparent
    
    set pathlength [expr [string length $newpath]-1] 
    if {[string range $newpath $pathlength $pathlength] eq "/"} {
      tk_messageBox -title $dan(TITLE) -icon info -message "Please delete the final '\/'!"
      return 0
    }

    if {[string first $dan(WORKDIR) $newpath] eq -1} {
      tk_messageBox -title $dan(TITLE) -icon info -message "New file path outside the Working Dir!"
      return 0
    }

    if {[string first $project(ROOT) $newpath] eq -1} {
      tk_messageBox -title $dan(TITLE) -icon info -message "New file path outside the Project Dir!"
      return 0
    }
    
    if {$oldparent ne $newparent} {
      tk_messageBox -title $dan(TITLE) -icon info -message "Change of parent folder disallowed!"
      return 0   
    }
    
    if {[catch {file rename $oldpath $newpath} e]} {
			set msg "\nERROR in win:"
			puts \n$msg\n\n$e$::errorInfo\n
			set msg "$msg\n\n$e\n\nPlease, inform authors.\nDetails are in stdout."
			tk_messageBox -title $dan(TITLE) -icon error -message $msg  
			return 0 
    }
    
	  # savind {field oldval newval} for later use
	  editDialogField end $varname $oldpath $newpath

    ::radxide::tree::create
    
    # Workaround for an overwheling activation of the main text editor..
    if {$project(CUR_FILE_PATH) eq ""} {
      $dan(TEXT) configure -state disabled
    }
        
    catch {destroy [dlgPath]}

    return 1
  }

# ________________________ renameFolderCancel _________________________ #


  proc renameFolderCancel {} {
  
    #catch {[destroy .danwin.diaRenameFolder1]}    
    catch {[destroy [dlgPath]]}
        
    return 0
  }



# ________________________ Replace_Tcl _________________________ #


  proc Replace_Tcl {r1 r2 r3 args} {
    # Replaces Tcl code with its resulting items in *lwidgets* list.
    #   r1 - variable name for a current index in *lwidgets* list
    #   r2 - variable name for a length of *lwidgets* list
    #   r3 - variable name for *lwidgets* list
    #   args - "tcl" and "tcl code" for "tcl" type of widget
    # The code should use the wildcard that goes first at a line:
    #   %C - a command for inserting an item into lwidgets list.
    # The "tcl" widget type can be useful to automate the inserting
    # a list of similar widgets to the list of widgets.
    # See tests/test2_pave.tcl where the "tcl" fills "Color schemes" tab.

    lassign $args _name _code
    if {[ownWName $_name] ne {tcl}} {return $args}
    upvar 1 $r1 _ii $r2 _lwlen $r3 _lwidgets
  ; proc lwins {lwName i w} {
      upvar 2 $lwName lw
      set lw [linsert $lw $i $w]
    }
    set _lwidgets [lreplace $_lwidgets $_ii $_ii]  ;# removes tcl item
    set _inext [expr {$_ii-1}]
    eval [string map {%C {lwins $r3 [incr _inext] }} $_code]
    return {}
  }

# ________________________ removeOptions _________________________ #


	proc removeOptions {options args} {
		# Removes some options from a list of options.
		#   options - list of options and values
		#   args - list of option names to remove
		# The `options` may contain "key value" pairs and "alone" options
		# without values.
		# To remove "key value" pairs, `key` should be an exact name.
		# To remove an "alone" option, `key` should be a glob pattern with `*`.

		foreach key $args {
		  while {[incr maxi]<99} {
		    if {[set i [lsearch -exact $options $key]]>-1} {
		      catch {
		        # remove a pair "option value"
		        set options [lreplace $options $i $i]
		        set options [lreplace $options $i $i]
		      }
		    } elseif {[string first * $key]>=0 && \
		      [set i [lsearch -glob $options $key]]>-1} {
		      # remove an option only
		      set options [lreplace $options $i $i]
		    } else {
		      break
		    }
		  }
		}
		return $options
	}


# ________________________ res _________________________ #


  proc res {{win {}} {result get}} {
    # Gets/sets a variable for *vwait* command.
    #   win - window's path
    #   result - value of variable
    # This method is used when
    #  - an event cycle should be stopped with changing a variable's value
    #  - a result of event cycle (the variable's value) should be got
    # In the first case, *result* is set to an integer. In *apave* dialogs
    # the integer is corresponding a pressed button's index.
    # In the second case, *result* is omitted or equal to "get".
    # Returns a value of variable that controls an event cycle.

    if {$win eq {}} {set win [dlgPath]}
    set varname [WinVarname $win]
    if {$result eq {get}} {
      return [set $varname]
    }
    #CleanUps $win
    return [set $varname $result]
  }

# ___________________ rockWindow _________________ #


  proc rockWindow {args} {
    # Processes "win / list_of_widgets" pairs.
    #   args - list of pairs "win / lwidgets"
    # The *win* is a window's path. The *lwidgets* is a list of widget items.
    # Each widget item contains:
    #   name - widget's name (first 3 characters define its type)
    #   neighbor - top or left neighbor of the widget
    #   posofnei - position of neighbor: T (top) or L (left)
    #   rowspan - row span of the widget
    #   colspan - column span of the widget
    #   options - grid/pack options
    #   attrs - attributes of widget
    # First 3 items are mandatory, others are set at need.
    # This method calls *paveWindow* in a cycle, to process a current "win/lwidgets" pair.

    namespace upvar ::radxide dan dan

    #tk_messageBox -title $dan(TITLE) -icon info -message "Start rock-Window!"

    set res [list]
    set wmain [set wdia {}]
    foreach {w lwidgets} $args {
      if {[lindex $lwidgets 0 0] eq {after}} {
        # if 1st item is "after idle" or like "after 1000", layout the window after...
        # (fit for "invisible independent" windows/frames/tabs)
        set what [lindex $lwidgets 0 1]
        if {$what eq {idle} || [string is integer -strict $what]} {
          after $what [rockWindow $w [lrange $lwidgets 1 end]]
          #after $what [list [self] colorWindow $w -doit]
        }
        continue
      }
      lappend res {*}[Window $w $lwidgets]
      if {[set ifnd [regexp -indices -inline {[.]dia\d+} $w]] ne {}} {
        set wdia [string range $w 0 [lindex $ifnd 0 1]]
      } else {
        set wmain .[lindex [split $w .] 1]
      }
    }
    # add a system Menu binding for the created window
    #if {[winfo exists $wdia]} {::apave::initPOP $wdia} elseif {
    #    [winfo exists $wmain]} {::apave::initPOP $wmain}
    return $res
  }

# ________________________ Search _________________________ #


#	proc Search {wtxt} {
#		# Searches a text for a string to find.
#		#   wtxt - text widget's path
#
#		namespace upvar ::alited obPav obPav
#		variable counts
#		variable data
#		set idx [$wtxt index insert]
#		#lassign [FindOptions $wtxt] findstr options
#	  set options {}
#    set findstr $data(en1)
#		if {![CheckData find]} {return {}}
#		$obPav set_HighlightedString $findstr
#		SetTags $wtxt
#		lassign [Search1 $wtxt 1.0] err fnd
#		if {$err} {return {}}
#		set i 0
#		set res [list]
#		foreach index1 $fnd {
#		  set index2 [$wtxt index "$index1 + [lindex $counts $i]c"]
#		  if {[CheckWord $wtxt $index1 $index2]} {
#		    lappend res [list $index1 $index2]
#		  }
#		  incr i
#		}
#		return $res
#	}

#_______________________ selectedWordText _____________________ #


  proc selectedWordText {txt} {
    # Returns a word under the cursor or a selected text.
    #   txt - the text's path

    set seltxt {}
    if {![catch {$txt tag ranges sel} seltxt]} {
      if {$seltxt eq ""} {return ""}
      set forword [expr {$seltxt eq {}}]
      #if {[set forword [expr {$seltxt eq {}}]]} {
      #  set pos  [$txt index "insert wordstart"]
      #  set pos2 [$txt index "insert wordend"]
      #  set seltxt [string trim [$txt get $pos $pos2]]
      #  if {![string is wordchar -strict $seltxt]} {
      #    # when cursor just at the right of word: take the word at the left
      #    set pos  [$txt index "insert -1 char wordstart"]
      #    set pos2 [$txt index "insert -1 char wordend"]
      #  }
      #} else {
        lassign $seltxt pos pos2
      #}
      #catch {
        set seltxt [$txt get $pos $pos2]
        if {[set sttrim [string trim $seltxt]] ne {}} {
          if {$forword} {set seltxt $sttrim}
        }
      #}
    }
    return $seltxt
  }

# ________________________ setAppIcon _________________________ #


  proc setAppIcon {win {winicon ""}} {
    # Sets application's icon.
    #   win - path to a window of application
    #   winicon - data of icon
    # The *winicon* may be a contents of variable (as supposed by default) or
    # a file's name containing th image data.
    # If it fails to find an image in either, no icon is set.

    set appIcon {}
    if {$winicon ne {}} {
      if {[catch {set appIcon [image create photo -data $winicon]}]} {
        catch {set appIcon [image create photo -file $winicon]}
      }
    }
    if {$appIcon ne {}} {wm iconphoto $win -default $appIcon}
  }

# ________________________ SetGetTexts _________________________ #


  proc SetGetTexts {oper w iopts lwidgets} {
    # Sets/gets contents of text fields.
    #   oper - "set" to set, "get" to get contents of text field
    #   w - window's name
    #   iopts - equals to "" if no operation
    #   lwidgets - list of widget items

    if {$iopts eq {}} return
    foreach widg $lwidgets {
      set wname [lindex $widg 0]
      set name [ownWName $wname]
      if {[string range $name 0 1] eq "te"} {
        set vv [::radxide::win::varName $name]
        if {$oper eq "set"} {
          displayText $w.$wname [set $vv]
        } else {
          set $vv [string trimright [$w.$wname get 1.0 end]]
        }
      }
    }
    return
  }

# ________________________ set_HighlightedString _________________________ #


  proc set_HighlightedString {sel} {
    # Saves a string got from highlighting by Alt+left/right/q/w.
    #   sel - the string to be saved

    set HLstring $sel
    if {$sel ne {}} {set Foundstr $sel}
  }

# ________________________ set_highlight_matches _________________________ #


  proc set_highlight_matches {w} {
    # Creates bindings to highlight matches in a text.
    #   w - path to the text

  }

# ________________________ setNewLineWithIndent _________________________ #

  proc setNewLineWithIndent {} {
  
    namespace upvar ::radxide dan dan
  
    set wt $dan(TEXT)

    # getting previous line
    set idx1 [$wt index {insert linestart}]
    set idx2 [$wt index {insert lineend}]
    set line [$wt get $idx1 $idx2]
    
    # erasing tabs, replacing them with spaces..
    set line [string map {\t $dan(TAB_IN_SPACE)} $line]

    # calculating identation..
    set orilength [string length $line]
    set newlength [string length [string trimleft $line]]   
    if {$newlength <= 0} {
      # case previous line is only spaces..
      
      set $newlength 0
      set nindent 0   
      return 0
    } else {
    
      set nspacesofindent [expr $orilength - $newlength] 
      
      # inserintg correct identation..
		  $wt insert [$wt index {insert}] \n[string repeat " " $nspacesofindent]  
		  set idx3 [$wt index insert]
		  set idx4 [$wt index "$idx3 +1 line"]
		  ::tk::TextSetCursor $wt $idx3
      return -code break
    }      
  }
  
# ________________________ setTextBinds _________________________ #


  proc setTextBinds {wt} {
    # Returns bindings for a text widget.
    #   wt - the text's path

    set res ""

    return $res
  }

# ________________________ showModal _________________________ #


  proc showModal {win args} {
    # Shows a window as modal.
    #   win - window's name
    #   args - attributes of window ("-name value" pairs)

    namespace upvar ::radxide dan dan
 
    variable MODALWINDOW

    set MODALWINDOW [set Modalwin $win]
    setAppIcon $win
    lassign [extractOptions args -centerme {} -ontop 0 -modal yes -minsize {} \
      -themed {} -input 0 -variable {} -waitvar {} -transient {-} -root {} -parent {}] \
      centerme ontop modal minsize themed input varname waitvar transient root parent
    $win configure -bg $dan(BG)  ;# removes blinking by default bg
    #if {$themed in {{} {0}} && [my csCurrent] != [apave::cs_Non]} {
    #  my colorWindow $win
    #}
    if {$centerme eq {}} {
      # obsolete options: -root, -parent
      if {$root ne {}} {set centerme $root} {set centerme $parent}
    }
    set root [winfo parent $win]
    set rooted 1
    if {$centerme ne {}} {
      ;# forced centering relative to a caller's window
      lassign [split $centerme x+] rw rh rx ry
      set rooted [expr {![regexp {[+|-]+\d+\++} $centerme]}]
      if {$rooted && [winfo exist $centerme]} {
        set root $centerme
      }
    }
    set decor [expr {$root in {{} .}}]
    foreach {o v} [list -decor $decor -focus {} -onclose {} -geometry {} \
    -resizable {} -ontop 0 -escape 1 -checkgeometry 1] {
      lappend defargs $o [getShowOption $o $v]
    }
    if {$varname ne {}} {
      set waitvar 1
    } else {
      set waitvar [string is true $waitvar]  ;# default 1: wait for closing the window
      set varname [WinVarname $win]
    }
    array set opt [list {*}$defargs {*}$args]
    if {$ontop eq {}} {
      if {$opt(-ontop)} {
        set ontop yes
      } else {
        set ontop no
        catch {
          set ontop [wm attributes [winfo parent $win] -topmost]
        }
        if {!$ontop} {
          # find if a window child of "." is topmost
          # if so, let this one be topmost too
          foreach w [winfo children .] {
            catch {set ontop [wm attributes $w -topmost]}
            if {$ontop} break
          }
        }
      }
    }
    if {$rooted} {
      lassign [splitGeometry [wm geometry [winfo toplevel $root]]] rw rh rx ry
    }
    if {$transient ne {-}} {
      wm transient $win $transient
    } elseif {!$opt(-decor)} {
      wm transient $win $root
    }
    if {[set destroy [expr {$opt(-onclose) eq {destroy}}]]} {
      set opt(-onclose) {}
    }
    if {$opt(-onclose) eq {}} {
      set opt(-onclose) "set $varname 0"
    } else {
      set opt(-onclose) "$opt(-onclose) $varname"  ;# $opt(-onclose) is a command
    }
    #if {$destroy} {append opt(-onclose) " ; destroy $win"}    
    if {$destroy} {append opt(-onclose) " ; destroy $win"}
    if {$opt(-resizable) ne {}} {
      if {[string is boolean $opt(-resizable)]} {
        set opt(-resizable) "$opt(-resizable) $opt(-resizable)"
      }
      wm resizable $win {*}$opt(-resizable)
    }
    if {!($modal || $waitvar)} {
      append opt(-onclose) "; CleanUps $win"
    }
    wm protocol $win WM_DELETE_WINDOW $opt(-onclose)
    # get the window's geometry from its requested sizes
    set inpgeom $opt(-geometry)
    if {$inpgeom eq {}} {
      # this is for less blinking:
      set opt(-geometry) [centeredXY $win $rw $rh $rx $ry \
        [winfo reqwidth $win] [winfo reqheight $win]]
    } elseif {[string first pointer $inpgeom]==0} {
      lassign [split $inpgeom+0+0 +] -> x y
      set inpgeom +[expr {$x+[winfo pointerx .]}]+[expr {$y+[winfo pointery .]}]
      set opt(-geometry) $inpgeom
    } elseif {[string first root $inpgeom]==0} {
      set root .[string trimleft [string range $inpgeom 5 end] .]
      set opt(-geometry) [set inpgeom {}]
    }
    if {$opt(-geometry) ne {}} {
      lassign [splitGeometry $opt(-geometry) {} {}] - - x y
      if {$x ne {}} {wm geometry $win $x$y}
    }
    if {$opt(-focus) eq {}} {
      set opt(-focus) $win
    }
    set $varname {-}
    if {$opt(-escape)} {bind $win <Escape> $opt(-onclose)}
    update
    if {![winfo exists $win]} {
      return 0 ;# looks idiotic, yet possible at sporadic calls
    }
    set w [winfo reqwidth $win]
    set h [winfo reqheight $win]
    if {$inpgeom eq {}} {  ;# final geometrizing with actual sizes
      set geo [centeredXY $win $rw $rh $rx $ry $w $h]
      set y [lindex [split $geo +] end]
      if {!$rooted || $root ne {.} && (($h/2-$ry-$rh/2)>30 || [::radxide::iswindows] && $y>0)} {
        # ::tk::PlaceWindow needs correcting in rare cases, namely:
        # when 'root' is of less sizes than 'win' and at screen top
        wm geometry $win $geo
      } else {
        ::tk::PlaceWindow $win widget $root
      }
    } else {
      lassign [splitGeometry $inpgeom {} {}] - - x y
      if {$x ne {} && $y ne {} && [string first x $inpgeom]<0 && $opt(-checkgeometry)} {
        set inpgeom [checkXY $win $w $h $x $y]
      } elseif {$x eq {} && $y eq {} && $centerme ne {} && $opt(-geometry) ne {}} {
        lassign [split $opt(-geometry) x+] w h
        lassign [split [centeredXY $win $rw $rh $rx $ry $w $h] +] -> x y
        set inpgeom ${w}x$h+$x+$y
      }
      wm geometry $win $inpgeom
    }
    after 50 [list if "\[winfo exist $opt(-focus)\]" "focus -force $opt(-focus)"]
    #if {[info exists ::transpops::my::cntwait]} {
    #  # this specific bind - for transpops package (to hide a demo message by keys)
    #  bind $win <Control-Alt-0> {set ::transpops::my::cntwait 0}
    #}
    showWindow $win $modal $ontop $varname $minsize $waitvar
    set res 0
    #catch {
      if {$modal || $waitvar} {CleanUps $win}
      if {[winfo exists $win]} {
        if {$input} {GetOutputValues}
        set res [set [set _ $varname]]
      }
    #}
    return $res
  }

# ________________________ showWindow _________________________ #


  proc showWindow {win modal ontop {var ""} {minsize ""} {waitvar 1}} {
    # Displays a windows and goes in tkwait cycle to interact with a user.
    #   win - the window's path
    #   modal - yes at showing the window as modal
    #   ontop - yes at showing the window as topmost
    #   var - variable's name to receive a result (tkwait's variable)
    #   minsize - list {minwidth minheight} or {}
    #   waitvar - if yes, force tkwait variable (mostly for non-modal windows)

    InfoWindow [expr {[InfoWindow] + 1}] $win $modal $var yes
    #::apave::deiconify $win
    if {$minsize eq {}} {
      set minsize [list [winfo width $win] [winfo height $win]]
    }
    wm minsize $win {*}$minsize
    bind $win <Configure> "[namespace current]::WinResize $win"
    if {$ontop} {wm attributes $win -topmost 1}
    if {$modal} {
      # modal window:
      waitWinVar $win $var $modal
      InfoWindow [expr {[InfoWindow] - 1}] $win $modal $var
    } else {
      # non-modal window:
      if {[set wgr [grab current]] ne {}} {
        # otherwise the non-modal window is irresponsive (in Windows even at WM level):
        grab release $wgr
      }
      if {$waitvar && $var ne {}} {
        waitWinVar $win $var $modal ;# show and wait for closing the window
      }
    }
  }

# ________________________ setShowOption _________________________ #

  proc setShowOption {name args} {
    # Sets / gets a default show option, used in showModal.
    #   name - name of option
    #   args - value of option
    # See also: showModal

    setProperty [ShowOption $name] {*}$args
  }

# ________________________ setProperty _________________________ #


	proc setProperty {name args} {
		# Sets a property's value as "application-wide".
		#   name - name of property
		#   args - value of property
		# If *args* is omitted, the method returns a property's value.
		# If *args* is set, the method sets a property's value as $args.

		variable _AP_Properties
		switch -exact [llength $args] {
		  0 {return [getProperty $name]}
		  1 {return [set _AP_Properties($name) [lindex $args 0]]}
		}
		puts -nonewline stderr \
		  "Wrong # args: should be \"::win::setProperty propertyname ?value?\""
		return -code error
	}

# ________________________ ShowOption _________________________ #


  proc ShowOption {name} {
    # Gets a default show option, used in showModal.
    #   name - name of option
    # See also: getShowOption, setShowOption

    return "_SHOWMODAL_$name"
  }

# ________________________ SpanConfig _________________________ #

  proc SpanConfig {w rcnam rc rcspan opt val} {
    # The method is used by *GetIntOptions* method to configure
    # row/column for their *span* options.

    for {set i $rc} {$i < ($rc + $rcspan)} {incr i} {
      eval [grid ${rcnam}configure $w $i $opt $val]
    }
    return
  }

# ________________________ splitGeometry _________________________ #


	proc splitGeometry {geom {X +0} {Y +0}} {
		# Gets widget's geometry components.
		#   geom - geometry
		#   X - default X-coordinate
		#   Y - default Y-coordinate
		# Returns a list of width, height, X and Y (coordinates are always with + or -).

		lassign [split $geom x+-] w h
		lassign [regexp -inline -all {([+-][[:digit:]]+)} $geom] -> x y
		if {$geom ne {}} {
		  if {$x in {"" 0} || [catch {expr {$x+0}}]} {set x $X}
		  if {$y in {"" 0} || [catch {expr {$y+0}}]} {set y $Y}
		}
		return [list $w $h $x $y]
	}

# ________________________ textChanConfigure _________________________ #


	proc textChanConfigure {channel {coding {}} {eol {}}} {
		# Configures a channel for text file.
		#   channel - the channel
		#   coding - if set, defines encoding of the file
		#   eol - if set, defines EOL of the file

		if {$coding eq {}} {
		  chan configure $channel -encoding utf-8
		} else {
		  chan configure $channel -encoding $coding
		}
		if {$eol eq {}} {
		  chan configure $channel {*}[textEOL translation]
		} else {
		  chan configure $channel -translation $eol
		}
	}

# ________________________ textEOL _________________________ #


	proc textEOL {{EOL "-"}} {
		# Gets/sets End-of-Line for text reqding/writing.
		#   EOL - LF, CR, CRLF or {}
		# If EOL omitted or equals to {} or "-", return the current EOL.
		# If EOL equals to "translation", return -translation option or {}.

		variable _PU_opts
		if {$EOL eq "-"} {return $_PU_opts(_EOL_)}
		if {$EOL eq "translation"} {
		  if {$_PU_opts(_EOL_) eq ""} {return ""}
		  return "-translation $_PU_opts(_EOL_)"
		}
		set _PU_opts(_EOL_) [string trim [string tolower $EOL]]
	}

# ________________________ TreSelect _________________________ #


	proc TreSelect {w idx} {
		# Selects a treeview item.
		#   w - treeview's path
		#   idx - item index

		set items [$w children {}]
		catch {
		  set it [lindex $items $idx]
		  $w see $it
		  $w focus $it
		  $w selection set $it  ;# generates <<TreeviewSelect>>
		}
	}

# ________________________ varName _________________________ #


  proc varName {wname} {
    # Gets a variable name associated with a widget's name of "input" dialogue.
    #   wname - widget's name

    return [namespace current]::var$wname
  }
	
# ________________________ waitWinVar _________________________ #


	proc waitWinVar {win var modal} {
		# Tk waiting for variable's change.
		#   win - the window's path
		#   var - variable's name to receive a result (tkwait's variable)
		#   modal - yes at showing the window as modal

		# first of all, wait till the window be visible
		after 1 ;# solves an issue with doubleclicking buttons
		if {![winfo viewable $win]} {
		  tkwait visibility $win
		}
		set wmain [winfo parent $win]
		if {$modal} {      ;# for modal, grab the window
		  set wgr [grab current]
		  if {$wmain ne {} && $wmain ne $win} {
		    if {[catch {grab set $win} e]} {
		      catch {tkwait visibility $win}  ;# 2nd attempt to get the window visible, by force
		      catch {grab set $win}           ;# (not sure, where it can fire, still let it be)
		      puts stderr "\n::radxide::win::waitWinVar - please send a note to apave developers on this catch. Error: $e"
		      catch {puts stderr "::radxide::win::waitWinVar - [info level -1]\n"}
		    }
		  }
		}
		# at need, wait till the window associated variable be changed
		if {$var ne {}} {
		  tkwait variable $var
		}
		if {$modal} {      ;# for modal, release the grab and restore the old one
		  catch {grab release $win}
		  if {$wgr ne {}} {
		    catch {grab set $wgr}
		  }
		}
	}

# ________________________ widgetType _________________________ #


  proc widgetType {wnamefull options attrs} {
    # Gets the widget type based on 3 initial letters of its name. Also
    # fills the grid/pack options and attributes of the widget.
    #   wnamefull - path to the widget
    #   options - grid/pack options of the widget
    #   attrs - attribute of the widget
    # Returns a list of items:
    #   widget - Tk/Ttk widget name
    #   options - grid/pack options of the widget
    #   attrs - attribute of the widget
    #   nam3 - 3 initial letters of widget's name
    #   disabled - flag of *disabled* state

    set disabled [expr {[getOption -state {*}$attrs] eq {disabled}}]
    set pack $options
    set name [ownWName $wnamefull]
    #if {[info exists ::apave::_AP_VARS(ProSplash,type)] && \
    #$::apave::_AP_VARS(ProSplash,type) eq {}} {
    #  set val [my progress_Go [incr ::apave::_AP_VARS(ProSplash,curvalue)] {} $name]
    #}
    set nam3 [string tolower [string index $name 0]][string range $name 1 2]
    if {[string index $nam3 1] eq "_"} {set k [string range $nam3 0 1]} {set k $nam3}
    lassign [defaultATTRS $k] defopts defattrs newtype
    set options "$defopts $options"
    set attrs "$defattrs $attrs"
    switch -glob -- $nam3 {
      #bts {
      #  set widget ttk::frame
      #  if {![info exists ::bartabs::NewBarID]} {package require bartabs}
      #  set attrs "-bartabs {$attrs}"
      #}
      but {
        set widget ttk::button
        AddButtonIcon $name attrs
      }
      buT - btT {
        set widget button
        AddButtonIcon $name attrs
      }
      can {set widget canvas}
      chb {set widget ttk::checkbutton}
      swi {
        set widget ttk::checkbutton
        #if {![my apaveTheme]} {
        #  set attrs "$attrs -style Switch.TCheckbutton"
        #}
      }
      chB {set widget checkbutton}
      cbx - fco {
        set widget ttk::combobox
        if {$nam3 eq {fco}} {  ;# file content combobox
          set attrs [FCfieldValues $wnamefull $attrs]
        }
        set attrs [FCfieldAttrs $wnamefull $attrs -tvar]
      }
      ent {set widget ttk::entry}
      enT {set widget entry}
      fil - fiL -
      fis - fiS -
      dir - diR -
      fon - foN -
      clr - clR -
      dat - daT -
      sta -
      too -
      fra {
        # + frame for choosers and bars
        set widget ttk::frame
      }
      frA {
        set widget frame
        if {$disabled} {set attrs [removeOptions $attrs -state]}
      }
      ftx {set widget ttk::labelframe}
      gut {set widget canvas}
      lab {
        set widget ttk::label
        if {$disabled} {
          set grey lightgray
          set attrs "-foreground $grey $attrs"
        }
        lassign [parseOptions $attrs -link {} -style {} -font {}] \
          cmd style font
        if {$cmd ne {}} {
          set attrs "-linkcom {$cmd} $attrs"
          set attrs [removeOptions $attrs -link]
        }
        if {$style eq {} && $font eq {}} {
          set attrs "-font {$::radxide::dan(CHARFAMILY)} $attrs"
        } elseif {$style ne {}} {
          # some themes stumble at ttk styles, so bring their attrs directly
          set attrs [removeOptions $attrs -style]
          set attrs "[ttk::style configure $style] $attrs"
        }
      }
      laB {set widget label}
      lfr {set widget ttk::labelframe}
      lfR {
        set widget labelframe
        if {$disabled} {set attrs [removeOptions $attrs -state]}
      }
      lbx - flb {
        set widget listbox
        if {$nam3 eq {flb}} {  ;# file content listbox
          set attrs [FCfieldValues $wnamefull $attrs]
        }
        set attrs "[FCfieldAttrs $wnamefull $attrs -lvar]"
        set attrs "[ListboxesAttrs $wnamefull $attrs]"
        AddPopupAttr $wnamefull attrs -entrypop 1
        foreach {ev com} {Home {LbxSelect %w 0} End {LbxSelect %w end}} {
          append attrs " -bindEC {<$ev> {$com}} "
        }
      }
      meb {set widget ttk::menubutton}
      meB {set widget menubutton}
      nbk {
        set widget ttk::notebook
        set attrs "-notebazook {$attrs}"
      }
      opc {
        # tk_optionCascade - example of "my method" widget
        # arguments: vname items mbopts precom args
        #set widget {tk_optionCascade}
        #set imax [expr {min(4,[llength $attrs])}]
        #for {set i 0} {$i<$imax} {incr i} {
        #  set atr [lindex $attrs $i]
        #  if {$i!=1} {
        #    lset attrs $i \{$atr\}
        #  } elseif {[llength $atr]==1 && [info exist $atr]} {
        #    lset attrs $i [set $atr]  ;# items stored in a variable
        #  }
        #}
      }
      pan {set widget ttk::panedwindow
        if {[string first -w $attrs]>-1 && [string first -h $attrs]>-1} {
          # important for panes with fixed (customized) dimensions
          set attrs "-propagate {$options} $attrs"
        }
      }
      pro {set widget ttk::progressbar}
      rad {set widget ttk::radiobutton}
      raD {set widget radiobutton}
      sca {set widget ttk::scale}
      scA {set widget scale}
      sbh {set widget ttk::scrollbar}
      sbH {set widget scrollbar}
      sbv {set widget ttk::scrollbar}
      sbV {set widget scrollbar}
      scf {
      #  if {![namespace exists ::apave::sframe]} {
      #    namespace eval ::apave {
      #      source [file join $::apave::apaveDir sframe.tcl]
      #    }
      #  }
      #  # scrolledFrame - example of "my method" widget
      #  set widget {my scrolledFrame}
      }
      seh {set widget ttk::separator}
      sev {set widget ttk::separator}
      siz {set widget ttk::sizegrip}
      spx - spX {
        if {$nam3 eq {spx}} {set widget ttk::spinbox} {set widget spinbox}
        lassign [::apave::parseOptions $attrs \
          -command {} -com {} -from {} -to {}] cmd cmd2 from to
        append cmd $cmd2
        lassign [::apave::extractOptions attrs -tip {} -tooltip {}] t1 t2
        set t2 "$t1$t2"
        if {$from ne {} || $to ne {}} {
          if {$t2 ne {}} {set t2 "\n $t2"}
          set t2 " $from .. $to $t2"
        }
        if {$t2 ne {}} {set t2 "-tip {$t2}"}
        append attrs " -onReturn {$UFF{$cmd} {$from} {$to}$UFF} $t2"
      }
      tbl { ;# tablelist
        package require tablelist
        set widget tablelist::tablelist
        set attrs "[FCfieldAttrs $wnamefull $attrs -lvar]"
        set attrs "[ListboxesAttrs $wnamefull $attrs]"
      }
      tex {set widget text
        if {[getOption -textpop {*}$attrs] eq {}} {
          AddPopupAttr $wnamefull attrs -textpop \
            [expr {[getOption -rotext {*}$attrs] ne {}}] -- disabled
        }
        lassign [parseOptions $attrs -ro {} -readonly {} -rotext {} \
          -gutter {} -gutterwidth 5 -guttershift 6] r1 r2 r3 g1 g2 g3
        set b1 [expr [string is boolean -strict $r1]]
        set b2 [expr [string is boolean -strict $r2]]
        if {($b1 && $r1) || ($b2 && $r2) || \
        ($r3 ne {} && !($b1 && !$r1) && !($b2 && !$r2))} {
          set attrs "-takefocus 0 $attrs"
        }
        set attrs [removeOptions $attrs -gutter -gutterwidth -guttershift]
        if {$g1 ne {}} {
          set attrs "$attrs -gutter {-canvas $g1 -width $g2 -shift $g3}"
        }
      }
      tre {
        set widget ttk::treeview
        foreach {ev com} {Home {TreSelect %w 0} End {TreSelect %w end}} {
          append attrs " -bindEC {<$ev> {$com}} "
        }
      }
      h_* {set widget ttk::frame}
      v_* {set widget ttk::frame}
      default {set widget $newtype}
    }
    #set attrs [GetMC $attrs]
    if {$nam3 in {cbx ent enT fco spx spX}} {
      # entry-like widgets need their popup menu
      set clearcom [lindex [parseOptions $attrs -clearcom -] 0]
      if {$clearcom eq {-}} {
        AddPopupAttr $wnamefull attrs -entrypop 0 readonly disabled
      }
    }
    if {[string first pack [string trimleft $pack]]==0} {
      catch {
        # try to expand -after option (if set as WidgetName instead widgetName)
        if {[set i [lsearch -exact $pack {-after}]]>=0} {
          set aft [lindex $pack [incr i]]
          if {[regexp {^[A-Z]} $aft]} {
            set aft [my $aft]
            set pack [lreplace $pack $i $i $aft]
          }
        }
      }
      set options $pack
    }
    set options [string trim $options]
    set attrs   [list {*}$attrs]
    return [list $widget $options $attrs $nam3 $disabled]
  }


# ________________________ WidgetNameFull _________________________ #


  proc WidgetNameFull {w name {an {}}} {
    # Gets a full name of a widget.
    #   w - name of root widget
    #   name - name of widget
    #   an - additional prefix for name
    # See also: apave::sframe::content

    set wn [string trim [parentWName $name].$an[ownWName $name] .]
    set wnamefull $w.$wn
    set wcc canvas.container.content ;# sframe.tcl may be not sourced
    if {[set i1 [string first .scf $wnamefull]]>0 && \
    [set i2 [string first . $wnamefull $i1+1]]>0 && \
    [string first .$wcc. $wnamefull]<0} {
      # insert a container's name into a scrolled frame's child
      set wend [string range $wnamefull $i2 end]
      set wnamefull [string range $wnamefull 0 $i2]
      append wnamefull $wcc $wend
    }
    return $wnamefull
  }

# ________________________ Window _________________________ #

  proc Window {w inplists} {
    # Paves the window with widgets.
    #   w - window's name (path)
    #   inplists - list of widget items (lists of widget data)
    # Contents of a widget's item:
    #   name - widget's name (first 3 characters define its type)
    #   neighbor - top (T) or left (L) neighbor of the widget
    #   posofnei - position of neighbor: T (top) or L (left)
    #   rowspan - row span of the widget
    #   colspan - column span of the widget
    #   options - grid/pack options
    #   attrs - attributes of widget
    # First 3 items are mandatory, others are set at need.
    # Called by *paveWindow* method to process a portion of widgets.
    # The "portion" refers to a separate block of widgets such as
    # notebook's tabs or frames.

    namespace upvar ::radxide dan dan 

    #tk_messageBox -title $dan(TITLE) -icon info -message "Start Window!"

    set lwidgets [list]
    # comments be skipped
    foreach lst $inplists {
      if {[string index $lst 0] ne {#}} {
        lappend lwidgets $lst
      }
    }
    set lused [list]
    set lwlen [llength $lwidgets]
    if {$lwlen<2 && [string trim $lwidgets "{} "] eq {}} {
      set lwidgets [list {fra - - - - {pack -padx 99 -pady 99}}]
      set lwlen 1
    }
    for {set i 0} {$i < $lwlen} {} {
      set lst1 [lindex $lwidgets $i]
      if {[Replace_Tcl i lwlen lwidgets {*}$lst1] ne {}} {incr i}
    }
    # firstly, normalize all names that are "subwidgets" (.lab for fra.lab)
    # also, "+" for previous neighbors
    set i [set lwlen [llength $lwidgets]]
    while {$i>1} {
      incr i -1
      set lst1 [lindex $lwidgets $i]
      lassign $lst1 name neighbor
      if {$neighbor eq {+}} {set neighbor [lindex $lwidgets $i-1 0]}
      lassign [NormalizeName name i lwidgets] name wname
      set neighbor [lindex [NormalizeName neighbor i lwidgets] 0]
      set lst1 [lreplace $lst1 0 1 $wname $neighbor]
      set lwidgets [lreplace $lwidgets $i $i $lst1]
    }
    for {set i 0} {$i < $lwlen} {} {
      # List of widgets contains data per widget:
      #   widget's name,
      #   neighbor widget, position of neighbor (T, L),
      #   widget's rowspan and columnspan (both optional),
      #   grid options, widget's attributes (both optional)
      set lst1 [lindex $lwidgets $i]
      #set lst1 [my Replace_chooser w i lwlen lwidgets {*}$lst1]
      #if {[set lst1 [my Replace_bar w i lwlen lwidgets {*}$lst1]] eq {}} {
      #  incr i
      #  continue
      #}
      lassign $lst1 name neighbor posofnei rowspan colspan options1 attrs1
      lassign [NormalizeName name i lwidgets] name wname
      set wname [MakeWidgetName $w $wname]
      if {$colspan eq {} || $colspan eq {-}} {
        set colspan 1
        if {$rowspan eq {} || $rowspan eq {-}} {
          set rowspan 1
        }
      }
      foreach ao {attrs options} {
        if {[catch {set $ao [uplevel 2 subst -nocommand -nobackslashes [list [set ${ao}1]]]}]} {
          set $ao [set ${ao}1]
        }
      }
      lassign [widgetType $wname $options $attrs] widget options attrs nam3 dsbl
      # The type of widget (if defined) means its creation
      # (if not defined, it was created after "makewindow" call
      # and before "window" call)
      if { !($widget eq {} || [winfo exists $widget])} {
        set attrs [GetAttrs $attrs $nam3 $dsbl]
        set attrs [ExpandOptions $attrs]
        # for scrollbars - set up the scrolling commands
        if {$widget in {ttk::scrollbar scrollbar}} {
          set neighbor [lindex [LowercaseWidgetName $neighbor] 0]
          set wneigb [WidgetNameFull $w $neighbor]
          if {$posofnei eq {L}} {
            $wneigb config -yscrollcommand "$wname set"
            set attrs "$attrs -com \\\{$wneigb yview\\\}"
            append options { -side right -fill y} ;# -after $wneigb"
          } elseif {$posofnei eq {T}} {
            $wneigb config -xscrollcommand "$wname set"
            set attrs "$attrs -com \\\{$wneigb xview\\\}"
            append options { -side bottom -fill x} ;# -before $wneigb"
          }
          set options [string map [list %w $wneigb] $options]
        }
        #% doctest 1
        #%   set a "123 \\\\\\\\ 45"
        #%   eval append b {*}$a
        #%   set b
        #>   123\45
        #> doctest
        Pre attrs
        #set addcomms [my AdditionalCommands $w $wname attrs]
        eval $widget $wname {*}$attrs
        #my Post $wname $attrs
        #foreach acm $addcomms {{*}$acm}
        # for buttons and entries - set up the hotkeys (Up/Down etc.)
        #my DefineWidgetKeys $wname $widget
      }
      if {$neighbor eq {-} || $row < 0} {
        set row [set col 0]
      }
      # check for simple creation of widget (without pack/grid)
      if {$neighbor ne {#}} {
        set options [GetIntOptions $w $options $row $rowspan $col $colspan]
        set pack [string trim $options]
        if {[string first add $pack]==0} {
          set comm "[winfo parent $wname] add $wname [string range $pack 4 end]"
          {*}$comm
        } elseif {[string first pack $pack]==0} {
          set opts [string trim [string range $pack 5 end]]
          if {[string first forget $opts]==0} {
            pack forget {*}[string range $opts 6 end]
          } else {
            pack $wname {*}$opts
          }
        } else {
          grid $wname -row $row -column $col -rowspan $rowspan \
             -columnspan $colspan -padx 1 -pady 1 {*}$options
        }
      }
      lappend lused [list $name $row $col $rowspan $colspan]
      if {[incr i] < $lwlen} {
        lassign [lindex $lwidgets $i] name neighbor posofnei
        set neighbor [lindex [LowercaseWidgetName $neighbor] 0]
        set row -1
        foreach cell $lused {
          lassign $cell uname urow ucol urowspan ucolspan
          if {[lindex [LowercaseWidgetName $uname] 0] eq $neighbor} {
            set col $ucol
            set row $urow
            if {$posofnei eq {T} || $posofnei eq {}} {
              incr row $urowspan
            } elseif {$posofnei eq {L}} {
              incr col $ucolspan
            }
          }
        }
      }
    }
    return $lwidgets
  }

# ________________________ WindowStatus _________________________ #


  proc WindowStatus {w name {val ""} {defval ""}} {
    # Sets/gets a status of window. The status is a value assigned to a name.
    #   w - window's path
    #   name - name of status
    #   val - if blank, to get a value of status; otherwise a value to set
    #   defval - default value (actual if the status not set beforehand)
    # Returns a value of status.
    # See also: IntStatus

    variable _AP_VARS
    if {$val eq {}} {  ;# getting
      if {[info exist _AP_VARS($w,$name)]} {
        return $_AP_VARS($w,$name)
      }
      return $defval
    }
    return [set _AP_VARS($w,$name) $val]  ;# setting
  }

# ________________________ WinResize _________________________ #


  proc WinResize {win} {
    # Restricts the window's sizes (thus fixing Tk's issue with a menubar)
    #   win - path to a window to be of restricted sizes

    if {[$win cget -menu] ne {}} {
      lassign [splitGeometry [wm geometry $win]] w h
      lassign [wm minsize $win] wmin hmin
      if {$w<$wmin && $h<$hmin} {
        set corrgeom ${wmin}x$hmin
      } elseif {$w<$wmin} {
        set corrgeom ${wmin}x$h
      } elseif {$h<$hmin} {
        set corrgeom ${w}x$hmin
      } else {
        return
      }
      wm geometry $win $corrgeom
    }
    return
 }

# ________________________ WinVarname _________________________ #


  proc WinVarname {win} {
    # Gets a unique varname for a window.
    #   win - window's path

    return [namespace current]::PV(_WIN_,$win)
  }

# ________________________ withdraw _________________________ #


	proc withdraw {w} {
		# Does 'withdraw' for a window.
		#   w - the window's path
		# See also: iconifyOption

		switch -- [iconifyOption] {
		  none {          ; # no withdraw/deiconify actions
		  }
		  Linux {         ; # do it for Linux
		    wm withdraw $w
		  }
		  Windows {       ; # do it for Windows
		    wm withdraw $w
		    wm attributes $w -alpha 0.0
		  }
		  default {       ; # do it depending on the platform
		    wm withdraw $w
		    if {[::radxide::iswindows]} {
		      wm attributes $w -alpha 0.0
		    }
		  }
		}
	}

# ________________________ #

}

