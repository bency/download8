#!/bin/bash
factor=50
function usage {
    echo -e "Usage: $0 --comic-url=http://www.comicbus/html/xxx.html --start-vol=1 --end-vol=999"
}
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

if [ $# -eq 0 ];then
    clear
    echo -e "\033[35m貼上漫畫的介紹網址\033[m\033[1;31m(http://www.comicbus.com/html/xxxxx.html)\033[m:"
    read  url
    echo -e "\033[35m輸入起始集(話)數\033[m:"
    read vol_start
    echo -e "\033[35m輸入截止集(話)數\033[m"
    read vol_end
elif [ $# -eq 3 ];then
    for arg do
        case "$arg" in

        --comic-url=*) url=`echo "$arg" | sed -e 's/^[^=]*=//'` ;;

        --start-vol=*) vol_start=`echo "$arg" | sed -e 's/^[^=]*=//'` ;;

        --end-vol=*) vol_end=`echo "$arg" | sed -e 's/^[^=]*=//'` ;;
        esac
    done
    if [[ ! $url =~ http://www.comicbus.com/html/[0-9]*\.html ]];then
        usage
        exit
    fi
    if [[ ! $vol_start =~ (^[0-9]{1,}$) ]];then
        echo $vol_start
        usage
        exit
    fi
    if [[ ! $vol_end =~ (^[0-9]{1,}$) ]];then
        usage
        exit
    fi
else
    usage
    exit
fi
# get total vol index

#echo -e "\033[35m取得漫畫分類\033[m"
printf "%s" "正在取得漫畫介紹頁面"
wget $url -O count_vol.html -o wget.log
error=$(grep --color=no "Not Found" wget.log)
if [[ ! $error = "" ]];then
    echo
    echo "無法取得漫畫介紹網頁 請聯絡作者 bency80097@gmail.com"
    rm index.html comicview.js get_name.html count_vol.html wget.log
    exit;
else
    printf "%s" ".........OK"
    echo 
fi
orign_lc_ctype=$LC_CTYPE
export LC_CTYPE=C

iconv -f BIG-5 -t UTF-8 count_vol.html > get_name.html
comic_name=$(grep --color=no '12pt' get_name.html | sed 's/.*d;">\(.*\)<\/font> .*/\1/')
if [[ $comic_name == "" ]]
then
    echo "無法取得漫畫名稱";
    rm index.html comicview.js get_name.html count_vol.html wget.log
    export LC_CTYPE=$orign_lc_ctype
    exit;
fi

echo -e "\033[35m漫畫名稱\033[m:\t$comic_name"
echo -e "\033[35m起始集(話)數\033[m:\t$vol_start"
echo -e "\033[35m截止集(話)數\033[m:\t$vol_end"

vol=$(grep --color=no "cview" count_vol.html | sed -e 's/.*="cview(\(.*\));.*/\1/g' | sed -e "s/'//g"| sed -e '/<script/d')

printf "%s" "正在取得級數目錄"
if [[ $vol = "" ]];then
    echo
    echo "無法取得集數目錄 請聯絡作者 bency80097@gmail.com"
    export LC_CTYPE=$orign_lc_ctype
    exit;
else
    printf "%s" ".........OK"
    echo 
fi

catid=$(echo $vol | cut -d ' ' -f1 | cut -d ',' -f2)

printf "%s" "正在取得漫畫分類 catid"
if [[ $catid = "" ]];then
    echo
    echo "無法取得漫畫分類 catid 請聯絡作者 bency80097@gmail.com"
    export LC_CTYPE=$orign_lc_ctype
    exit;
else
    printf "%s" ".......OK"
    echo 
fi

id=$(echo $url | cut -d '/' -f5 | cut -d '.' -f1)
printf "%s" "正在取得漫畫分類 id"
if [[ ! $id =~ (^[0-9]{1,}$) ]];then
    echo "無法取得漫畫id 請聯絡作者 bency80097@gmail.com"
    export LC_CTYPE=$orign_lc_ctype
    exit;
else
    printf "%s" ".........OK"
    echo 
fi

wget http://www.comicbus.com/js/comicview.js  -o wget.log
vol_url=$(grep --color=no "\<$catid\>" comicview.js | sed -e 's/.*baseurl="\(.*\)".*/\1/')
vol_url="http://www.comicbus.com$vol_url$id.html?ch=1"


wget -O index.html $vol_url  -o wget.log
allcodes=$(grep --color=no -oh "cs='[a-z0-9]*'" index.html | sed -e "s/cs='\(.*\)'/\1/g")
export LC_CTYPE=$orign_lc_ctype
if [[ $allcodes = "" ]];then
    echo "找不到單本（話）下載網址，請與作者聯絡 bency80097@gmail.com"
    rm index.html comicview.js get_name.html count_vol.html wget.log
    exit
fi
total_vol=$((${#allcodes}/factor - 1))

rm index.html comicview.js get_name.html count_vol.html wget.log

total_page=0
for ((i=$vol_start;i<=$vol_end;i++)); do
    vol_hash=$(volHash $allcodes $i)
    page=$(ss $vol_hash 7 3);
    total_page=$((total_page + page))
done

echo -e "\n\033[35m開始下載\033[m:\t"$comic_name
page_percentage=0
for ((vol=$vol_start;vol<=$vol_end;vol++)); do

    vol_hash=$(volHash $allcodes $vol)
    pages=$(ss $vol_hash 7 3);
    sid=$(ss $vol_hash 4 2)
    did=$(ss $vol_hash 6 1)

    vol_path=$comic_name"/vol-$vol"
    mkdir -p $vol_path

    for ((page=1;page<=$pages;page++)); do
        code=$(ss $vol_hash $(($(mm $page)+10)) 3 $factor)
        page_percentage=$((page_percentage+1))
        total_percentage=$((page_percentage*100/total_page))
        vol_percentages=$((page*100/pages))
        if [ $page -lt 10 ];then
            img="00$page"
            elif [ $page -lt 100 ];then
            img="0$page"
            else
            img=$page;
        fi
        m=$((((page-1)/10)%10 + ((page-1)%10)*3))
        pic_name=$img
        img=$img"_"$code".jpg"
        pic_url="http://img$sid.8comic.com/$did/$id/$vol/$img"
        wget -c -O "$vol_path/$pic_name.jpg" $pic_url -o wget.log
        clear
        echo -e "\033[35m漫畫名稱\033[m:\t$comic_name"
        echo -e "\033[35m起始集(話)數\033[m:\t$vol_start"
        echo -e "\033[35m截止集(話)數\033[m:\t$vol_end"
        if [ $pages -lt 60 ];then
            echo -e "\033[35m正在下載\033[33m第$vol 話\033[m \033[35m第\033[33m$page/$pages\033[35m頁\033[m"
        else
            echo -e "\033[35m正在下載\033[33m第$vol 集\033[m \033[35m第\033[33m$page/$pages\033[35m頁\033[m"
        fi
        progress_bar $total_percentage 1
        echo ""
        progress_bar $vol_percentages 2
    done
done
