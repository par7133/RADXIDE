#! /usr/bin/env tclsh
###########################################################
# Name:    radxide.tcl
# Author:  Daniele Bonini  (posta@elettronica.lol)
# Date:    08/10/2024
# Desc:    Bootstrap file of RadXIDE.
#
#          Bootstrap file and most of the code 
#          here presented and distributed contains excerpts 
#          from [alited](https://github.com/aplsimple/alited
#          by Alex Plotnikov and contributors to the project.
#          The original code of these excerpts could be 
#          borrowed from other sources which the author
#          and the contributors to this RadXIDE have no 
#          knowledge about.
#
#          Code Library scaffolding and most of its code contains 
#          excerpts from "Practical Programming in Tcl and Tk, 4th Ed."
#          by Brent B. Welch, Ken Jones, Jeffrey Hebbs.
#          The original code of these excerpts could be 
#          borrowed from other sources which the author
#          and the contributors to RadXIDE have no 
#          knowledge about. For the related copyright notice
#          refer <eglib.tcl> part of this software.
#
# License: MIT. Copyrights 5 Mode (Last implementation and adaptations.)
#               Copyright (c) 2021-2023 Alex Plotnikov https://aplsimple.github.io (original scaffolding and excerpts.)
#
###########################################################

set version "1.5.2" 
set os "$::tcl_platform(os) $::tcl_platform(osVersion)"

package provide radxide $version

set _ [package require Tk]
wm withdraw .

if {![package vsatisfies $_ 8.6.10-]} {
  tk_messageBox -message "\nradxide needs Tcl/Tk v8.6.10+ \
    \n\nwhile the current is v$_\n"
  exit
}

unset -nocomplain _


# __________________________ radxide:: Main _________________________ #

namespace eval radxide {

  variable dan; array set dan [list]
  
  variable tcltk_version "Tcl/Tk [package versions Tk]"

  ## ________________________ Main variables _________________________ ##

  set DEBUG no  ;# debug mode
  
  set dan(WIN) .danwin              ;# main form
  set dan(TITLE) RADXIDE
  
  set tmpfname "~"
  set userhome [file normalize $tmpfname]
  if {$userhome eq "/root"} {
     tk_messageBox -title $dan(TITLE) -icon error -message "RADXIDE can't run under root."
     exit 0
  }   
  
  set dan(WORKDIR) "$userhome/.radxwork"  ;# working dir
  
  # Check workdir existance..
  if {![file exists $dan(WORKDIR)]} {
    file mkdir $dan(WORKDIR)
  }

  # Check Code Library dir existance.. (WORKDIR)/.examples)
  if {![file exists $dan(WORKDIR)/.snippets]} {
    file mkdir $dan(WORKDIR)/.snippets
  }
    
  set dan(TREEVIEW) ""              ;# ide project tree
  set dan(GUTTEXT) ""               ;# ide guttext control 
  set dan(GUTTERWIDTH) 12
  set dan(TEXT) ""                  ;# ide text control
  set dan(TEXTBG) "#222223"
  set dan(TEXTFG) "#55ff55"
  set dan(TEXTSELFG) "red"
  set dan(TEXTFONT) "Monospace Semi-Condensed"
  set dan(TEXTFONTSIZE) "10"
  set dan(CURSORCOLOR) "red"
  set dan(CURSORWIDTH) "5"
  set dan(TOTLINES) 1
  set dan(CUR_FILE_MAX_YVIEW) 1.0
  set dan(prjdirignore) {.git nbproject} ;# ignored subdirectories of project
  
  set project(NAME) ""              ;# project default name
  set project(ROOT) ""              ;# project default root
  set project(PATH) ""              ;# project default path
  set project(CUR_FILE_PATH) ""     ;# project current file path
  set project(TREE_PROJECT_ROOT) "" ;# Treeview: Project root node
  set project(TREE_PRIVATE_ROOT) "" ;# Treeview: Private node
  set project(TREE_PUBLIC_ROOT) ""  ;# Treeview: Public node
  
