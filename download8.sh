#!/bin/bash

function progress_bar {
    percentage=$1
    width=$(tput cols)
    mid_width=$((width/2))
    width=$((width*percentage/100))
    partial=$((width/100))
    
    for((j=0;j<=width;j++));do
        printf "\r"
    done

    if [ $width -lt $mid_width ];then

        printf "\033[41m"
        for((j=0;j<$width;j++));do

            printf " "
        done

        printf "\033[m"

        for((;j<mid_width;j++));do
            printf " "
        done

        printf "%%%d" $percentage

        for((j=0;j<mid_width-3;j++));do
            printf " "
        done

    else

        printf "\033[41m"
        for((j=0;j<mid_width;j++));do

            printf " "
        done

        diff=$((width-mid_width-1))

        if [ $diff -eq 0 ];then

            printf "\033[m"
            printf "%%%d" $percentage

        elif [ $diff -eq 1 ];then

            printf "%%\033[m%d" $percentage

        elif [ $diff -eq 2 ];then

            printf "%%5\033[m0"

        elif [ $diff -eq 3 ];then

            printf "%%50\033[m"

        else

            printf "%%%d" $percentage

            for((j=0;j<diff-3;j++));do

                printf " "
            done
            
            printf "\033[m"
        
        fi
    fi
}

orign_lc_ctype=$LC_CTYPE
export LC_CTYPE=C
read -p "Enter the introduction page of comic: " url
echo "Enter the start vol num"
echo "輸入起始集(話)數 "
read vol_start
echo "Enter the end vol num"
echo "輸入截止集(話)數"
read vol_end
echo $url
# get total vol index
wget $url -O count_vol.html -o wget.log
vol=$(grep --color=no "cview" count_vol.html | sed -e 's/.*="cview(\(.*\));.*/\1/g' | sed -e "s/'//g"| sed -e '/<script/d')
catid=$(echo $vol | cut -d ' ' -f 1 | cut -d ',' -f2)
id=`echo $url | cut -d '/' -f5 | cut -d '.' -f1`

iconv -f big5 -t utf8 count_vol.html > get_name.html
comic_name=$(grep --color=no '12pt' get_name.html | sed 's/.*d;">\(.*\)<\/font> .*/\1/')

wget http://www.8comic.com/js/comicview.js  -o wget.log
vol_url=$(grep --color=no "\<$catid\>" comicview.js | sed -e 's/.*baseurl="\(.*\)".*/\1/')
vol_url="$vol_url$id.html?ch=1"


#vol_url="http://www.8comic.com/show/cool-$id.html?ch=1";
wget -O index.html $vol_url  -o wget.log
allcodes=$(grep --color=no "allcodes" index.html | sed -e 's/.*allcodes="\(.*\)";sho.*/\1/g')

total_vol=$(grep -o "|" <<< $allcodes | wc -l)
total_vol=$((total_vol + 1))

rm index.html comicview.js get_name.html count_vol.html

echo "正在下載:"$comic_name
for ((i=1;i<=$total_vol;i++))
do
    num=$(echo $allcodes | cut -d '|' -f $i | cut -d ' ' -f 1)
    sid=$(echo $allcodes | cut -d '|' -f $i | cut -d ' ' -f 2)
    did=$(echo $allcodes | cut -d '|' -f $i | cut -d ' ' -f 3)
    page=$(echo $allcodes | cut -d '|' -f $i | cut -d ' ' -f 4)
    code=$(echo $allcodes | cut -d '|' -f $i | cut -d ' ' -f 5)

    if [ $num -ge $vol_start ] && [ $num -le $vol_end ];then

    vol_name=$comic_name"/vol-$num"
    mkdir -p $vol_name

    if [ $page -lt 60 ];then
    echo "正在下載第$num話"
    else
    echo "正在下載第$num集"
    fi

    for((p=1;p<=$page;p++))
    do
        percentage=$((p*100/page))
        if [ $p -lt 10 ];then
        img="00$p"
        elif [ $p -lt 100 ];then
        img="0$p"
        else
        img=$p;
        fi
        m=$((((p-1)/10)%10 + ((p-1)%10)*3))
        pic_name=$img
        img=$img"_"${code:$m:3}".jpg"
        pic_url="http://img$sid.8comic.com/$did/$id/$num/$img"
        wget -O "$vol_name/$pic_name.jpg" $pic_url -o wget.log
        progress_bar $percentage
    done

    fi
done

export LC_CTYPE=$orign_lc_ctype
