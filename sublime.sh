rm ~/.config/sublime-text/Local/Session.sublime_session ~/.config/sublime-text/Local/'Auto Save Session.sublime_session' &

subl -a ~/.public_html ~/.public_html/test.txt -n

# the below is for any directory
#DIR=$(dirname "$1")
#xterm -hold -e "echo $DIR; ls -al $1" &
#subl -n -a $DIR $1
