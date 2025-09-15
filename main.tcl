###########################################################
# Name:    main.tcl
# Author:  Daniele Bonini  (code@gaox.io)
# Date:    25/11/2023
# Desc:    Main namespace of RadXIDE.
#
#          Main namespace and most of the code 
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
###########################################################


namespace eval main {

# ________________________ Main _create _________________________ #

	proc _create {} {
		# Creates the main form of radxide.

		namespace upvar ::radxide dan dan
		
		::radxide::win::makeMainWindow $dan(WIN).fra $dan(TITLE) $dan(BG) $dan(FG)

	}

# ________________________ ShowHeader _________________________ #

	proc updateAppTitle {} {
		# Displays a file's name and modification flag (*) in alited's title.

		namespace upvar ::radxide dan dan project project

    #tk_messageBox -title $dan(TITLE) -icon error -message $project(CUR_FILE_PATH)

  	set f "<no file>"
    if {$project(CUR_FILE_PATH) ne ""} {
      set f [string range $project(CUR_FILE_PATH) [expr [string length $dan(WORKDIR)]+1] end]
  	}  
  	#tk_messageBox -title $dan(TITLE) -icon error -message $f
	  set t $dan(TITLE)
	  set templ $dan(TITLE_TEMPL)
	  set ttl [string map [list %f $f %t $t] $templ]
	  wm title $dan(WIN) [string trim $ttl]

	}

# ________________________ Main _run _________________________ #

	proc _run {} {
		# Runs the alited, displaying its main form with attributes
		# 'modal', 'not closed by Esc', 'decorated with Contract/Expand buttons',
		# 'minimal sizes' and 'saved geometry'.
		#
		# After closing the alited, saves its settings (geometry etc.).

		namespace upvar ::radxide dan dan

		wm attributes $dan(WIN) -topmost
		updateAppTitle
		wm iconphoto $dan(WIN) $dan(ICONI)
		wm resizable $dan(WIN) 1 1
		::radxide::win::centerWin $dan(WIN) $dan(WIDTH) $dan(HEIGHT)
		wm minsize $dan(WIN) [expr $dan(WIDTH)-600] [expr $dan(HEIGHT)-600]
		wm maxsize $dan(WIN) [expr $dan(WIDTH)+400] [expr $dan(HEIGHT)+300]
		wm attributes $dan(WIN) -fullscreen 0
		wm protocol $dan(WIN) WM_DELETE_WINDOW { radxide::quit }
    
    catch {focus -force $dan(TEXT)}
    
    # Modal
		set var 1
		::radxide::win::waitWinVar $dan(WIN) $var 1
		# --
		
		destroy $dan(WIN)
		update
		return 1
	}

}
# _________________________________ EOF _________________________________ #