  set files(FILE1) ""             ;# Array files
  set files(FILE2) ""
  set files(FILE3) ""  
  set files(FILE4) ""  
  set files(FILE5) ""  
  
  # main data of radxide (others are in ini.tcl)

  variable SCRIPT [info script]
  variable SCRIPTNORMAL [file normalize $SCRIPT]
  variable FILEDIR [file dirname $SCRIPTNORMAL]
  variable DIR [file dirname $FILEDIR]

  # directories of sources
  variable SRCDIR [file join $DIR src]
  variable LIBDIR [file join $DIR lib]
  variable ICONDIR [file join $SRCDIR icons]
  
  # misc. vars
  variable pID 0

  # directory tree's content
  variable _dirtree [list]
  
  set dan(TITLE_TEMPL) {%f :: %t}   ;# radxide title's template
  set dan(WIDTH) 1280
  set dan(HEIGHT) 760
  #set al(MOVEFG) "black"
  #set al(MOVEBG) "#7eeeee"  
  set dan(FG) "#000000"
  set dan(BG) "#cecece"  
  set dan(fgred) "red"
  set dan(fgbold) "magenta"
  set dan(fgtodo) "orange"
  set dan(fgbranch) "blue"    
  set dan(CHARFAMILY) "Sans"
  set dan(CHARSIZE) 10
  set dan(MAXFILES) 15000
  set dan(MAXFILESIZE) 150000
  set dan(MAXFINDLENGTH) 50 
  set dan(TAB_IN_SPACE) "  "
   
  # icons
  set dan(ICON) "$ICONDIR/radxide.png"
  set dan(ICONI) [image create photo imgobj1 -file $dan(ICON)]
      
  set icons(PROJECT-ICON) "$ICONDIR/archive.png"
  set icons(PROJECT-ICONI) [image create photo imgobj2 -file $icons(PROJECT-ICON)]
  set icons(PUBLICF-ICON) "$ICONDIR/public-folder.png"
  set icons(PUBLICF-ICONI) [image create photo imgobj3 -file $icons(PUBLICF-ICON)]
  set icons(PRIVATEF-ICON) "$ICONDIR/private-folder.png"
  set icons(PRIVATEF-ICONI) [image create photo imgobj4 -file $icons(PRIVATEF-ICON)]
  set icons(HTML-ICON) "$ICONDIR/file-html.png"
  set icons(HTML-ICONI) [image create photo imgobj5 -file $icons(HTML-ICON)]
  set icons(JS-ICON) "$ICONDIR/file-js.png"
  set icons(JS-ICONI) [image create photo imgobj6 -file $icons(JS-ICON)]  
  set icons(IMG-ICON) "$ICONDIR/image.png"
  set icons(IMG-ICONI) [image create photo imgobj7 -file $icons(IMG-ICON)]
  set icons(CSS-ICON) "$ICONDIR/file-css.png"
  set icons(CSS-ICONI) [image create photo imgobj8 -file $icons(CSS-ICON)]
  set icons(PHP-ICON) "$ICONDIR/file-php.png"
  set icons(PHP-ICONI) [image create photo imgobj9 -file $icons(PHP-ICON)]
  set icons(TXT-ICON) "$ICONDIR/file-txt.png"
  set icons(TXT-ICONI) [image create photo imgobj10 -file $icons(TXT-ICON)]
  set icons(GENERIC-FILE-ICON) "$ICONDIR/file-generic.png"
  set icons(GENERIC-FILE-ICONI) [image create photo imgobj11 -file $icons(GENERIC-FILE-ICON)]
  set icons(FOLDER-ICON) "$ICONDIR/folder.png"
  set icons(FOLDER-ICONI) [image create photo imgobj12 -file $icons(FOLDER-ICON)]
  
