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

- copy shell101.sh into .public_html

- install yt-dlp
```
sudo apt install curl
sudo curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
sudo chmod a+rx /usr/local/bin/yt-dlp  # Make executable
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
- inside the folder
```
export PIPENV_VENV_IN_PROJECT=1
pipen install
```

- run django
```
 . /home/santhosh/.public_html/django_download/.venv/bin/activate &&  cd /home/santhosh/.public_html/django_download/download && ./manage.py runserver 0.0.0.0:8000
 ```

- If one wants multiple interfaces. use docker_routing.sh (to choose the internet for yt-dlp command)
