###########################################################
# Name:    tree.tcl
# Author:  Daniele Bonini  (posta@elettronica.lol)
# Date:    05/12/2023
# Desc:    Tree namespace of RadXIDE.
#
#          Tree namespace and most of the code 
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

namespace eval tree {

# ________________________ addFile _________________________ #


	proc addFile {{ID ""}} {
		# Adds a new item to the tree.
		#   ID - an item's ID where the new file will be added (for the file tree).

		namespace upvar ::radxide dan dan

    set tree $dan(TREEVIEW)
    lassign [$tree item $ID -values] -> fname isfile
    set destfolder $fname
    
    if {!$isfile} {
    
      #tk_messageBox -title $dan(TITLE) -icon error -message $destfolder
        
      ::radxide::filelib::createFile $destfolder
      
      # Refreshing TreeView
      ::radxide::tree::create
      
    }  

	}

# ________________________ addFolder _________________________ #


	proc addFolder {{ID ""}} {
		# Adds a new item to the tree.
		#   ID - an item's ID where the new folder will be added (for the file tree).

		namespace upvar ::radxide dan dan

    set tree $dan(TREEVIEW)
    lassign [$tree item $ID -values] -> fname isfile
    set parentfolder $fname
    
    if {!$isfile} {
    
      #tk_messageBox -title $dan(TITLE) -icon error -message $parentfolder
        
      ::radxide::filelib::createFolder $parentfolder
      
      # Refreshing TreeView
      ::radxide::tree::create
      
    }  

	}


# ________________________ addTags _________________________ #


	proc addTags {tree} {
		# Creates tags for the tree.
		#   tree - the tree's path

		namespace upvar ::radxide dan dan
		#lassign [::hl_tcl::addingColors {} -AddTags] - - fgbr - - fgred - - - fgtodo

		$tree tag configure tagNorm -foreground $dan(FG)
		$tree tag configure tagSel  -foreground $dan(fgred)
		$tree tag configure tagBold -foreground $dan(fgbold)
		$tree tag configure tagTODO -foreground $dan(fgtodo)
		$tree tag configure tagBranch -foreground $dan(fgbranch)
	}

# ________________________ AddToDirContents _________________________ #

	proc addToDirContent {lev isfile fname iroot} {
		# Adds an item to a list of directory's contents.
		#   lev - level in the directory hierarchy
		#   isfile - a flag "file" (if yes) or "directory" (if no)
		#   fname - a file name to be added
		#   iroot - index of the directory's parent or -1

		namespace upvar ::radxide dan dan _dirtree _dirtree
		set dllen [llength $_dirtree]
		if {$dllen < $dan(MAXFILES)} {
		  lappend _dirtree [list $lev $isfile $fname 0 $iroot]
		  if {$iroot>-1} {
		    lassign [lindex $_dirtree $iroot] lev isfile fname fcount sroot
		    set _dirtree [lreplace $_dirtree $iroot $iroot \
		      [list $lev $isfile $fname [incr fcount] $sroot]]
		  }
		}
		return $dllen
	}

# ________________________ buttonPress _________________________ #


	proc buttonPress {but x y X Y} {
		# Handles a mouse clicking the tree.
		#   but - mouse button
		#   x - x-coordinate to identify an item
		#   y - y-coordinate to identify an item
		#   X - x-coordinate of the click
		#   Y - x-coordinate of the click

		namespace upvar ::radxide dan dan menu menu
		set tree $dan(TREEVIEW)
		set ID [$tree identify item $x $y]
		set region [$tree identify region $x $y]
		#set al(movID) [set al(movWin) {}]
		if {![$tree exists $ID] || $region ni {tree cell}} {
		  return  ;# only tree items are processed
		}
		#tk_messageBox -title $dan(TITLE) -icon error -message $but
		switch $but {
		  {3} {
		    if {[llength [$tree selection]]<2} {
		      $tree selection set $ID
		    }
		    showPopupMenu $ID $X $Y
		  }
		  {1} {
		    #::radxide::tree::openFile $ID
		    
		    lassign [$tree item $ID -values] -> fname isfile
     		if {$isfile} {
     		  $menu(FILE) entryconfigure $menu(ADD_FILE_ENTRY_IDX) -state disabled
		    } else {
		      $menu(FILE) entryconfigure $menu(ADD_FILE_ENTRY_IDX) -state normal
		    }   
		  }
		}
	}

# ________________________ buttonRelease _________________________ #


