#!/bin/bash

##Creates new podcast episode posts on LTR dev website
#Podcast conversion script callis this script whenever any files successfully uploaded onto S3, passing the file's S3 URL (https://s3.us-east-2.amazonaws.com/ltrpodcasts/PATH/TO/FILE).

#Read file's ID3 tags for podcast title, podcast album name, podcast description, podcast release date.
	
	#Loop through each file in "s3-uploads" folder.
	#for file in /var/downloads/podcasts/s3-uploads
	#do 
		cd /var/downloads/podcasts/ltr/education-currents/EC\ 2018/2018_09_Show_Line-up_for_Sept/
		post_title=$( eyeD3 --plugin=display -p "%t%" godspeed_voices-of-the-reformation-david-teems.mp3 )
		echo $post_title
		post_description=$( eyeD3 --plugin=display -p "%c%" godspeed_voices-of-the-reformation-david-teems.mp3 )
		echo $post_description
		post_year=$( eyeD3 --plugin=display -p "%recording-date%" godspeed_voices-of-the-reformation-david-teems.mp3 )
		echo $post_year
		podcast_name=$( eyeD3 --plugin=display -p "%a%" godspeed_voices-of-the-reformation-david-teems.mp3 )
		echo $podcast_name
		
		echo "$podcast_name" | sed -e 's/./\L&/g; s/ /-/g'
		podcast_name_lcns=$( echo "$podcast_name" | sed -e 's/./\L&/g; s/ /-/g' )
		echo $podcast_name_lcns

		taxonomy_term_1=$( echo "$post_year"-"$podcast_name_lcns" )
		echo $taxonomy_term_1
	#done

#Create variables of ID3 tags.

#SSH into dev server.

#Create new post of podcast episode.

#Add taxonomy terms to new post.


