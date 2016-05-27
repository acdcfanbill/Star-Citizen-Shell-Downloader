# Star-Citizen-Shell-Downloader

This project requires bash, wget, awk, sed, grep, tr, cut and possibly some other \*nix utility I've forgotten.


To run: 

    chmod u+x star-citizen-downloader.sh
    ./star-citizen-downloader.sh

For Help:

    ./star-citizen-downloader.sh -h


Make sure you have enough space.  The script will automatically download the LIVE version.  If you want the PTU files you can pass the proper flag and it will download that instead. The script also has wget set to continue downloads so you can resume things. So it might continue or it might start over again on partial files.  I don't have the required time to investigate this at the moment.


If you want to see more info about what is going on, pass the verbose flag to the script and it will print out a bunch more info as it works.


If there's enough interest I may keep updating this, or add more functionality that people may ask for. Thanks very much to AntonLacon who did some much needed updates and cleanup to this script.


Updated 20160527

Shell test script by acdcfanbill, AntonLacon

This script is distributed in the hope that it will be useful,  
but WITHOUT ANY WARRANTY; without even the implied warranty of  
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