	proc buttonRelease {but s x y X Y} {
		# Handles a mouse button releasing on the tree, at moving an item.
		#   but - mouse button
		#   s - state (ctrl/alt/shift)
		#   x - x-coordinate to identify an item
		#   y - y-coordinate to identify an item
		#   X - x-coordinate of the click
		#   Y - x-coordinate of the click

		namespace upvar ::radxide dan dan
		
		set tree $dan(TREEVIEW)
		set ID [$tree identify item $x $y]
		#DestroyMoveWindow no
		#set msec [clock milliseconds]
		#set ctrl [expr {$s & 0b100}]
		#if {([info exists al(_MSEC)] && [expr {($msec-$al(_MSEC))<400}]) || $ctrl} {
		#  SelectUnits $wtree $ctrl
		#  set al(movWin) {}
		#  return
		#}
		#if {[$tree exists $ID] && [info exists al(movID)] && \
		#$al(movID) ne {} && $ID ne {} && $al(movID) ne $ID && \
		#[$wtree identify region $x $y] eq {tree}} {
		#  if {$al(TREE,isunits)} {
		#    alited::unit::MoveUnits $wtree move $al(movID) $ID
		#  } else {
		#    alited::file::MoveFiles $wtree move $al(movID) $ID
		#  }
		#}
		#DestroyMoveWindow yes
	}

# ________________________ clearTree _________________________ #

	proc clearTree {TreeView item} {
		# Removes recursively an item and its children from the tree.
		#   TreeView - the tree widget's path
		#   item - ID of the item to be deleted.

		foreach child [$TreeView children $item] {
		  clearTree $TreeView $child
		}
		if {$item ne {}} {$TreeView delete $item}
	}

# ________________________ create _________________________ #

	proc create {} {
		# Creates a tree of files, at need.
		
		namespace upvar ::radxide dan dan menu menu

		set tree $dan(TREEVIEW)

	  # for file tree: get its current "open branch" flags
	  # in order to check them in createFilesTree
	  set dan(SAVED_FILE_TREE) [list]
	  foreach item [getTree] {
	    lassign $item - - ID - values
	    lassign $values -> fname isfile
	    if {[string is false -strict $isfile]} {
	      lappend dan(SAVED_FILE_TREE) [list $fname [$tree item $ID -open]]
	    }
	  }

		#set TID [alited::bar::CurrentTabID]
		delete $tree {}
		addTags $tree
		bind $tree "<ButtonPress>" {after idle {::radxide::tree::buttonPress %b %x %y %X %Y}}
		#bind $tree "<ButtonRelease>" {after idle {::radxide::tree::buttonRelease %b %s %x %y %X %Y}}
		bind $tree "<Double-Button-1>" {after idle {::radxide::tree::dblClick %b %x %y %X %Y}}
		#bind $tree "<Motion>" {after idle {::radxide::tree::ButtonMotion %b %s %x %y %X %Y}}
		#bind $tree "<ButtonRelease>" {alited::tree::DestroyMoveWindow no}
		#bind $tree "<Leave>" {alited::tree::DestroyMoveWindow yes}
		#bind $tree "<F2>" {alited::file::RenameFileInTree 0 -}
		#bind $tree "<Insert>" {alited::tree::AddItem}
		#bind $tree "<Delete>" {alited::tree::DelItem {} {}}

		createFileTree $tree
		unset dan(SAVED_FILE_TREE)

    $menu(FILE) entryconfigure $menu(ADD_FILE_ENTRY_IDX) -state disabled

	}

# ________________________ createFileTree _________________________ #

