#!/bin/bash
reset_color='\033[0m'
black='\033[0;30m'
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
purple='\033[0;35m'
cyan='\033[0;36m'
white='\033[0;37m'
darkgray='\033[1;30m'
lightred='\033[1;31m'
lightgreen='\033[1;32m'
lightyellow='\033[1;33m'
lightblue='\033[1;34m'
lightpurple='\033[1;35m'
lightcyan='\033[1;36m'
lightwhite='\033[1;37m'

print_red_msg() {
    echo -e "${red}$1${reset_color}"
}
print_green_msg() {
    echo -e "${green}$1${reset_color}"
}
print_yellow_msg() {
    echo -e "${yellow}$1${reset_color}"
}
print_blue_msg() {
    echo -e "${blue}$1${reset_color}"
}
print_purple_msg() {
    echo -e "${purple}$1${reset_color}"
}
print_cyan_msg() {
    echo -e "${cyan}$1${reset_color}"
}
print_white_msg() {
    echo -e "${white}$1${reset_color}"
}
print_darkgray_msg() {
    echo -e "${darkgray}$1${reset_color}"
}
print_lightred_msg() {
    echo -e "${lightred}$1${reset_color}"
}
print_lightgreen_msg() {
    echo -e "${lightgreen}$1${reset_color}"
}
print_lightyellow_msg() {
    echo -e "${lightyellow}$1${reset_color}"
}
print_lightblue_msg() {
    echo -e "${lightblue}$1${reset_color}"
}
print_lightpurple_msg() {
    echo -e "${lightpurple}$1${reset_color}"
}
print_lightcyan_msg() {
    echo -e "${lightcyan}$1${reset_color}"
}
print_lightwhite_msg() {
    echo -e "${lightwhite}$1${reset_color}"
}
