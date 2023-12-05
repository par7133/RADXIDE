###########################################################
# Name:    edit.tcl
# Author:  Daniele Bonini  (posta@elettronica.lol)
# Date:    27/11/2023
# Desc:    Edit Menu namespace of RadXIDE.
#
#          Edit Menu namespace scaffolding and most of code 
#          here presented and distributed contain excerpts 
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

	proc find {win} {
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
		    -head "Serach for:" {*}$args] res}
    }
	}

# ________________________ makeCopy _________________________ #

	proc makeCopy {win} {
    # Copy from the textPane to the clipboard
    #clipboard clear
    #clipboard append $txt
    tk_textCopy $win
	}

#_________________________ makeCut ________________________ #

	proc makeCut {win} {
    # Cut from the textPane to the clipboard
    #set canvas %W
    #eval [clipboard get -type TkCanvasItem]
    tk_textCut $win    
	}
	
#_________________________ makePaste ________________________ #

	proc makePaste {win} {
    # Paste from the clipboard to the textPane
    #set canvas %W
    #eval [clipboard get -type TkCanvasItem]
    tk_textPaste $win    
	}

#_________________________ setup ________________________ #

	proc setup {} {
    # Open the Options window
    
    namespace upvar ::radxide dan dan
    
    tk_messageBox -title $dan(TITLE) -icon info -message "Setup!"   
	}
	
#_______________________

}


# _________________________________ EOF _________________________________ #
