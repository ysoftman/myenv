#!/bin/bash

download_ysoftman_youtube_music() {
    local music_path="$HOME/Downloads/music"
    mkdir -p $music_path
    # download-archive 파일에 이미 다운로드된 음악 hash 가 기록되어 이를 참고하면 중복 다운로드를 피할 수 있다.
    yt-dlp "https://www.youtube.com/playlist?list=PLxZefZxz0kXuZSbU4AQsIiES32Ddqbwbe" \
        --download-archive $music_path/download-archive \
        --extract-audio --audio-format mp3 \
        --audio-quality 0 \
        --restrict-filenames \
        --ignore-errors \
        -o "$music_path/%(playlist_title)s/%(title)s.%(ext)s"
    yt-dlp "https://www.youtube.com/playlist?list=PLxZefZxz0kXva-lM3tLP49r5zZQKC_w5C" \
        --download-archive $music_path/download-archive \
        --extract-audio --audio-format mp3 \
        --audio-quality 0 \
        --restrict-filenames \
        --ignore-errors \
        -o "$music_path/%(playlist_title)s/%(title)s.%(ext)s"
    yt-dlp "https://www.youtube.com/playlist?list=PLxZefZxz0kXt-LqxE7I2IJERF8-t_8FUT" \
        --download-archive $music_path/download-archive \
        --extract-audio --audio-format mp3 \
        --audio-quality 0 \
        --restrict-filenames \
        --ignore-errors \
        -o "$music_path/%(playlist_title)s/%(title)s.%(ext)s"
    yt-dlp "https://youtube.com/playlist?list=PLxZefZxz0kXt0zWX9cy0Gf5DcikcA4S01" \
        --download-archive $music_path/download-archive \
        --extract-audio --audio-format mp3 \
        --audio-quality 0 \
        --restrict-filenames \
        --ignore-errors \
        -o "$music_path/%(playlist_title)s/%(title)s.%(ext)s"
}

# 플레이 리스트 정보만 출력시
show_ysoftman_youtube_music_list() {
    local music_path="$HOME/Downloads/music"
    mkdir -p $music_path
    local music_list_file="$HOME/Downloads/music/ysoftman_youtube_music_list.txt"
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
