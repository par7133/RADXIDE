###########################################################
# Name:    edit.tcl
# Author:  Daniele Bonini  (posta@elettronica.lol)
# Date:    27/11/2023
# Desc:    Edit Menu namespace of RadXIDE.
#
#          Edit Menu namespace scaffolding and most of the code 
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

namespace eval edit {

# ________________________ find _________________________ #

	proc find {} {
    # Open the Find window to start a text search

    namespace upvar ::radxide dan dan project project

    set t $dan(TEXT)
    set args {}

		if {$project(CUR_FILE_PATH) ne {}} {

      #tk_textCopy $t
      #catch {clipboard get} clipcontent

		  #set sel $clipcontent
		  
      set sel [::radxide::win::InitFindInText 0 $t]
		  
		  #tk_messageBox -title $dan(TITLE) -icon info -message $sel
		  
		  set args "-buttons {butSearch SEARCH ::radxide::win::findTextOK butCANCEL CANCEL ::radxide::win::findTextCancel}"
		     
		  catch {lassign [::radxide::win::input "Find" {} "Find text" [list \
		    ent "{} {} {-w 64}" "{$sel}"] \
		    -head "Search for:" {*}$args] res}
    }
	}

# ________________________ GotoLine _________________________ #


	proc GotoLine {} {
    # Open the Go To Line window

    namespace upvar ::radxide dan dan project project

    set t $dan(TEXT)
    set args {}
    set ln 1

		if {$project(CUR_FILE_PATH) ne {}} {

		  #tk_messageBox -title $dan(TITLE) -icon info -message "Go To Line"
		  
		  set args "-buttons {butGo GO ::radxide::win::GotoLineOK butCANCEL CANCEL ::radxide::win::GotoLineCancel}"
		     
		  catch {lassign [::radxide::win::input "GotoLine" {} "Go to Line" [list \
		    ent "{} {} {-w 28}" "{$ln}"] \
		    -head "Go to line:" {*}$args] res}
    }
	}

# ________________________ Indent _________________________ #


	proc Indent {{from "event"}} {
		# Indent selected lines of text.

		namespace upvar ::radxide dan dan

		set indent $dan(TAB_IN_SPACE)
		set len [string length $dan(TAB_IN_SPACE)]
		set sels [SelectedLines]
		set wtxt [lindex $sels 0]
		#::apave::undoIn $wtxt
		foreach {l1 l2} [lrange $sels 1 end] {
		  for {set l $l1} {$l<=$l2} {incr l} {
		    set line [$wtxt get $l.0 $l.end]
		    if {[string trim $line] eq {}} {
		      $wtxt replace $l.0 $l.end {}
		    } else {
		      set leadsp [leadingSpaces $line]
		      set sp [expr {$leadsp % $len}]
		      # align by the indent edge
		      if {$sp==0} {
		        set ind $indent
		      } else {
		        set ind [string repeat " " [expr {$len - $sp}]]
		      }
		      $wtxt insert $l.0 $ind
		    }
		  }
		}
		#::apave::undoOut $wtxt
		#alited::main::HighlightLine
		
		focus $dan(TEXT)
		
		if {$from eq "event"} {
		  return -code break
		}  
	}

# ________________________ leadingSpaces _________________________ #


	proc leadingSpaces {line} {
		# Returns a number of leading spaces of a line
		#   line - the line

		return [expr {[string length $line]-[string length [string trimleft $line]]}]
	}


# ________________________ makeCopy _________________________ #


	proc makeCopy {{from "event"}} {
    # Copy from the editor to the clipboard
    #clipboard clear
    #clipboard append $txt
    
    namespace upvar ::radxide dan dan
    
    set t $dan(TEXT)
    
    tk_textCopy $t
    
    if {$from eq "event"} {
		  return -code break
		}  
	}

#_________________________ makeCut ________________________ #

	proc makeCut {{from "event"}} {
    # Cut from the editor to the clipboard
    #set canvas %W
    #eval [clipboard get -type TkCanvasItem]

    namespace upvar ::radxide dan dan
    
    set t $dan(TEXT)
    
    tk_textCut $t
    
    after 1000 "::radxide::win::fillGutter .danwin.fra.pan.fra2.text .danwin.fra.pan.fra2.gutText 5 1 #FFFFFF #222223"
    #$dan(TEXT) yview [$dan(TEXT) index insert] 
    #$dan(GUTTEXT) yview moveto [lindex [$dan(TEXT) yview] 1] 
    
    if {$from eq "event"} {
		  return -code break
		}  
	}

# ________________________ makeNewLine _________________________ #


  proc makeNewLine {} {
  
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
        
    set nspacesofindent [expr $orilength - $newlength] 
      
    # inserintg correct identation..
	  $wt insert [$wt index {insert}] \n[string repeat " " $nspacesofindent]  

	  set idx3 [$wt index insert]
	  set idx4 [$wt index "$idx3 +1 line"]
	  ::tk::TextSetCursor $wt $idx3
		  
    ::radxide::win::fillGutter .danwin.fra.pan.fra2.text .danwin.fra.pan.fra2.gutText 5 1 "#FFFFFF" "#222223"
    #$dan(TEXT) yview [$dan(TEXT) index insert] 
    #$dan(GUTTEXT) yview moveto [lindex [$dan(TEXT) yview] 1]             

    return -code break

  }
	
#_________________________ makePaste ________________________ #

