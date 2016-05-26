# Star-Citizen-Shell-Downloader

This project requires bash, curl, awk, sed, grep and possibly some other \*nix utility I've forgotten.


To run: 

    chmod u+x star-citizen-downloader.sh
    ./star-citizen-downloader.sh


Make sure you have enough space.  The script is interactive and will ask if you want Live/PTU relases and if the folders for the current release exist already exist, it will ask if you want to continue.  The script also has curl set to continue downloads so 'in-theory' you can resume things.  In practice it reports the webserver doesn't support resuming.  So it might just start over again on partial files.  I have no time to investigate right now.


If you want to see more info on what is going on, edit the script with your favorite editor (vim I'm assuming) and change the DEBUG variable to 1.


If there's enough interest I may keep updating this, or add functionality like bypassing the interactive parts with parameters.



Last updated 05/2016 - acdcfanbill
