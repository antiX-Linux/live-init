#! /bin/bash
# File Name: antixsources.sh
# Purpose: script to set initial Debian repository (and antiX)
# Author: anticapitalista for antiX
# Latest Change: 26 December 2013
# Added options for antiX repositories. 25 October 2013.
##################################################################################

TEXTDOMAINDIR=/usr/share/locale 
TEXTDOMAIN=antixsources.sh

export title="antixsources"

info_text=$"This <b>$title</b> tool sets your default Debian and antiX repository and then runs the installer.\n\\n\
You can choose between: \n\\n\
<b>Wheezy/Stable</b>\n\\n\
<b>Testing</b> or \n\\n\
<b>Sid/Unstable</b>.\n\\n\
This release of antiX defaults to <b>Testing</b> and <b>antiX/Testing</b>.\n\\n\
If you do not know what to do, choose <b>Cancel</b> and the \n\
<b>Testing</b> repositories will be used and the installer will begin.\n\\n\
Press <b>OK</b> to continue."

# width of progress dialogs
WIDTH=300

# edit Debian sources.list
function edit_sources
{
    # Wheezy
    if [ "$wheezy" = true ]; then
        sed -i -r '/wheezy/ s/^#+//' /etc/apt/sources.list.d/debian.list 
        sed -i -r '/http:.*multimedia\.org.* testing/ s/^([^#])/#\1/' /etc/apt/sources.list.d/debian.list    
        sed -i -r '/testing/ s/^([^#])/#\1/' /etc/apt/sources.list.d/debian.list        
        sed -i -r '/deb-src/ s/^([^#])/#\1/' /etc/apt/sources.list.d/debian.list
        sed -i -r '/stable/ s/^#+//' /etc/apt/sources.list.d/antix.list 
        sed -i -r '/testing/ s/^/#/' /etc/apt/sources.list.d/antix.list
    fi
    # Testing
    if [ "$testing" = true ]; then
        echo "do nothing"
    fi
    # Sid
    if [ "$sid" = true ]; then
        sed -i -r '/unstable/ s/^#+//' /etc/apt/sources.list.d/debian.list
        sed -i -r '/http:.*multimedia\.org.* unstable/ s/^([^#])/#\1/' /etc/apt/sources.list.d/debian.list    
        sed -i -r '/wheezy/ s/^([^#])/#\1/' /etc/apt/sources.list.d/debian.list 
        sed -i -r '/testing/ s/^([^#])/#\1/' /etc/apt/sources.list.d/debian.list  
        sed -i -r '/deb-src/ s/^([^#])/#\1/' /etc/apt/sources.list.d/debian.list
        sed -i -r '/testing/ s/^#+//' /etc/apt/sources.list.d/antix.list 
        sed -i -r '/stable/ s/^/#/' /etc/apt/sources.list.d/antix.list
    fi
}

function success
{
	# tell user 
	yad --image "info" --center --title "$title" --text=$"Your Debian and antiX repositories are set to <b>$x</b>"
}

function minstall
{
        yad --image "info" --center --title "$title" --text=$"The installer will now run."
        rsp=$?
        if [ $rsp != 0 ]; then
        exit 0
        else
        sudo minstall
        fi
}

#=======================================================================
# main
#

# display message and ask to continue
yad --title "$title" --width "$WIDTH" --image "question" --center --text="$info_text"
rsp=$?

if [ $rsp != 0 ]; then
    minstall
    exit 0
fi

# selection dialog
ans=$(yad --title "$title" \
             --width "$WIDTH" --height 220 \
             --list --separator=":" \
             --text $"Choose <b>ONE</b> repository for Debian and antiX" \
             --checklist  --column $"Choose" --column $"Repository"\
             FALSE "Wheezy" \
              TRUE "Testing" \
             FALSE "Sid")

#echo $ans

# transform the list separated by ':' into arr
arr=$(echo $ans | tr ":" "\n")

selected=""
for x in $arr
do
    #echo "> [$x]"
    case $x in
    Wheezy)
        wheezy='true'
        selected='yes'
        ;;
    Testing)
        testing='true'
        selected='yes'
        ;;
    Sid)
        sid='true'
        selected='yes'
        ;;
    esac    
done

if [ -z $selected ]; then
    # nothing selected
    echo $"No item selected"
    exit 0
fi

edit_sources
success
minstall