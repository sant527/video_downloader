#!/usr/bin/env bash

set -eu

dockerfile=$(mktemp)
trap "rm $dockerfile" EXIT
# we are escaping $ and \ with \$ and \\
cat << EOF > $dockerfile
FROM archlinux:base-devel-20220320.0.50753
RUN yes | pacman -Syy

# makepkg user and workdir
# check the below step what to replace with what
RUN sed -i 's@users:x:984:@users:x:1000:@g' /etc/group
ARG user=simha
RUN useradd --system -u 1000 -g 1000 -m \$user \\
  && echo "\$user ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/\$user
RUN chown simha:users /home/simha

USER \$user
WORKDIR /home/\$user

RUN yes |sudo pacman -S git --noconfirm

# Install yay
RUN git clone https://aur.archlinux.org/yay.git \\
  && cd yay \\
  && makepkg -sri --needed --noconfirm \\
  && cd \\
  # Clean up
  && rm -rf .cache yay
CMD /bin/bash

RUN yes | pacman -S wget --noconfirm

RUN sudo wget https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -O /usr/local/bin/yt-dlp

RUN sudo chmod a+rx /usr/local/bin/yt-dlp  # Make executable

RUN sudo pacman -S ffmpeg --needed --noconfirm


EOF

docker build -t arch_with_yay_with_yt_dlp - < $dockerfile
docker run -it --rm --name arch_with_yay_with_yt_dlp \
  arch_with_yay_with_yt_dlp
