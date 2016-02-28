#!/bin/bash
function progress_bar {
    percentage=$1
    option=$2
    case ${option} in
        1) color="\033[41m"
        ;;
        2) color="\033[42m"
        ;;
        3) color="\033[43m"
        ;;
        4) color="\033[44m"
        ;;
        5) color="\033[45m"
        ;;
        6) color="\033[46m"
        ;;
        7) color="\033[47m"
        ;;
        *) color="\033[41m"
        ;;
    esac
    width=$(tput cols)
    mid_width=$((width/2))
    progress=$((width*percentage/100))
    partial=$((progress/100))
    
    for((j=0;j<=progress;j++));do
        printf "\r"
    done

    if [ $progress -le $mid_width ];then

        printf "$color"
        for((j=0;j<$progress;j++));do

            printf " "
        done

        printf "\033[m"

        for((;j<mid_width;j++));do
            printf " "
        done

        printf "%3d%%" $percentage

 ####### fill out the rest space #########

        for((j=0;j<mid_width-3;j++));do
            printf " "
        done

    else

        printf "$color"
        for((j=0;j<mid_width;j++));do

            printf " "
        done

        diff=$((progress-mid_width-1))

        if [ $diff -eq 0 ];then

            printf "\033[m"
            printf "%d%%" $percentage

        elif [ $diff -eq 1 ];then

            printf "5\033[m%d%%" $((percentage%10))

        elif [ $diff -eq 2 ];then

            printf "5%d\033[m%%" $((percentage%10))

        elif [ $diff -eq 3 ];then

            printf "5%d%%\033[m" $((percentage%10))

        else

            printf "%3d%%" $percentage

            for((j=0;j<diff-3;j++));do

                printf " "
            done
            
            printf "\033[m"
        
        fi

 ####### fill out the rest space #########

            for((j=0;j<width-progress;j++));do
                printf " "
            done
    fi
}
function usage {
    echo -e "Usage: $0 --comic-url=http://www.comicbus/html/xxx.html --start-vol=1 --end-vol=999"
}

function volHash {
    comicHash=$1
    ch=$2
    cc=${#comicHash}
    for((i=0;i<cc/factor;i++));do
        if [ "$(ss $comicHash $((i*factor)) 4)" == "$ch" ]
        then
            echo $(ss $comicHash $((i*factor)) $factor $factor)
            exit;
        fi
    done
    echo $(ss $comicHash $(((i-1)*factor)) 4)
}
function ss {
    a=$1
    e=${a:$2:$3}
    if [ -z $4 ]
    then
        echo $e | sed "s/[a-zA-Z]//g"
    else
        echo $e
    fi
}

function mm {
    echo $((($1-1)/10%10+($1-1)%10*3))
}
