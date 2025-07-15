# Aliases for Android file system navigation
alias root='cd /'
alias sdcard='cd ~/storage/shared'  # Points to /storage/emulated/0, equivalent to /sdcard
alias home='cd ~/storage/shared'
alias downloads='cd ~/storage/shared/Download'
alias docs='cd ~/storage/shared/Documents'
alias pics='cd ~/storage/shared/Pictures'
alias music='cd ~/storage/shared/Music'
alias videos='cd ~/storage/shared/Movies'

# Custom folders
alias notes='cd ~/storage/shared/notes'
alias todo='cd ~/storage/shared/todo-list'

# Utility aliases
alias ls='ls'          # Default ls command
alias back='cd ..'     # Go up one directory
alias home='cd ~'      # Go to home directory
alias update='pkg update && pkg upgrade'  # Update and upgrade packages (for Termux)
alias clear='clear'    # Clear terminal screen
alias x='exit'         # Exit the terminal
alias source='source .bashrc'  # Updates the bash config
case ":$PATH:" in
    *":$HOME/bin:"*) ;;
    *) export PATH=$PATH:$HOME/bin ;;
esac

# Nightride FM channel aliases
alias horrorsynth='nightride horrorsynth'
alias synthwave='nightride synthwave'
alias rekt='nightride rekt'
alias rektory='nightride rektory'
alias rektify='nightride rektify'
alias chillsynth='nightride chillsynth'
alias datawave='nightride datawave'
alias spacesynth='nightride spacesynth'
alias stopradio='stopradio'
