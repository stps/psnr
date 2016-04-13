#!/bin/bash
clear
prompt="Select a file number:"
options=( $(gfind -maxdepth 1 -not -path '*/\.*' -name "*.mkv" -printf "%P\n"  | xargs -0) )

echo "Select a ground truth video:"
PS3="$prompt "
select gt in "${options[@]}" "Quit" ; do 
    if (( REPLY == 1 + ${#options[@]} )) ; then
        exit

    elif (( REPLY > 0 && REPLY <= ${#options[@]} )) ; then
        echo  "Analyzing against ground truth video $gt"
        break

    else
        echo "Invalid option. Try another one."
    fi
done    
mediainfo --Inform="General;Duration=%Duration/String3%\nFile size=%FileSize/String1%" "$gt"
mediainfo --Inform="Video;Resolution=%Width%x%Height%\nCodec=%CodecID%" "$gt"; 

echo ""
echo "Select a video to compare:"
select tt in "${options[@]}" "Quit" ; do 
    if (( REPLY == 1 + ${#options[@]} )) ; then
        exit

    elif (( REPLY > 0 && REPLY <= ${#options[@]} )) ; then
        echo  "Analyzing test video $tt"
        break

    else
        echo "Invalid option. Try another one."
    fi
done 

mediainfo --Inform="General;Duration=%Duration/String3%\nFile size=%FileSize/String1%" "$tt"
mediainfo --Inform="Video;Resolution=%Width%x%Height%\nCodec=%CodecID%" "$tt"; 

echo ""

vidSeek="0:04"

mpv --start=$vidSeek --frames=1 $gt --vo=image:format=png -ao null
mv 00000001.png 00000001gt.png
mpv --start=$vidSeek --frames 1 $tt --vo=image:format=png -ao null
mv 00000001.png 00000001tt.png

clear

compare -verbose -metric PSNR 00000001gt.png 00000001tt.png diff.png
