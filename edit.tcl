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
	
# ________________________ makeCopy _________________________ #

	proc makeCopy {} {
    # Copy from the editor to the clipboard
    #clipboard clear
    #clipboard append $txt
    
    namespace upvar ::radxide dan dan
    
    set t $dan(TEXT)
    
    tk_textCopy $t
	}

#_________________________ makeCut ________________________ #

	proc makeCut {} {
    # Cut from the editor to the clipboard
    #set canvas %W
    #eval [clipboard get -type TkCanvasItem]

    namespace upvar ::radxide dan dan
    
    set t $dan(TEXT)
    
    tk_textCut $t
	}
	
#_________________________ makePaste ________________________ #

	proc makePaste {} {
    # Paste from the clipboard to the editor
    #set canvas %W
    #eval [clipboard get -type TkCanvasItem]
    
    namespace upvar ::radxide dan dan
    
    set t $dan(TEXT)
    
    tk_textPaste $t    
	}

#_________________________ setup ________________________ #

	proc setup {} {
    # Open the Options window
    
    namespace upvar ::radxide dan dan
    
    tk_messageBox -title $dan(TITLE) -icon info -message "Please check 'radxide.tcl' for any variable to customize."   
	}
	
#_______________________

}


# _________________________________ EOF _________________________________ #
