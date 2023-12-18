###########################################################
# Name:    file.tcl
# Author:  Daniele Bonini  (posta@elettronica.lol)
# Date:    27/11/2023
# Desc:    File Menu namespace of RadXIDE.
#
#          File Menu namespace scaffolding and most of the code 
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

namespace eval file {

#_________________________ addFile ______________________ #


	proc addFile {} {
    # Add a file to the current project

    namespace upvar ::radxide dan dan
  
    set tree $dan(TREEVIEW)
    
	  if {[set ID [$tree selection]] eq {}} return
		
		::radxide::tree::addFile $ID
	}


#_________________________ closeFile ______________________ #

	proc closeFile {} {
    # Close the current file
    
    namespace upvar ::radxide dan dan menu menu project project
    
    # var reset
		set project(CUR_FILE_PATH) ""
    
    # ide text reset
   	set t $dan(TEXT)
  	$t config -state normal
	  $t delete 1.0 end
	  $t insert end ""
	  $t config -state disabled
	  ::radxide::win::fillGutter $dan(TEXT) $dan(GUTTEXT) 5 1 "#FFFFFF" "#222223"
	  
		# Update file Menu
	  $menu(FILE) entryconfigure $menu(SAVE_AS_ENTRY_IDX) -state disabled
	  $menu(FILE) entryconfigure $menu(SAVE_ENTRY_IDX) -state disabled
	  $menu(FILE) entryconfigure $menu(CLOSE_ENTRY_IDX) -state disabled
    $menu(EDIT) entryconfigure $menu(UNDO_ENTRY_IDX) -state disabled
	  $menu(EDIT) entryconfigure $menu(REDO_ENTRY_IDX) -state disabled  
    $menu(EDIT) entryconfigure $menu(COPY_ENTRY_IDX) -state disabled
	  $menu(EDIT) entryconfigure $menu(PASTE_ENTRY_IDX) -state disabled
	  $menu(EDIT) entryconfigure $menu(CUT_ENTRY_IDX) -state disabled
	  $menu(EDIT) entryconfigure $menu(INDENT_ENTRY_IDX) -state disabled
    $menu(EDIT) entryconfigure $menu(UNINDENT_ENTRY_IDX) -state disabled		  
	  $menu(EDIT) entryconfigure $menu(FIND_ENTRY_IDX) -state disabled
	  $menu(EDIT) entryconfigure $menu(GOTO_ENTRY_IDX) -state disabled
	  
	  ::radxide::main::updateAppTitle		      
	}

#_________________________ closeProject ______________________ #

	proc closeProject {} {
    # Close all the files
    
    namespace upvar ::radxide dan dan menu menu project project
    
    # var reset
		set project(NAME) ""
		set project(ROOT) ""
		set project(PATH) ""
		set project(CUR_FILE_PATH) ""
    
    # ide text reset
   	set t $dan(TEXT)
  	$t config -state normal
	  $t delete 1.0 end
	  $t insert end ""
	  $t config -state disabled
	  ::radxide::win::fillGutter $dan(TEXT) $dan(GUTTEXT) 5 1 "#FFFFFF" "#222223"
	  
	  # ide treeviee reset
	  set tree $dan(TREEVIEW)
	  ::radxide::tree::delete $tree {}

		# Update file Menu
		$menu(FILE) entryconfigure $menu(ADD_FILE_ENTRY_IDX) -state disabled
	  $menu(FILE) entryconfigure $menu(SAVE_AS_ENTRY_IDX) -state disabled
	  $menu(FILE) entryconfigure $menu(SAVE_ENTRY_IDX) -state disabled		  
	  $menu(FILE) entryconfigure $menu(CLOSE_ENTRY_IDX) -state disabled
    $menu(FILE) entryconfigure $menu(CLOSE_PROJECT_ENTRY_IDX) -state disabled
    $menu(EDIT) entryconfigure $menu(UNDO_ENTRY_IDX) -state disabled
	  $menu(EDIT) entryconfigure $menu(REDO_ENTRY_IDX) -state disabled  
    $menu(EDIT) entryconfigure $menu(COPY_ENTRY_IDX) -state disabled	  
	  $menu(EDIT) entryconfigure $menu(PASTE_ENTRY_IDX) -state disabled
	  $menu(EDIT) entryconfigure $menu(CUT_ENTRY_IDX) -state disabled
	  $menu(EDIT) entryconfigure $menu(INDENT_ENTRY_IDX) -state disabled
    $menu(EDIT) entryconfigure $menu(UNINDENT_ENTRY_IDX) -state disabled	    
	  $menu(EDIT) entryconfigure $menu(FIND_ENTRY_IDX) -state disabled
	  $menu(EDIT) entryconfigure $menu(GOTO_ENTRY_IDX) -state disabled

	  ::radxide::main::updateAppTitle		      
	  
	}


# ________________________ createProjectStru _______________________ #

