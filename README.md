# RADXIDE
One more IDE but thought for RAD - Tcl-Tk &lt;= 8.6


Originally envisioned for RAD development in PHP...

The software check for the existance of the Working Dir
in /home/YourUser/.radxwork and must configured for this 
in radxide.tcl, variable dan(WORKDIR).

The "Code Library" of the window right pane needs the 
folder $dan(WORKDIR)/.snippets eg:<br> 
<br> 
/home/YourUser/.radxwork/.snippets<br><br>
and must be filled with your examples files tagged with 
one [tag] on their names. And containg a first line of 
#comment to give a the menu a descriptive nomenclature:<br>
<br>
~/.radxwork/.snippets/file[php].inc:<br>
#Example of PHP code<br>
phpinfo();<br>
<br>
RADXIDE and most of code here presented and distributed contains excerpts 
from [alited](https://github.com/aplsimple/alited by Alex Plotnikov and 
contributors to the project.
The original code of these excerpts could be 
borrowed from other sources which the author
and the contributors to this RadXIDE have no 
knowledge about.

Code Library scaffolding and most of its code 
contains excerpts from "Practical Programming in Tcl and Tk, 4th Ed."
by Brent B. Welch, Ken Jones, Jeffrey Hebbs.
The original code of these excerpts could be 
borrowed from other sources which the author
and the contributors to RadXIDE have no 
knowledge about. For the related copyright notice
refer to <eglib.tcl> part of this software.

License: MIT.<br>
Copyright (c) 2023-2024 5 Mode (Last implementation and adaptations.)<br>
Copyright (c) 2021-2023 Alex Plotnikov https://aplsimple.github.io (original scaffolding and excerpts.)

<br><br>

## Screenshot:

![RADXIDE in action #1](/res/screenshot1.png)<br><br><br>

Feedback: <a href="mailto:posta@elettronica.lol">posta@elettronica.lol</a>
