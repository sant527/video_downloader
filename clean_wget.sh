# pkill -f -i xterm
# rm -rf /home/simha/.public_html/youtube_dl_download/*
#pkill -f -i youtube 
# pfkill -f -i url= 
# pkill -f -i mpv 
# pkill -f -i tmux 
# pkill -f -i cpulimited_sem
# pkill -f yt-dlp
pgrep -if tsp | awk '{system("kill -9 "$1)}'
pgrep -if mpv | awk '{system("kill -9 "$1)}'
pgrep -if yt-dlp | awk '{system("kill -9 "$1)}'
#xdotool search "youtube" windowkill
# rm /home/simha/.public_html/lockfile_yt_dont_delete/download*
# rm /home/simha/.public_html/lockfile_yt_down_dont_delete/download*
# rm -rf /home/simha_personal_data/multimedia_audio_video_image/Videos/fb_completed/*
# rm -rf /home/simha_personal_data/multimedia_audio_video_image/Videos/fb/*
# rm -rf /home/simha/terminator_screenshots/*
# rm -rf /home/simha/Downloads/other/*
# rm -rf /home/web_dev/radhanath_google_search/mapping/lockfile_yt_dont_delete/*
# rm -rf /home/simha/.config/mpv/watch_later/*
# rm -rf /home/web_dev/django_download/download/run-sh\?url=*
# rm -rf /home/simha_personal_data/programming_arch_firefox/extra/Unsorted/vid/tmp/*
# rm -rf /home/simha_personal_data/programming_arch_firefox/extra/Unsorted/vid/tmp2/*
rm -rf ~/tmp/*
#killall plasma-desktop 
#plasma-desktop &
# rm -rf /home/simha/.cache
tsp -K
tsp -S 5
#pgrep -if anydesk | awk '{system("kill -9 "$1)}'
#anydesk 44853458