  proc createProjectStru {pjroot pjname} {
  
    namespace upvar ::radxide dan dan
  
    set init_txt ""
    set init_txt ${init_txt}project_name=$pjname\n
    set init_txt ${init_txt}project_root=$pjroot\n
    
    set fh [open $dan(WORKDIR)/$pjname.radx {WRONLY CREAT EXCL}]
    puts $fh $init_txt
    close $fh
    
		file mkdir $pjroot
		file mkdir $pjroot/Private
		file mkdir $pjroot/Public
			
  }

# ________________________ newProject _______________________ #

	proc newProject {} {
    # Create a new project
    
    namespace upvar ::radxide dan dan project project icons icons menu menu
    
		set types {
				{{Project Files}    {.radx}       }
				{{All Files}        *             }
		}
		set oriprojectpath [tk_getSaveFile -initialdir $dan(WORKDIR) -filetypes $types]

		if {$oriprojectpath ne ""} {
		
		  # Check: Parent path must equal to Working Dir..
		  if {[string range $oriprojectpath 0 [expr [string last "/" $oriprojectpath]-1]] ne $dan(WORKDIR)} {
			
        tk_messageBox -title $dan(TITLE) -icon error -message "Project must be inside the Working Dir!"			
			  return
			  
			}
		
			# Parsing project name and path ..
			set projectpath $oriprojectpath
			
			set projectname [string range $projectpath [expr [string last "/" $projectpath]+1] end]
			set projectname [string tolower $projectname] 
			set projectname [string totitle $projectname]
			set projectname [string map {.radx ""} $projectname]
			set project(NAME) $projectname
			
			set project(ROOT) $dan(WORKDIR)/$project(NAME)
			
			set projectpath $project(ROOT).radx
			set project(PATH) $projectpath
			
		  # Check: Project existance..
		  if {[file exists $oriprojectpath] || [file exists $project(PATH)]} {
			
        tk_messageBox -title $dan(TITLE) -icon error -message "Project already exists!"			
			  return
			  
			}
			
			# tk_messageBox -title $dan(TITLE) -icon error -message $project(NAME)
			# tk_messageBox -title $dan(TITLE) -icon error -message $project(ROOT)
			# tk_messageBox -title $dan(TITLE) -icon error -message $project(PATH)
			
			# Creating Project file structure
			createProjectStru $project(ROOT) $project(NAME)
							
			# Update Treeview
			#catch {::winfun::clearTree $dan(TREEVIEW) $project(TREE_PROJECT_ROOT)}
			#set project(TREE_PROJECT_ROOT) [$dan(TREEVIEW) insert {} 0 -text $project(NAME) -image $icons(PROJECT-ICONI) -open true]
			#set project(TREE_PRIVATE_ROOT) [$dan(TREEVIEW) insert $project(TREE_PROJECT_ROOT) 1 -text "Private" -image $icons(PRIVATEF-ICONI)]
			#set project(TREE_PUBLIC_ROOT) [$dan(TREEVIEW) insert $project(TREE_PROJECT_ROOT) 2 -text "Public" -image $icons(PUBLICF-ICONI)]
			::radxide::tree::create
			
			# Update file Menu
			$menu(FILE) entryconfigure $menu(ADD_FILE_ENTRY_IDX) -state normal
      $menu(FILE) entryconfigure $menu(CLOSE_PROJECT_ENTRY_IDX) -state normal		  		        		  		  

			# Update text editor
			#$dan(TEXT) configure -state normal
		}
	}


#_________________________ openProject ______________________ #


