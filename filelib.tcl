###########################################################
# Name:    filelib.tcl
# Author:  Daniele Bonini  (posta@elettronica.lol)
# Date:    01/12/2023
# Desc:    Files namespace of RadXIDE.
#
#          Files namespace and most of code 
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


namespace eval filelib {

# __________________________ createFile _________________________ #


	proc createFile {{destfolder ""}} {
		# Create a file.
		#   fname - file name
		#   stxt - text to save

		namespace upvar ::radxide dan dan project project
		
		set n "newfile"
		
		#tk_messageBox -title $dan(TITLE) -icon error -message $destfolder
		
		if {$destfolder ne ""} {
		
		  #tk_messageBox -title $dan(TITLE) -icon error -message "Yess!"
		
		  set num 1
		  while {[file exists $destfolder/$n$num]} {  
		    incr num
		  }

		  #tk_messageBox -title $dan(TITLE) -icon error -message $destfolder/$n$num	
		  
		  set fname $destfolder/$n$num
		
		  set fh [open $fname {WRONLY CREAT}]
		  set stxt ""
		  puts $fh $stxt
		  close $fh		
		}
	}

# __________________________ delFile _________________________ #


	proc delFile {{fname ""}} {
		# Delete a file.
		#   fname - file name

		if {($fname ne "")} {
		
		  catch {[file delete $fname]}

		}
	}

# __________________________ openFile _________________________ #


	proc openFile {{fname ""} {reload no} {islist no} {Message {}}} {
		# Handles "Open file" menu item.
		#   fnames - file name (if not set, asks for it)
		#   reload - if yes, loads the file even if it has a "strange" extension
		#   islist - if yes, *fnames* is a file list
		#   Message - name of procedure for "open file" message
    # Return the content of the file
    
    namespace upvar ::radxide dan dan

    set ret ""

    if {$fname ne ""} {

		  if {[file size $fname] > $dan(MAXFILESIZE)} {
		    tk_messageBox -title $dan(TITLE) -icon error -message "File exceed MAXFILESIZE=$dan(MAXFILESIZE)"
		    return $ret
		  }

			set fh [open $fname {RDONLY}]
			set ret [set data [read $fh]]
			close $fh

    }
		
		return $ret
	}

# __________________________ saveFile _________________________ #


	proc saveFile {{fname ""} {stxt ""}} {
		# Saves a file.
		#   fname - file name
		#   stxt - text to save

		namespace upvar ::radxide dan dan project project
		
		if {($fname ne "") && ($stxt ne "")} {
		
		  set fh [open $fname {WRONLY CREAT}]
		  puts $fh $stxt
		  close $fh		
		}
	}
#_______________________

}

# _________________________________ EOF _________________________________ #	  
