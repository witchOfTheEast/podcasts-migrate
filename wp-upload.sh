#!/bin/bash

##Creates new podcast episode posts on LTR dev website
#Podcast conversion script callis this script whenever any src_files successfully uploaded onto S3, passing the src_file's S3 URL (https://s3.us-east-2.amazonaws.com/ltrpodcasts/PATH/TO/FILE).

#Read src_file's ID3 tags for podcast title, podcast album name, podcast description, podcast release date.
	
#Loop through each src_file in "s3-uploads" folder.
#for src_file in /var/downloads/podcasts/s3-uploads

## randall replaced this logic iterating over files in a source director
## replaced with a csv file output from the upload-podcasts script
## csv file contacts src_file file path and name as well as the file url on s3

#src_dir="/var/downloads/podcasts/s3-uploads/"
#find "$src_dir" -type f -print0 |
#    while IFS= read -r -d $'\0' src_file; do
#cd "$src_dir"
#for src_file in $(ls "$src_dir"); do

usage() {
    echo -e "Usage: ${basename} /PATH/TO/OUTPUT_FILE_FROM_UPLOAD_SCRIPT\n"
    echo -e "expect file to be csv\nexpect each file line to have 2 fields\nexpect field 1 to be the full file path\nexpect filed 2 to be the upload url"

}

## $# is number of parameters passed on cli
if [[ $# != 1 ]]; then
    usage
    exit 1
fi

## checks if the supplied argument is a existing file
if ! [[ -f "$1" ]]; then
    usage
    exit 1
else
    echo "passed: received argument"
    output_file_from_upload="$1"
fi

while IFS='' read -r line; do

    if ! [[ $line =~ "****" ]]; then
        #echo $line
        src_file="$(echo "$line" | awk 'BEGIN{FS=OFS=","}{ print $1 }')"
        #echo "file:$src_file"
        file_url="$(echo "$line" | awk 'BEGIN{FS=OFS=","}{ print $2 }')"
        #echo "url:$file_url"

        echo -e "\nsrc_file is $src_file\n"

        #Create variables of ID3 tags.
        post_title=$( eyeD3 --plugin=display -p "%t%" "$src_file" 2> /dev/null)
        post_description=$( eyeD3 --plugin=display -p "%c%" "$src_file" 2> /dev/null)
                
        post_date=$( eyeD3 --plugin=display -p "%original-release-date%" "$src_file" 2> /dev/null)
        #echo "original ID3 date: $post_date"

        #Insure date is in the format:YYYY-MM-DD with a catch-all.
        #echo -e "\nactive date in question: $post_date"
        echo $post_date | egrep -o '[0-9]{4}-[0-9]{2}-[0-9]{2}'
        exitstatus=$?

        if [[ $exitstatus -ne 0 ]]; then
            #echo "$post_date didn't match accepted format"
                post_date=$( date "+%Y-%m-%d" )
            else
                #echo "format seemed okay. trying ''date'' on $post_date"
            date "+%Y-%m-%d" -d "$post_date" > /dev/null  2>&1
            date_exitstatus=$?
            if [[ $date_exitstatus -eq 1 ]]; then
                #echo "date seemed to think $post_date isn't a real date"
                post_date=$( date "+%Y-%m-%d" )
            fi
        fi
        #echo "at the end, our date is: $post_date"

        post_year=$( echo $post_date | egrep -o '[0-9]{4}' )
        #echo "this is just the year: $post_year"

        podcast_name=$( eyeD3 --plugin=display -p "%a%" "$src_file" 2> /dev/null)
        podcast_name_lcns=$( echo "$podcast_name" | sed -e 's/./\L&/g; s/ /-/g' )
        echo "podcast_name_lcns is: $podcast_name_lcns"
        taxonomy_child_term=$( echo "$post_year"-"$podcast_name_lcns" )
                

        #List of variables of podcast thumbnail images
        case $podcast_name_lcns in
            "american-indian-living")
                wp_thumbnail="1487"
                ;; 
            "bible-talk")
                wp_thumbnail="1502"
                ;; 
            "chip")
            wp_thumbnail="1668"
            ;;
            "education-currents")
            wp_thumbnail="1523"
            ;;
            "health-longevity")
                wp_thumbnail="1541"
                ;;
            "heartwise")
                wp_thumbnail="1545"
                ;;
            "homeschool-companion")
                wp_thumbnail="1547"
                ;;
            "lifequest")
            wp_thumbnail="1572"
            ;;
            "lifequest-liberty")
            wp_thumbnail="1670"
            ;;
            "message-of-hope")
            wp_thumbnail="2063"
            ;;
            "sink-the-beagle")
            wp_thumbnail="1650"
            ;;
            "someone-cares-prison-ministry")
            wp_thumbnail="1613"
            ;;
            *)
            echo "Error! Name doesn't match!"
            ;;
        esac

        echo $src_file
        
## original wp_meta
#        wp_meta=$( echo "--meta_input='{\"enclosure\":\""https://s3.us-east-2.amazonaws.com/ltrpodcasts/education-currents/2018/Godspeed-Voices-of-the-Reformation-David-Teems.mp3"\",\""_thumbnail_id"\":\""$wp_thumbnail"\"}'" )	

## randall modified wp_meta
        wp_meta=$(echo "--meta_input='{\"enclosure\":\""$file_url"\",\""_thumbnail_id"\":\""$wp_thumbnail"\"}'")	

        #SSH into dev server and create new post of podcast episode.
     #   echo "wp post create --post_content=\"$post_description\" --post_title=\"$post_title\" --post_date=\"$post_date\" --post_status=publish --post_type=podcasts $wp_meta --porcelain --path=/var/www/html/lifetalk.net/public_html/"

        #whole_line="$post_desc $post_date"

        #ssh "$whole_line"

        wp_post=$(ssh wp_cli_user@172.16.208.18 -i ~/id_wp_cli_user_rsa "wp post create --post_content=\"$post_description\" --post_title=\"$post_title\" --post_date=\"$post_date\" --post_status=publish --post_type=podcasts $wp_meta --porcelain --path=/var/www/html/lifetalk.net/public_html/" < /dev/null)
    echo -e "\nwp_post is this: $wp_post\n"

    echo "last $src_file"
    #Add taxonomy terms to new post.
        ssh wp_cli_user@172.16.208.18 -i ~/id_wp_cli_user_rsa "wp post term add $wp_post podcasts_cat $podcast_name_lcns $taxonomy_child_term  --path=/var/www/html/lifetalk.net/public_html/" < /dev/null


    fi

done < "$output_file_from_upload"
