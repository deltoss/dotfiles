use ./modules/devenv.nu *

es /a-d -r !"*Recycle.Bin*\\*" !"*RECYCLE*\\*" !"C:\\Program*\\*" *.sln | fzf --multi '--header=Search - .NET Solutions (Tab to Select)' | lines | each { |it| devenv $it }