###########################################################
# Name:    eglib.tcl
# Author:  Daniele Bonini  (posta@elettronica.lol)
# Date:    05/12/2023
# Desc:    Code library code. 
#
#          Code Library scaffolding and most of code 
#          here presented and distributed contain excerpts 
#          from "Practical Programming in Tcl and Tk, 4th Ed."
#          by Brent B. Welch, Ken Jones, Jeffrey Hebbs.
#          The original code of these excerpts could be 
#          borrowed from other sources which the author
#          and the contributors to RadXIDE have no 
#          knowledge about.
#
# License: MIT. Copyrights 5 Mode (Last implementation and adaptations.)
#               Copyrights © 2003 Pearson Education Inc. (original excerpts.)  
#
###########################################################

namespace eval eglib {

  namespace upvar ::radxide dan dan

  set browse(list) [list]
  set browse(dir) $dan(WORKDIR)/.snippets
	set browse(curix) -1
	set browse(current) ""
	set browse(label) {}
	set browse(cookie) ""
	  
# ____________________ Scrolled_Text ____________________ #

	proc Scrolled_Text { f args } {
	# Create the text to display the example
		frame $f
		eval {text $f.text -wrap none \
		-xscrollcommand [list $f.xscroll set] \
		-yscrollcommand [list $f.yscroll set]} $args
		scrollbar $f.xscroll -orient horizontal \
		-command [list $f.text xview]
		scrollbar $f.yscroll -orient vertical \
		-command [list $f.text yview]
		grid $f.text $f.yscroll -sticky news
		grid $f.xscroll -sticky news
		grid rowconfigure $f 0 -weight 1
		grid columnconfigure $f 0 -weight 1
		return $f.text
	}
	
# ____________________ create ____________________________ #	
	  
	proc create {wframe} {
	  # Create the Code Library window
	  
	  namespace upvar ::radxide dan dan
	
	  variable browse

		#wm minsize $wframe 30 5
		#wm title $wframe "Tcl Example Browser"

		# Create a row of buttons along the top
		#set f $wframe
		set f [frame $wframe.menubar]
		pack $f -fill x; #-side left -fill both -expand 1 ;#-fill x
		
		# Create the menubutton and menu
		menubutton $f.ex -text Snippets -menu $f.ex.m
		pack $f.ex -side left
		set m [menu $f.ex.m]		

		button $f.next -text Next -command ::radxide::eglib::Next
		button $f.prev -text Previous -command ::radxide::eglib::Previous

		# The Run and Reset buttons use EvalEcho that
		# is defined by the Tcl shell in Example 24–4 on page 389
		button $f.load -text Copy -command ::radxide::eglib::Copy ;#-state disabled
		button $f.reset -text Reset -command ::radxide::eglib::Reset

		# A label identifies the current example
		set browse(label) [set l [label $f.label]]

		pack $f.reset $f.load $f.next $f.prev $l -side left

		set browse(text) [Scrolled_Text $wframe.body \
			-width 40 -height 10\
			-setgrid false]
		pack $wframe.body -side left -expand 1 -fill both -anchor nw ;#-fill both -expand true	
	
		# Look through the example files for their ID number.
		catch {
				foreach fpath [lsort -dictionary [glob [file join $browse(dir) *]]] {
				if [catch {open $fpath} in] {
					puts stderr "Cannot open $f: $in"
					continue
				}
					set ex [expr 0]
					while {[gets $in line] >= 0} {
						#if [regexp {^# Example ([0-9]+)-([0-9]+)} $line x chap ex] {
							#regexp {^\/\/\w+} $line x
							set fname [file tail $fpath]
							set chap [string range $fname [expr [string first \[ $fname]+1] [expr [string last \] $fname]-1]]
							if {[string length $chap] <=1} {
								set chap "Various"
							}
							set ex [incr $ex]
							lappend snippets($chap) $ex
							lappend browse(list) $fpath
							# Read example title
							#gets $in line
							set title($chap-$ex) [string trim $line "# "]
							#tk_messageBox -title radxide -icon error -message $title($chap-$ex)
							set file($chap-$ex) $fpath
							close $in
							break
						#}
					}
				}
		}		
		

		# Create two levels of cascaded menus.
		# The first level divides up the chapters into chunks.
		# The second level has an entry for each example.
		option add *Menu.tearOff 0
		set limit 8
		set c 0; set i 0
		foreach chap [lsort [array names snippets]] {
			$m add cascade -label "$chap..." \
			-menu $m.$c
			set sub1(chap) [menu $m.$c]
			incr c
			
			set i [expr ($i +1) % $limit]
			foreach ex [lsort $snippets($chap)] {
				$sub1(chap) add command -label $title($chap-$ex) \
					-command [list ::radxide::eglib::Browse $file($chap-$ex)]	
			}
		}
  }
  
# ___________________ Browse ____________________ #  
  	
	proc Browse { file } {
	# Display a specified file. The label is updated to
	# reflect what is displayed, and the text is left
	# in a read-only mode after the example is inserted.
		variable browse
		# update the descriptive label with the filename
		#$browse(label) configure -text [set browse(current) [file tail $file]]
		set t $browse(text)
		$t config -state normal
		$t delete 1.0 end
		if [catch {open $file} in] {
			$t insert end $in
		} else {
			$t insert end [set browse(cookie) [read $in]]
			close $in
		}
		#$t config -state disabled
	}

# ___________________ Next ____________________ #  

	proc Next {} {
	# Browse the next files in the list
		variable browse 
		if {$browse(curix) < ([llength $browse(list)] - 1)} {
			incr browse(curix)
		}
		::radxide::eglib::Browse [lindex $browse(list) $browse(curix)]
	}

# ___________________ Previous ____________________ #

	proc Previous {} {
	 # Browse the previous files in the list
		variable browse
		if {$browse(curix) > 0} {
			incr browse(curix) -1
		}
		::radxide::eglib::Browse [lindex $browse(list) $browse(curix)]
	}

# ___________________ Run ____________________ #


	proc Copy {} {
  # Run the example in the shell
		variable browse
		set t $browse(text)
    tk_textCopy $t
	}

# ___________________ Reset ____________________ #


	proc Reset {} {
  # Reset the slave in the eval server
		variable browse
	 	set t $browse(text)
		$t config -state normal
		$t delete 1.0 end
		#Next
		#Previous
		#$t insert end ""
		$t insert end $browse(cookie)
		#$t config -state disabled
	}	
#_______________________	
	
}  

# _________________________________ EOF _________________________________ #	  
