(es -r !"*Recycle.Bin*\*" !"*RECYCLE*\*" !"C:\Program*\*" *.sln | fzf --multi --header='Search - .NET Solutions (Tab to Select)') | Where-Object { Start-Process devenv -Argument """$_""" }