  # Menu variables
  set menu(ROOT) "";
  set menu(ADD_FILE_ENTRY_IDX) 2;
  set menu(SAVE_AS_ENTRY_IDX) 4;
  set menu(SAVE_ENTRY_IDX) 5;
  set menu(CLOSE_ENTRY_IDX) 7;
  set menu(CLOSE_PROJECT_ENTRY_IDX) 8;      
  set menu(UNDO_ENTRY_IDX) 0;
  set menu(REDO_ENTRY_IDX) 1;
  set menu(COPY_ENTRY_IDX) 3;
  set menu(PASTE_ENTRY_IDX) 4;
  set menu(CUT_ENTRY_IDX) 5;
  set menu(INDENT_ENTRY_IDX) 7;
  set menu(UNINDENT_ENTRY_IDX) 8;
  set menu(FIND_ENTRY_IDX) 10;    
  set menu(GOTO_ENTRY_IDX) 11;
  
  # a couplle of extension definitions..
  set dan(PhpExts) {.php .php2 .php3 .php4 .php5 .inc}            ;# extensions of php files
  set dan(HtmlExts) {.html .htm .xml .xsl}                        ;# extensions of html files
  set dan(CssExts) {.css}                                         ;# extensions of css files
  set dan(JsExts) {.js}                                           ;# extensions of js files
  set dan(TxtExts) {.txt .rtf}                                    ;# extensions of txt files
  set dan(ImgExts) {.gif .png .jpg .jpeg .ico}                    ;# extensions of images
  set dan(OfficeExts) {.doc .docx .xls .xlsx .ppt .pptx}          ;# extensions of office files
  set dan(BinExts) {.so .o .exe}                                  ;# extensions of binary
     
# __________________ iswindows ___________________ #


	proc iswindows {} {
		# Checks for "platform is MS Windows".

		expr {$::tcl_platform(platform) eq {windows}}
	}

# __________________ quit ___________________ #


  proc quit {{w ""} {res 0} {ask yes}} {
    # Closes alited application.
    #   w - not used
    #   res - result of running of main window
    #   ask - if "yes", requests the confirmation of the exit
    
    set answer [tk_messageBox -message "Really quit RADXIDE?" \
        -icon question -type yesno \
        -detail "Select \"Yes\" to make the application exit"]
        
    switch -- $answer {
       yes exit 0
       no
    }    
    
    return
  }

# __________________ raise_window ___________________ #


  proc raise_window {} {
    # Raises the app's window.

    variable dan
    catch {
      wm withdraw $dan(WIN)
      wm deiconify $dan(WIN)
    }
  }

# __________________ Tclexe ___________________ #


  proc Tclexe {} {
    # Gets Tcl's executable file.

    variable dan
  
    set tclexe [info nameofexecutable]
  
    return $tclexe
  }

  
  source [file join $SRCDIR main.tcl]
  source [file join $SRCDIR filelib.tcl]
  source [file join $SRCDIR win.tcl] 
  source [file join $SRCDIR menu.tcl]
  source [file join $SRCDIR tree.tcl]
  source [file join $SRCDIR eglib.tcl] 
   
  ## _ EONS: radxide _ ##
}  

# ________________________ ::argv, ::argc _________________________ #


set ::radxide::ARGV $::argv
set ::radxide::dan(IsWindows) [expr {$::tcl_platform(platform) eq {windows}}]

# _________________________ Run the app _________________________ #


namespace upvar ::radxide dan dan

radxide::main::_create  ;# create the main form
unset -nocomplain _

if {[catch {set res [radxide::main::_run]} err]} {
  set res 0
  set msg "\nERROR in radxide:"
  puts \n$msg\n\n$::errorInfo\n
  set msg "$msg\n\n$err\n\nPlease, inform authors.\nDetails are in stdout."
  tk_messageBox -title $dan(TITLE) -icon error -message $msg
  exit 2
}

exit 0
# _________________________________ EOF _________________________________ #
