#/run/media/simha/3332-6130

set -x -o verbose;

cd /home/administrator/tmp

url=$1

today=`date +"%Y-%m-%dT%H__%M__%S"`

#format='best'

#format='hls-360p/hls-480p/hls-540p/hls-250p/mp4-low'

#format='worstvideo[height>=400]+worstaudio'

#format='worstvideo[height>=300]+worstaudio'

#format='worstvideo[height>=300]'

#format='worstvideo[height>=300]+bestaudio'

#format='491/492/493/494/495/496/497/498/499/0'

#format='worstvideo[height>=1000]+worstaudio/bestvideo+worstaudio'

#format='bestvideo+worstaudio'

format='worstvideo[height>=1000]+bestaudio/best'

#format='worstvideo[height>=1000]'

#format='133+worstaudio'
#format='136/worstvideo[height>=300]+worstaudio'

#format='worst'

#format='bestaudio'

#format='[height>=300]'

#yt-dlp --restrict-filenames --no-part --no-mtime --verbose -f "${format}" -o "$(date +"%Y-%m-%dT%H__%M__%S")-%(title)s-%(id)s-%(format_id)s.%(ext)s" "${url}"

datet=`date +"%Y-%m-%dT%H__%M__%S"`

#yt-dlp --restrict-filenames --no-part --no-mtime --verbose -o "${datet}.mp4" "${url}"

# ffmpeg -i "${datet}.mp4" -f null -
# if [ $? -eq 1 ]
# then
#   rm -rf "${datet}.mp4"
# else
#   mv "${datet}.mp4" ../tmp2/"${datet}.mp4"
# fi


#yt-dlp -F "${url}"

#docker run --rm \
#--network="avpn" \
#--env="_JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=lcd'" \
#--env="DISPLAY=${DISPLAY}" \
#--volume="/home/administrator/.public_html/youtube_cookies:/home/simha/youtube_cookies" \
#--volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
#--volume="/home/administrator/tmp:/home/simha/tmp:rw" \
#archlinux_custom:base-devel-20220320.0.50753 /bin/sh -c "curl http://www.myip.ch; cd tmp;yt-dlp --continue --cookies /home/simha/youtube_cookies/youtube.com_cookies.txt --restrict-filenames --no-part --no-mtime --verbose -f '${format}' -o ${today}-%\(title\)s-%\(id\)s.%\(ext\)s ${url}"

yt-dlp --continue --cookies /home/administrator/.public_html/youtube_cookies/youtube.com_cookies.txt --restrict-filenames --no-part --no-mtime --verbose -f "${format}" -o "${today}-%(title)s-%(id)s.%(ext)s" "${url}"

#echo "${url}"

## ##########################################
## # FOR da begins
## ##########################################
## 
## yt-dlp --cookies /home/simha/.public_html/youtube.com_cookies.txt --restrict-filenames --no-part --no-mtime --verbose -f 0 -o "${today}.mp4" "${url}"
## 
## jq . "${today}.mp4"
## 
## PYCMD=$(cat <<EOF
## import json
## with open('${today}.mp4') as data_file:    
##     data = json.load(data_file)
##     urls_list=[]
##     for v in data['playlist']:
##         for m in v['sources']:
##             if m["label"] == "360p":
##                 urls_list.append(m["file"][2:])
##     print(" ".join(urls_list))
## EOF
## )
## 
## 
## hare=`python3 -c "$PYCMD"`
## 
## echo ${hare}
## 
## rm -rf "${today}.mp4"
## 
## # for x in $( echo "$hare" ):
## # do
## #     echo ${x}
## # done
## 
## COUNTER=0
## # Yes!. A var expansion is not split (by default) in zsh, but command expansions are.
## # https://unix.stackexchange.com/a/491459/187681
## for x in $( echo "$hare" ):
## do
##     echo $x
##     yt-dlp --restrict-filenames --no-part --no-mtime --verbose -o "${today}_${COUNTER}.mp4" $x
## 
##     ffmpeg -i "${today}_${COUNTER}.mp4" -f null -
## 	if [ $? -eq 1 ]
## 	then
## 	  rm -rf "${today}_${COUNTER}.mp4"
## 	fi
##     let COUNTER++
## done
## 
## ##########################################
## # FOR da ends
## ##########################################

# jq . "${today}.mp4"
# url2=`jq 'last(.playlist[]).sources[]|select(.label=="480p")| .file' "${today}.mp4"`
# url3=`echo ${url2} | sed 's/"//g'`
# url2=`echo ${url3} | sed 's/^\/\///g'`
# yt-dlp --cookies /home/simha/.public_html/youtube.com_cookies.txt --restrict-filenames --no-part --no-mtime --verbose -o "${today}_1.mp4" ${url2}

#timeout 120 yt-dlp --restrict-filenames --no-part --verbose -f "${format}" -o "$(date +"%Y-%m-%dT%H__%M__%S")-%(title)s-%(id)s.%(ext)s" "${url}"