	proc openProject {} {
    # Open an existing project

    namespace upvar ::radxide dan dan project project icons icons menu menu
    
		set types {
				{{Project Files}    {.radx}       }
				{{All Files}        *             }
		}
		set oriprojectpath [tk_getOpenFile -initialdir $dan(WORKDIR) -filetypes $types]

		if {$oriprojectpath ne ""} {
		
		  # Check: Parent path must equal to Working Dir..
		  if {[string range $oriprojectpath 0 [expr [string last "/" $oriprojectpath]-1]] ne $dan(WORKDIR)} {
			
        tk_messageBox -title $dan(TITLE) -icon error -message "Project must be inside the Working Dir!"			
			  return
			  
			}
		
			# Parsing project name and path ..
			set projectpath $oriprojectpath
			
			set projectname [string range $projectpath [expr [string last "/" $projectpath]+1] end]
			set projectname [string tolower $projectname] 
			set projectname [string totitle $projectname]
			set projectname [string map {.radx ""} $projectname]
			set project(NAME) $projectname
			
			#tk_messageBox -title $dan(TITLE) -icon error -message $projectname
			
			#project_root=/home/pocahontas/.radxwork/Pippo
			
			if [catch {open $oriprojectpath} in] {
	      tk_messageBox -title $dan(TITLE) -icon error -message "Cannot open $projectname."
      	return
      }   
      set project(ROOT) ""
			while {[gets $in line] >= 0} {
				regexp {^project_root\=(.+)} $line x project(ROOT)
				if {$project(ROOT) ne ""} {
				  break
				}
			}
			#tk_messageBox -title $dan(TITLE) -icon error -message $projectname
 			#tk_messageBox -title $dan(TITLE) -icon error -message $project(ROOT)
			#set project(ROOT) [gets $in line]
			
			set projectpath $project(ROOT).radx
			set project(PATH) $projectpath
			
			# Update Treeview
			::radxide::tree::create
			
			# Update file Menu
			$menu(FILE) entryconfigure $menu(ADD_FILE_ENTRY_IDX) -state normal
      $menu(FILE) entryconfigure $menu(CLOSE_PROJECT_ENTRY_IDX) -state normal	

			# Update text editor
			#$dan(TEXT) configure -state normal
						
    }
	}

#____________________________ quit ______________________ #


	proc quit {} {
    # Quit the application
    radxide::quit
	}


# ________________________ saveFileByName _______________________ #


  proc saveFileByName {{withGUI no}} {
  
    namespace upvar ::radxide dan dan project project
    
    #tk_messageBox -title $dan(TITLE) -icon error -message "file=$project(CUR_FILE_PATH)"
    
    if {$withGUI eq yes} {
    
      set initialdir [string range $project(CUR_FILE_PATH) 0 [expr [string last "/" $project(CUR_FILE_PATH)]-1]]
      set initialfile [string range $project(CUR_FILE_PATH) [expr [string last "/" $project(CUR_FILE_PATH)]+1] end]
      
								set types {
										{{HTML Files}       {.html}       }					
										{{PHP Files}        {.php}        }
										{{INC Files}        {.inc}        }
										{{All Files}        *             }
								}
								set orifilepath [tk_getSaveFile -initialdir $initialdir -initialfile $initialfile -filetypes $types -defaultextension .php]
								
								if {$orifilepath eq ""} {return}
								
								# Check: Parent path must equal to Working Dir..
								if {([string first $project(ROOT)/Private $orifilepath] eq -1) && ([string first $project(ROOT)/Public $orifilepath] eq -1)} {
								
			      tk_messageBox -title $dan(TITLE) -icon error -message "File must be saved inside a valid destination in the Working Dir ($project(ROOT)) !"			
										return
								}			
			
					  set fname $orifilepath
			  
					} else {   

						 set fname $project(CUR_FILE_PATH)
			    }
		  
		  set t $dan(TEXT)
		  set stxt [string trim [$t get 1.0 end]]
	    
	   if {![file writable $fname]} { 
      tk_messageBox -title $dan(TITLE) -icon error -message "File not writable!"			
	   } else {
  		   ::radxide::filelib::saveFile $fname $stxt
  		    }
  }

#_________________________ saveFileAs ______________________ #


	proc saveFileAs {} {
    # Save the current file as..
    
    namespace upvar ::radxide dan dan
    
    #tk_messageBox -title $dan(TITLE) -icon info -message "Saved as!"    
    
    namespace upvar ::radxide project project

    if {$project(CUR_FILE_PATH) ne ""} {
      saveFileByName yes
         }
	}

#_________________________ saveFile ______________________ #


	proc saveFile {} {
    # Save the current file
    
    namespace upvar ::radxide dan dan project project

    #tk_messageBox -title $dan(TITLE) -icon info -message "Saved!"

		if {$project(CUR_FILE_PATH) ne ""} {
      saveFileByName no
    }
	}

#_________________________#

}


# _________________________________ EOF _________________________________ #