	proc createFileTree {tree} {

		# Creates a file tree.
		#   wtree - the tree's path

		namespace upvar ::radxide dan dan project project icons icons 
		#set al(TREE,files) yes
		#[$obPav BtTswitch] configure -image alimg_gulls
		#baltip::tip [$obPav BtTswitch] $al(MC,swfiles)
		#baltip::tip [$obPav BtTAddT] $al(MC,filesadd)\nInsert
		#baltip::tip [$obPav BtTDelT] $al(MC,filesdel)\nDelete
		#baltip::tip [$obPav BtTUp] $al(MC,moveupF)
		#baltip::tip [$obPav BtTDown] $al(MC,movedownF)
		#$tree heading #0 -text ":: [file tail $al(prjroot)] ::"
		#$tree heading #1 -text $al(MC,files)
		bind $tree <Return> {::radxide::tree::openFile}
		set selID ""
		#if {[catch {set selfile [alited::bar::FileName]}]} {
		#  set selfile {} ;# at closing by Ctrl+W with file tree open: no current file
		#}
		
		set parent {}
		set fc 0
		set fname $project(ROOT)
		set title [file tail $fname]
		set isfile no
		set itemID 0
		set isopen yes
		set imgopt $icons(PROJECT-ICONI)
		
		$tree insert $parent end -id $itemID -text "$title" \
		    -values [list $fc $fname $isfile $itemID] -open $isopen -image $imgopt

		set dan(_dirignore) [list]
		catch {    ;# there might be an incorrect list -> catch it
		  foreach d $dan(prjdirignore) {
		    lappend dan(_dirignore) [string toupper [string trim $d \"]]
		     }  
		}

		foreach item [getDirectoryContent $project(ROOT)] {
		  
		  lassign $item lev isfile fname fcount iroot
		  #if {([string first $project(ROOT)/Private $fname] eq -1) && ([string first $project(ROOT)/Public $fname] eq -1)} {
		  #  continue
		  #}  
		  set itemID [newItemID [incr iit]]
		  #if {$selfile eq $fname} {set selID $itemID}
		  set title [file tail $fname]
		  if {$iroot<0} {
		    set parent 0 ;#{}
		  } else {
		    set parent [newItemID [incr iroot]]
		  }
		  #if {$parent eq 0 && ((!$isfile && ($title ne "Private") && ($title ne "Public")) || ($isfile))} {
		  #  continue
		  #}
		  set isopen no
		  if {$isfile} {
		  
		    if {$parent eq 0} {
		      continue
		    } 
		  
		    if {[isHtml $fname]} {
		      set imgopt $icons(HTML-ICONI)
		    } elseif {[isCss $fname]} {
		      set imgopt $icons(CSS-ICONI)		      
		    } elseif {[isJs $fname]} {
		      set imgopt $icons(JS-ICONI)		      
		    } elseif {[isPhp $fname]} {
		      set imgopt $icons(PHP-ICONI)
		    } elseif {[isTxt $fname]} {
		      set imgopt $icons(TXT-ICONI)
		    } elseif {[isImage $fname]} {
		      set imgopt $icons(IMG-ICONI)		      
		    } else {
		      set imgopt $icons(GENERIC-FILE-ICONI)
		    }
		  } else {
        
        if {$title eq "Private"} {
	        set imgopt $icons(PRIVATEF-ICONI)
	      } elseif {$title eq "Public"} {
	        set imgopt $icons(PUBLICF-ICONI)
	      } else {
	      
	        if {$parent eq 0} {
		        continue
		      } 
	      
	        set imgopt $icons(FOLDER-ICONI)	
	      }  
		    
		    # get the directory's flag of expanded branch (in the file tree)
		    set idx [lsearch -index 0 -exact $dan(SAVED_FILE_TREE) $fname]
		    if {$idx>-1} {
		      set isopen [lindex $dan(SAVED_FILE_TREE) $idx 1]
		    }
		  }
		  if {$fcount} {set fc $fcount} {set fc {}}
		  $tree insert $parent end -id $itemID -text "$title" \
		    -values [list $fc $fname $isfile $itemID] -open $isopen -image $imgopt
		  $tree tag add tagNorm $itemID
		  if {!$isfile} {
		    $tree tag add tagBranch $itemID
		  }
		}
		if {$selID ne {}} {
		  $tree see $selID
		  $tree selection set $selID
		}
	}



# ________________________ delete _________________________ #

	proc deleteFile {ID} {
		# Removes a file.
		#   ID - ID of the item to be deleted.

    namespace upvar ::radxide dan dan

    set tree $dan(TREEVIEW)

		if {$ID eq {}} {
		  if {[set ID [$tree selection]] eq {}} return
		}
		lassign [$tree item $ID -values] -> fname isfile

    if {$isfile} {
    
      set answer [tk_messageBox -title $dan(TITLE) -message "Really delete the selected file?" \
        -icon question -type yesno -detail "Selected: \"$fname\""]
    
      if {$answer eq yes} {
        ::radxide::filelib::delFile $fname
        
        ::radxide::tree::create
      }    
    }
	}

# ________________________ delete _________________________ #

	proc delete {tree item} {
		# Removes recursively an item and its children from the tree.
		#   tree - the tree widget's path
		#   item - ID of the item to be deleted.

		foreach child [$tree children $item] {
		  delete $tree $child
		}
		if {$item ne {}} {$tree delete $item}
	}

# ________________________ dblClick _________________________ #


	proc dblClick {but x y X Y} {
		# Handles a mouse clicking the tree.
		#   but - mouse button
		#   x - x-coordinate to identify an item
		#   y - y-coordinate to identify an item
		#   X - x-coordinate of the click
		#   Y - x-coordinate of the click

		namespace upvar ::radxide dan dan
		set tree $dan(TREEVIEW)
		set ID [$tree identify item $x $y]
		set region [$tree identify region $x $y]
		#set al(movID) [set al(movWin) {}]
		if {![$tree exists $ID] || $region ni {tree cell}} {
		  return  ;# only tree items are processed
		}
		#tk_messageBox -title $dan(TITLE) -icon error -message DoubleClick: ($but)
		switch $but {
		  {3} {

  	  }
		  {1} {
		    #set al(movID) $ID
		    #set al(movWin) .tritem_move
		    #set msec [clock milliseconds]
		    #if {[info exists al(_MSEC)] && [expr {($msec-$al(_MSEC))<400}]} {
		    ::radxide::tree::openFile $ID
		    #}
		    #set al(_MSEC) $msec
		  }
		}
	}

# ________________________ dirContent _________________________ #

	proc dirContent {dirname {lev 0} {iroot -1} {globs "*"}} {
		# Reads a directory's contents.
		#   dirname - a dirtectory's name
		#   lev - level in the directory hierarchy
		#   iroot - index of the directory's parent or -1
		#   globs - list of globs to filter files.

		namespace upvar ::radxide dan dan _dirtree _dirtree
		incr lev
				
		# firstly directories:
		
		if {[catch {set dcont [lsort -dictionary [glob -type d [file join $dirname *]]]}]} {
			set dcont [list]
		}
		# firstly directories:
		# 1. skip the ignored ones
		for {set i [llength $dcont]} {$i} {} {
			incr i -1
			if {[ignoredDir [lindex $dcont $i]] || (($lev eq 1) && (([file tail [lindex $dcont $i]] ne "Private") && ([file tail [lindex $dcont $i]] ne "Public")))}  {
				set dcont [lreplace $dcont $i $i]
			}
		}
		# 2. put the directories to the beginning of the file list
		set i 0
		foreach fname $dcont {
 			if {[file isdirectory $fname]} {
	 			set dcont [lreplace $dcont $i $i [list $fname "y"]]
				set nroot [addToDirContent $lev 0 $fname $iroot]
				if {[llength $_dirtree] < $dan(MAXFILES)} {
					dirContent $fname $lev $nroot $globs
				} else {
					break
				}
			} else {
				set dcont [lreplace $dcont $i $i [list $fname]]
			}
			incr i
		}		

		
		# then files
		
		# hidden files
		if {[catch {set dcont [lsort -dictionary [glob -types {f hidden} [file join $dirname *]]]}]} {
		  set dcont [list]
		}
		for {set i [llength $dcont]} {$i} {} {
		  incr i -1
		  if {[ignoredDir [lindex $dcont $i]] && (!(([file tail [lindex $dcont $i]] ne ".") && ([file tail [lindex $dcont $i]] ne "..")))} {
		    set dcont [lreplace $dcont $i $i]
		     }
		}
		if {[llength $_dirtree] < $dan(MAXFILES)} {
		  foreach fname $dcont {
		    lassign $fname fname d
		    if {$d ne "y"} {
		      #tk_messageBox -title $dan(TITLE) -icon error -message $fname
		      foreach gl [split $globs ","] {
		        if {[string match $gl $fname]} {
		          addToDirContent $lev 1 $fname $iroot
		          break
		                    }
		               }
		         }
		     }
		 }
	 # generic files
		if {[catch {set dcont [lsort -dictionary [glob -type f [file join $dirname *]]]}]} {
		  set dcont [list]
		}
		for {set i [llength $dcont]} {$i} {} {
		  incr i -1
		  if {[ignoredDir [lindex $dcont $i]] && (!(([file tail [lindex $dcont $i]] ne ".") && ([file tail [lindex $dcont $i]] ne "..")))} {
		    set dcont [lreplace $dcont $i $i]
		     }
		}
		if {[llength $_dirtree] < $dan(MAXFILES)} {
		  foreach fname $dcont {
		    set d " " 
                    set fname [string map {"\"" "\'"} $fname] 
                    #lassign $fname fname d
		    if {$d ne "y"} {
		      #tk_messageBox -title $dan(TITLE) -icon error -message $fname
		      foreach gl [split $globs ","] {
		        if {[string match $gl $fname]} {
		          addToDirContent $lev 1 $fname $iroot
		          break
		                    }
		               }
		         }
		     }
		 }
		 
	}

# ________________________ getDirectoryContent _________________________ #


	proc getDirectoryContent {dirname} {
		# Gets a directory's content.
		#   dirname - the directory's name
		# Returns a list containing the directory's content.

		namespace upvar ::radxide dan dan _dirtree _dirtree
#		set _dirtree [set dan(_dirignore) [list]]
		set _dirtree [list]
#		catch {    ;# there might be an incorrect list -> catch it
#		  foreach d $dan(prjdirignore) {
#		    lappend dan(_dirignore) [string toupper [string trim $d \"]]
#		  }
#		}
#		lappend dan(_dirignore) [string toupper [file tail [::radxide::Tclexe]]]
		dirContent $dirname
		return $_dirtree
	}

# ________________________ getTree _________________________ #

	proc getTree {{parent {}}} {
		# Gets a tree or its branch.
		#   parent - ID of the branch
		#   Tree - name of the tree widget

		namespace upvar ::radxide dan dan
		set tree $dan(TREEVIEW)
		set mytree [list]
		set levp -1
		procTreeItems $tree {
		  set item "%item"
		  set lev %level
		  if {$levp>-1 || $item eq $parent} {
		    if {$lev<=$levp} {return -code break}  ;# all of branch fetched
		    if {$item eq $parent} {set levp $lev}
		  }
		  catch {
		    if {$parent eq {} || $levp>-1} {
		      lappend mytree [list $lev %children $item {%text} {%values}]
		    }
		  }
		}
		return $mytree
	}

# ________________________ ignoredDir _________________________ #

	proc ignoredDir {dir} {
		# Checks if a directory is in the list of the ignored ones.
		#   dir - the directory's name

		namespace upvar ::radxide dan dan
		set dir [string toupper [file tail $dir]]
		return [expr {[lsearch -exact $dan(_dirignore) $dir]>-1}]
	}

# ________________________ isHtml _________________________ #

	proc isHtml {fname} {
		# Checks if a file is of Html.
		#   fname - file name

		if {[string tolower [file extension $fname]] in $radxide::dan(HtmlExts)} {
		  return yes
		}
		return no
	}

# ________________________ isCss _________________________ #

	proc isCss {fname} {
		# Checks if a file is of Css.
		#   fname - file name

		if {[string tolower [file extension $fname]] in $radxide::dan(CssExts)} {
		  return yes
		}
		return no
	}

# ________________________ isBin _________________________ #

	proc isBin {fname} {
		# Checks if a file is of isBin.
		#   fname - file name

		if {[string tolower [file extension $fname]] in $radxide::dan(BinExts)} {
		  return yes
		}
		return no
	}

# ________________________ isImage _________________________ #

	proc isImage {fname} {
		# Checks if a file is of Image.
		#   fname - file name

		if {[string tolower [file extension $fname]] in $radxide::dan(ImgExts)} {
		  return yes
		}
		return no
	}

# ________________________ isJs _________________________ #

	proc isJs {fname} {
		# Checks if a file is of JS.
		#   fname - file name

		if {[string tolower [file extension $fname]] in $radxide::dan(JsExts)} {
		  return yes
		}
		return no
	}

# ________________________ isOfficeFile _________________________ #

	proc isOfficeFile {fname} {
		# Checks if a file is of isOfficeFile.
		#   fname - file name

		if {[string tolower [file extension $fname]] in $radxide::dan(OfficeExts)} {
		  return yes
		}
		return no
	}

# ________________________ isPhp _________________________ #

	proc isPhp {fname} {
		# Checks if a file is of PHP.
		#   fname - file name

		if {[string tolower [file extension $fname]] in $radxide::dan(PhpExts)} {
		  return yes
		}
		return no
	}

# ________________________ isTxt _________________________ #

	proc isTxt {fname} {
		# Checks if a file is of Txt.
		#   fname - file name

		if {[string tolower [file extension $fname]] in $radxide::dan(TxtExts)} {
		  return yes
		}
		return no
	}

# ________________________ newItemID _________________________ #

	proc newItemID {iit} {
		# Gets a new ID for the tree item.
		#   iit - index of the new item.

		return "al$iit"
	}

# ________________________ openFile _________________________ #


	proc openFile {{ID ""}} {
		# Opens file at clicking a file tree's item.
		#   ID - ID of file tree

		namespace upvar ::radxide dan dan menu menu project project

		set tree $dan(TREEVIEW)
		#tk_messageBox -title $dan(TITLE) -icon error -message $ID
		if {$ID eq {}} {
		  if {[set ID [$tree selection]] eq {}} return
		}
		lassign [$tree item $ID -values] -> fname isfile
		if {![file exists $fname]} {
		
				tk_messageBox -title $dan(TITLE) -icon error -message "File doesn't exist!"
	  	return		
	  	
	 }	 else {
		
		 	if {[file size $fname] > $dan(MAXFILESIZE)} {
				  tk_messageBox -title $dan(TITLE) -icon error -message "File exceed MAXFILESIZE=$dan(MAXFILESIZE)"
	  			return
				 }
		
				if {$isfile && (![isBin $fname]) && (![isOfficeFile $fname]) && (![isImage $fname])} {
					 $dan(TEXT) config -state normal
					 $dan(TEXT) delete 1.0 end 
					 $dan(TEXT) insert 1.0 [::radxide::filelib::openFile $fname]
					 ::radxide::win::fillGutter $dan(TEXT) $dan(GUTTEXT) 5 1 "#FFFFFF" "#222223"
					
					 # Update menu
				  $menu(FILE) entryconfigure $menu(SAVE_ENTRY_IDX) -state normal
				  $menu(FILE) entryconfigure $menu(SAVE_AS_ENTRY_IDX) -state normal
				  $menu(FILE) entryconfigure $menu(CLOSE_ENTRY_IDX) -state normal
				  $menu(EDIT) entryconfigure $menu(UNDO_ENTRY_IDX) -state normal
				  $menu(EDIT) entryconfigure $menu(REDO_ENTRY_IDX) -state normal
				  $menu(EDIT) entryconfigure $menu(COPY_ENTRY_IDX) -state normal
				  $menu(EDIT) entryconfigure $menu(PASTE_ENTRY_IDX) -state normal
				  $menu(EDIT) entryconfigure $menu(CUT_ENTRY_IDX) -state normal	
				  $menu(EDIT) entryconfigure $menu(INDENT_ENTRY_IDX) -state normal
				  $menu(EDIT) entryconfigure $menu(UNINDENT_ENTRY_IDX) -state normal	    
				  $menu(EDIT) entryconfigure $menu(FIND_ENTRY_IDX) -state normal
				  $menu(EDIT) entryconfigure $menu(GOTO_ENTRY_IDX) -state normal	    
					
				  set project(CUR_FILE_PATH) $fname
					
				  $dan(TEXT) edit reset
					
				  focus $dan(TEXT)
				  ::tk::TextSetCursor $dan(TEXT) @0,0
					
				  ::radxide::main::updateAppTitle
							  
					 # after idle {alited::bar::BAR draw; alited::tree::UpdateFileTree}
				 } else {	 
 			  tk_messageBox -title $dan(TITLE) -icon error -message "File is binary or a folder!"
	  			return
				 }
		 }		
	}


# ________________________ procTreeItems _________________________ #


	proc procTreeItems {tree aproc {lev 0} {branch {}}} {
		# Scans all items of the tree.
		#   tree - the tree's path
		#   aproc - a procedure to run at scanning
		#   lev - level of the tree
		#   branch - ID of the branch to be scanned
		# The 'aproc' argument can include wildcards to be replaced
		# appropriate data:
		#    %level - current tree level
		#    %children - children of a current item
		#    %item - ID of a current item
		#    %text - text of a current item
		#    %values - values of a current item

		set children [$tree children $branch]
		if {$lev} {
		  set proc [string map [list \
		    %level $lev \
		    %children [llength $children] \
		    %item $branch \
		    %text [$tree item $branch -text] \
		    %values [$tree item $branch -values]] \
		    $aproc]
		  uplevel [expr {$lev+1}] "$proc"
		}
		incr lev
		foreach child $children {
		  procTreeItems $tree $aproc $lev $child
		}
	}

# ________________________ refreshTree _________________________ #


  proc refreshTree {{tree ""} {headers ""} {clearsel no}} {
  
     namespace upvar ::radxide dan dan
  
     if {$tree eq ""} {
       set tree $dan(TREEVIEW)
     }
  
     if {[set selID [$tree selection]] eq {}} return
     #tk_messageBox -title $dan(TITLE) -icon error -message $selID
     
     ::radxide::tree::create
     
     $tree selection set [list $selID]
     
  }

# ________________________ renameFile _________________________ #


  proc renameFile {{ID ""}} {
  
    namespace upvar ::radxide dan dan
  
    set tree $dan(TREEVIEW)
    set args {}
    set name2 ""
    
		if {$ID eq {}} {
		  if {[set ID [$tree selection]] eq {}} return
		}
		lassign [$tree item $ID -values] -> fname isfile 
  
    # lassign [::radxide::win::input {} "Rename file" [list \
    #   ent "{} {} {-w 32}" "{$fname}"] \
    #   -head "File name:" res name2]
    
    set args "-buttons {butOK OK ::radxide::win::renameFileOK butCANCEL CANCEL ::radxide::win::renameFileCancel}"
       
    catch {lassign [::radxide::win::input "RenameFile" {} "Rename file" [list \
      ent "{} {} {-w 64}" "{$fname}"] \
      -head "File name:" {*}$args] res}
  
  }
  
# ________________________ renameFolder _________________________ #


  proc renameFolder {{ID ""}} {
  
    namespace upvar ::radxide dan dan
  
    set tree $dan(TREEVIEW)
    set args {}
    set name2 ""
    
		if {$ID eq {}} {
		  if {[set ID [$tree selection]] eq {}} return
		}
		lassign [$tree item $ID -values] -> fname isfile 
  
    # lassign [::radxide::win::input {} "Rename file" [list \
    #   ent "{} {} {-w 32}" "{$fname}"] \
    #   -head "File name:" res name2]
    
    set args "-buttons {butOK OK ::radxide::win::renameFolderOK butCANCEL CANCEL ::radxide::win::renameFolderCancel}"
       
    catch {lassign [::radxide::win::input "RenameFolder" {} "Rename folder" [list \
      ent "{} {} {-w 64}" "{$fname}"] \
      -head "Folder name:" {*}$args] res}
  
  }  

# ________________________ showPopupMenu _________________________ #


	proc showPopupMenu {ID X Y} {
		# Creates and opens a popup menu at right clicking the tree.
		#   ID - ID of clicked item
		#   X - x-coordinate of the click
		#   Y - y-coordinate of the click

		namespace upvar ::radxide dan dan project project
		
		
		#::baltip sleep 1000
		set tree $dan(TREEVIEW)
		set popm $tree.popup
		catch {destroy $popm}
		menu $popm -tearoff 0 -cursor ""
		set header [lindex [split "" \n] 0]

		lassign [$tree item $ID -values] -> fname isfile
		
		set m1 "Refresh project"
		set m2 "Add file"
		set m2f "Add folder"
		set m3 "Rename file"
		set m4 "Delete file"
		set m3f "Rename folder"
		set m4f "Delete folder"
		set m5 "Open file" 
		set m6 "Open dir"  
		
		$popm add command -label $m1 -command { ::radxide::tree::refreshTree }
		
		if {$ID ne 0} {
		
				$popm add separator
				if {$isfile} {
					$popm add command -label $m2 -command "::radxide::tree::addFile $ID" -state disabled
				} else {
					$popm add command -label $m2 -command "::radxide::tree::addFile $ID" -state normal
				}
				if {$isfile} {  
					$popm add command -label $m3 -command "::radxide::tree::renameFile $ID"
					$popm add command -label $m4 -command "::radxide::tree::deleteFile $ID" 
				} else {
					$popm add command -label $m2f -command "::radxide::tree::addFolder $ID"
					if {($fname eq "$project(ROOT)/Public") || ($fname eq "$project(ROOT)/Private")} {
						$popm add command -label $m3f -command "::radxide::tree::renameFolder $ID" -state disabled
						$popm add command -label $m4f -command "::radxide::tree::delFolder $ID" -state disabled
					} else {
						$popm add command -label $m3f -command "::radxide::tree::renameFolder $ID" -state normal
						$popm add command -label $m4f -command "::radxide::tree::delFolder $ID" -state disabled
					}  	  	
				}	
				$popm add separator
				
				if {$isfile} {
					$popm add command -label $m5 -command "::radxide::tree::openFile $ID" -state normal
				} else {
					$popm add command -label $m5 -command { ::radxide::tree::openFile $ID } -state disabled
				}  
    
    }
         		
		set addsel {}
		if {[llength [$tree selection]]>1} {
		  if {[$tree tag has tagSel $ID]} {
		    # the added tagSel tag should be overrided
		    $tree tag remove tagSel $ID
		    set addsel "; $tree tag add tagSel $ID"
		  }
		}  
		
		bind $popm <FocusIn> "$tree tag add tagBold $ID"
		bind $popm <FocusOut> "catch {$tree tag remove tagBold $ID; $addsel}"
		#$obPav themePopup $popm
		tk_popup $popm $X $Y
	}

#_______________________

	
}	

# _________________________________ EOF _________________________________ #
