#!/bin/bash

download_ysoftman_youtube_music() {
    local music_path="$HOME/Downloads/music"
    mkdir -p $music_path
    yt-dlp "https://www.youtube.com/playlist?list=PLxZefZxz0kXuZSbU4AQsIiES32Ddqbwbe" \
        --download-archive $music_path/download-archive \
        --extract-audio --audio-format mp3 \
        --audio-quality 0 \
        -o "$music_path/%(playlist_title)s/%(title)s.%(ext)s"
    yt-dlp "https://www.youtube.com/playlist?list=PLxZefZxz0kXva-lM3tLP49r5zZQKC_w5C" \
        --download-archive $music_path/download-archive \
        --extract-audio --audio-format mp3 \
        --audio-quality 0 \
        -o "$music_path/%(playlist_title)s/%(title)s.%(ext)s"
    yt-dlp "https://www.youtube.com/playlist?list=PLxZefZxz0kXt-LqxE7I2IJERF8-t_8FUT" \
        --download-archive $music_path/download-archive \
        --extract-audio --audio-format mp3 \
        --audio-quality 0 \
        -o "$music_path/%(playlist_title)s/%(title)s.%(ext)s"
}

# 플레이 리스트 정보만 출력시
show_ysoftman_youtube_music_list() {
    local music_list_file="ysoftman_youtube_music_list.txt"
    rm -f $music_list_file
    yt-dlp "https://www.youtube.com/playlist?list=PLxZefZxz0kXuZSbU4AQsIiES32Ddqbwbe" \
        --skip-download \
        --print "%(playlist_title)s - %(title)s - %(webpage_url)s" | tee -a $music_list_file
    yt-dlp "https://www.youtube.com/playlist?list=PLxZefZxz0kXva-lM3tLP49r5zZQKC_w5C" \
        --skip-download \
        --print "%(playlist_title)s - %(title)s - %(webpage_url)s" | tee -a $music_list_file
    yt-dlp "https://www.youtube.com/playlist?list=PLxZefZxz0kXt-LqxE7I2IJERF8-t_8FUT" \
        --skip-download \
        --print "%(playlist_title)s - %(title)s - %(webpage_url)s" | tee -a $music_list_file
}
