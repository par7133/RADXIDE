# RADXIDE
One more IDE but thought for RAD.

<br>
Originally envisioned for RAD development in PHP...
<br><br>
RADXIDE checks for the existance of the Working Dir
in /home/YourUser/.radxwork.

The "Code Library" of the window right pane needs the 
folder $dan(WORKDIR)/.snippets eg:<br> 
<br> 
/home/YourUser/.radxwork/.snippets<br><br>
and must be filled with your example files tagged with 
one [tag] on their names and containg a first line of 
#comment to give a the menu a descriptive nomenclature:<br>
<br>
~/.radxwork/.snippets/file [php].inc:<br>
#Example of PHP code<br>
phpinfo();<br>
<br>
Please see "examples/_snippets"
<br><br>
RADXIDE enforces the following Project structure:<br>
/Private<br>
/Public<br>
<br>
Setting dan(MAXFILES) you define how many files max the
project can contain. Setting dan(MAXFILESIZE) you define the 
max size of the file RADXIDE can handle. 
The defaults are some good ones, but in the need you know what to change.
<br><br>
You can exclude folders from the project by adding 
their name to $dan(prjdirignore) 
eg {.git nbproject} in a way they are ignored by RADXIDE.<br> 
NB: files and folders in the root of the project are ignored by default.
<br><br><br>
RADXIDE and most of code here presented and distributed contains excerpts 
from [alited](https://github.com/aplsimple/alited) by Alex Plotnikov and 
contributors to the project.
The original code of these excerpts could be 
borrowed from other sources which the author
and the contributors of RADXIDE have no 
knowledge about.

Code Library scaffolding and most of its code 
contains excerpts from "Practical Programming in Tcl and Tk, 4th Ed."
by Brent B. Welch, Ken Jones, Jeffrey Hebbs.
The original code of these excerpts could be 
borrowed from other sources which the author
and the contributors of RADXIDE have no 
knowledge about. For the related copyright notice
refer to <eglib.tcl> part of this software.

<br>

License: MIT.<br><br>

Authors:<br>
RAXIDE, Daniele Bonini (Last implementation and adaptations.) <br>
Alited, Alex Plotnikov (original scaffolding and excerpts.) <br>
Tcler's Wiki (original excerpts.)

<br>

## Screenshot:

![RADXIDE in action #1](/res/screenshot1.png)<br><br><br>

Feedback: <a href="mailto:posta@elettronica.lol">posta@elettronica.lol</a>
