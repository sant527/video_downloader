- required softwares

- install sublime text
```
sudo apt update && sudo apt install sublime-text
```

- create ~/.public_html and test.txt file inside it
- create script to start sublime text sublime.sh inside ~/.public_html
```
rm ~/.config/sublime-text/Local/Session.sublime_session ~/.config/sublime-text/Local/'Auto Save Session.sublime_session' &

subl -a ~/.public_html ~/.public_html/test.txt -n

# the below is for any directory
#DIR=$(dirname "$1")
#xterm -hold -e "echo $DIR; ls -al $1" &
#subl -n -a $DIR $1
```




- check python3
- install pipenv
```
sudo apt install pipenv
```
- install task-spooler
```
sudo apt-get install -y task-spooler
```

- Download the django_download.zip file
