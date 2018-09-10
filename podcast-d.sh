#!/bin/bash

ftp_ip="108.31.40.11"
ftp_user="lifetalk"

this_year=$( date +%Y )
echo $this_year
this_mo_no=$( date +%m )
echo $this_mo_no
next_mo_no=$( date +%m --date="next month" )
echo $next_mo_no

podcast_name=("Education\ Currents" "Homeschool\ Companion");
echo ${podcast_name[*]}
echo ${podcast_name[1]}

cd /var/downloads/podcasts/ltr/education-currents/

#Path A: initial download of ALL files
#mirror Education\ Currents/ /var/downloads/podcasts/ltr/education-currents
#exit

#Path B: for cronjob
#lftp -e "mirror -cv --newer-than=now-4days Education\ Currents/EC\ 2018/2018_09_Show\ Line-up\ for\ Sept /var/downloads/podcasts/ltr/education-currents" -u $ftp_user,$ftp_pw $ftp_ip
#exit

filename_ns=$( prename 'y/ /_/' */*.mp3 )
#echo $filename_ns
#         filename_l=$( prename 'y/A-Z/a-z/' "$filename" )
#       echo $filename_l
#	filename_ok=$( prename 's/_ok././' "$filename_ns" )        
#	echo $filename_ok
#filename_b=$( basename "$filename_l" )
#echo $filename_b
#for mp3 in */*.mp3
#do
#	filename=$mp3
#	filename_b=$( basename "$filename_l" )
 #       echo $filename_b
#	filename_l=$( prename 'y/A-Z/a-z/' "$filename" )
#	echo $filename_l
	#filename_ns=$( prename 'y/ /_/' "$filename_l" )
	#echo $filename_ns
	#filename_ok=$( prename 's/_ok././' "$filename_ns" )
	#echo $filename_ok
	#echo ffmpeg -i $filename -codec:a libmp3lame -b:a 96k "$filename"
	#ffmpeg -i */$filename
#done  
