###########################################################
# Name:    menu.tcl
# Author:  Daniele Bonini  (posta@elettronica.lol)
# Date:    27/11/2023
# Desc:    Menu namespace of RadXIDE.
#
#          Menu namespace and most of the code 
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

namespace eval menu {

# ________________________ MenuScaf _________________________ #

	proc menuScaf {} {
	
	  namespace upvar ::radxide dan dan menu menu

	  set aboutTEXT ""	
	  #set aboutTEXT "MIT Licence.\n\n\n" 
	  #set aboutTEXT "${aboutTEXT}Copyrights 5 Mode\n\n"
	  #set aboutTEXT "${aboutTEXT}http://5mode.com\n\n\n"
	  #set aboutTEXT "${aboutTEXT}Most of code here presented and distributed contain excerpts"
    #set aboutTEXT "${aboutTEXT}from Alited (https://github.com/aplsimple/alited"
    #set aboutTEXT "${aboutTEXT}by Alex Plotnikov and contributors to the project."
    #set aboutTEXT "${aboutTEXT}The original code of these excerpts could be" 
    #set aboutTEXT "${aboutTEXT}borrowed from other sources which the author"
    #set aboutTEXT "${aboutTEXT}and the contributors to this RadXIDE have no"
    #set aboutTEXT "${aboutTEXT}knowledge about.\n\n\n"
    #set aboutTEXT "${aboutTEXT}For other rights and copyright see each file header."
	
		# menu
		set menu(ROOT) [set m [menu .mb]]
		$m add cascade -label File -menu $m.file
		set m1 [menu $m.file -tearoff 0]
		set menu(FILE) $m1
		$m1 add command -label "New project" -command { ::radxide::menu::file::newProject } -accelerator Ctrl+N
		$m1 add command -label "Open project" -command { ::radxide::menu::file::openProject } -accelerator Ctrl+O
		$m1 add command -label "Add file" -command { ::radxide::menu::file::addFile } -accelerator Ctrl+Shift+N -state disabled
		$m1 add separator
		$m1 add command -label "Save as.." -command { ::radxide::menu::file::saveFileAs } -accelerator Ctrl+Shift+S	-state disabled
		$m1 add command -label "Save" -command { ::radxide::menu::file::saveFile } -accelerator Ctrl-S -state disabled
		$m1 add separator
		$m1 add command -label "Close" -command { ::radxide::menu::file::closeFile } -accelerator Ctrl+Shift+X -state disabled
		$m1 add command -label "Close project" -command { ::radxide::menu::file::closeProject } -accelerator Ctrl+Alt+X	-state disabled	
		$m1 add separator  	
		$m1 add command -label Exit -command { ::radxide::menu::file::quit } -accelerator Ctrl+Q
		$m add cascade -label Edit -menu $m.edit
		set m2 [menu $m.edit -tearoff 0]
		set menu(EDIT) $m2
		$m add cascade -label Help -menu $m.help
		$m2 add command -label Copy -command { ::radxide::menu::edit::makeCopy }  -accelerator Ctrl+C -state disabled
		$m2 add command -label Paste -command { ::radxide::menu::edit::makePaste } -accelerator Ctrl+P -state disabled
		$m2 add command -label Cut -command { ::radxide::menu::edit::makeCut } -accelerator Ctrl+X -state disabled
		$m2 add separator
		$m2 add command -label Find -command { ::radxide::menu::edit::find } -accelerator Ctrl+F -state disabled
		$m2 add command -label "Go to Line" -command { ::radxide::menu::edit::GotoLine } -accelerator Ctrl+G -state disabled
		$m2 add separator
		$m2 add command -label Options -command { ::radxide::menu::edit::setup } 
		set m3 [menu $m.help -tearoff 0]
		$m3 add command -label About -command { tk_messageBox -title $dan(TITLE) -icon info -message "\n\nRADXIDE ver 1.2.1\n\n\nMIT Licence.\n\n\nCopyright (c) 5 Mode\n\nThis software is provided AS-IS.\n\nAuthors:\n2023-2024 RADXIDE, Daniele Bonini\n2021-2023 Alited, Alex Plotnikov\n\nhttps://5mode.com\n\n\n"}
    return $m
	}

# ________________________ defMUShortcuts _________________________ #

	proc defWinShortcuts {ctrl canvas} {
	
	  namespace upvar ::radxide dan dan
	
 	  bind $ctrl "<Control-n>" { ::radxide::menu::file::newProject }
 	  bind $ctrl "<Control-o>" { ::radxide::menu::file::openProject }
 	  bind $ctrl "<Control-s>" { ::radxide::menu::file::saveFile }
 	  bind $ctrl "<Control-Alt-x>" { ::radxide::menu::file::closeProject }
 	  bind $ctrl "<Control-q>" { ::radxide::menu::file::quit }
 	  bind $ctrl "<Control-c>" "::radxide::menu::edit::makeCopy"
 	  bind $ctrl "<Control-p>" "::radxide::menu::edit::makePaste"
 	  bind $ctrl "<Control-x>" "::radxide::menu::edit::makeCut"
 	  bind $ctrl "<Control-f>" "::radxide::menu::edit::find"
		bind $ctrl "<Control-g>" "::radxide::menu::edit::GotoLine"
		bind $ctrl "<Return>" "::radxide::win::setNewLineWithIndent" 
		bind $ctrl "<Tab>" "::radxide::win::insertTab"
		
	}	
	
#_______________________

  source [file join . file.tcl]
  source [file join . edit.tcl]

}

# _________________________________ EOF _________________________________ #