	proc makePaste {{from "event"}} {
    # Paste from the clipboard to the editor
    #set canvas %W
    #eval [clipboard get -type TkCanvasItem]
    
    namespace upvar ::radxide dan dan
    
    set t $dan(TEXT)
    
    tk_textPaste $t    
    
    after 1000 "::radxide::win::fillGutter .danwin.fra.pan.fra2.text .danwin.fra.pan.fra2.gutText 5 1 #FFFFFF #222223" 
    #$dan(TEXT) yview [$dan(TEXT) index insert] 
    #$dan(GUTTEXT) yview moveto [lindex [$dan(TEXT) yview] 1] 

    if {$from eq "event"} {
		  return -code break
		}  

	}

#_________________________ makeRedo ________________________ #


	proc makeRedo {{from "event"}} {
    # Paste from the clipboard to the editor
    #set canvas %W
    #eval [clipboard get -type TkCanvasItem]
    
    namespace upvar ::radxide dan dan
    
    set t $dan(TEXT)
    
    catch {$t edit redo}
    
    after idle "::radxide::win::fillGutter .danwin.fra.pan.fra2.text .danwin.fra.pan.fra2.gutText 5 1 #FFFFFF #222223" 
    #$dan(TEXT) yview [$dan(TEXT) index insert] 
    #$dan(GUTTEXT) yview moveto [lindex [$dan(TEXT) yview] 1] 

    if {$from eq "event"} {
		  return -code break
		}  
	}

#_________________________ makeUndo ________________________ #


	proc makeUndo {{from "event"}} {
    # Paste from the clipboard to the editor
    #set canvas %W
    #eval [clipboard get -type TkCanvasItem]
    
    namespace upvar ::radxide dan dan
    
    set t $dan(TEXT)
    
    catch {$t edit undo}   
    
    after idle "::radxide::win::fillGutter .danwin.fra.pan.fra2.text .danwin.fra.pan.fra2.gutText 5 1 #FFFFFF #222223"
    #$dan(TEXT) yview [$dan(TEXT) index insert] 
    #$dan(GUTTEXT) yview moveto [lindex [$dan(TEXT) yview] 1] 
    
    if {$from eq "event"} {
		  return -code break
		}  

	}

# ________________________ SelectedLines _________________________ #


	proc SelectedLines {{wtxt ""} {strict no}} {
		# Gets a range of lines of text that are selected at least partly.
		#   wtxt - text's path
		#   strict - if yes, only a real selection is counted
		# Returns a list of the text widget's path and ranges of selected lines.

		namespace upvar ::radxide dan dan

		if {$wtxt eq {}} {set wtxt $dan(TEXT)}
		set res [list $wtxt]
		if {[catch {$wtxt tag ranges sel} sels] || ![llength $sels]} {
		  if {$strict} {
		    set sels [list]
		  } else {
		    set pos1 [set pos2 [$wtxt index insert]]
		    set sels [list $pos1 $pos2]
		  }
		}
		foreach {pos1 pos2} $sels {
		  if {$pos1 ne {}} {
		    set pos21 [$wtxt index "$pos2 linestart"]
		    if {[$wtxt get $pos21 $pos2] eq {}} {
		      set pos2 [$wtxt index "$pos2 - 1 line"]
		    }
		  }
		  set l1 [expr {int($pos1)}]
		  set l2 [expr {max($l1,int($pos2))}]
		  lappend res $l1 $l2
		}
		return $res
	}

#_________________________ setup ________________________ #


	proc setup {} {
    # Open the Options window
    
    namespace upvar ::radxide dan dan
    
    tk_messageBox -title $dan(TITLE) -icon info -message "Please check 'radxide.tcl' to customize any variable." -parent $dan(WIN)  
	}

# ________________________ UnIndent _________________________ #


	proc UnIndent {{from "event"}} {
		# Unindent selected lines of text.

		namespace upvar ::radxide dan dan

		set len [string length $dan(TAB_IN_SPACE)]
		set spaces [list { } \t]
		set sels [SelectedLines]
		set wtxt [lindex $sels 0]
		#::apave::undoIn $wtxt
		foreach {l1 l2} [lrange $sels 1 end] {
		  for {set l $l1} {$l<=$l2} {incr l} {
		    set line [$wtxt get $l.0 $l.end]
		    if {[string trim $line] eq {}} {
		      $wtxt replace $l.0 $l.end {}
		    } elseif {[string index $line 0] in $spaces} {
		      set leadsp [leadingSpaces $line]
		      # align by the indent edge
		      set sp [expr {$leadsp % $len}]
		      if {$sp==0} {set sp $len}
		      $wtxt delete $l.0 "$l.0 + ${sp}c"
		    }
		  }
		}
		#::apave::undoOut $wtxt
		
		focus $dan(TEXT)
		
		if {$from eq "event"} {
		  return -code break
		}  
	}

#_______________________

}


# _________________________________ EOF _________________________________ #
