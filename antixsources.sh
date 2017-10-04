#! /bin/bash
# File Name: antixsources.sh
# Purpose: script to set initial Debian repository (and antiX)
# Author: anticapitalista for antiX
# Latest Change: 03 March 2017
# Added options for up-coming Stretch repositories. 03 March 2017.
# Set default to Stretch.
##################################################################################

TEXTDOMAINDIR=/usr/share/locale 
TEXTDOMAIN=antixsources

export title="antixsources"

info_text=$"This tool sets your default Debian repository and then runs the installer.

You can choose between:

Stretch/Stable
Testing (Experts)
Sid/Unstable (Experts)

This release of antiX defaults to Stretch/Stable and antiX/Stretch.

If you do not know what to do, choose Cancel and the 
Stretch/Stable repositories will be used and the installer will begin.

Press OK to continue."

# width of progress dialogs
WIDTH=300

# edit Debian sources.list
function edit_sources
{
    # Stretch
    if [ "$stretch" = true ]; then
        echo "do nothing"
    fi
    # Testing
    if [ "$testing" = true ]; then
        sed -i -r "/testing/ s/^#+//" /etc/apt/sources.list.d/debian.list 
        sed -i -r "/http:.*multimedia\.org.* testing/ s/^([^#])/#\1/" /etc/apt/sources.list.d/debian.list    
        sed -i -r "/stretch/ s/^([^#])/#\1/" /etc/apt/sources.list.d/debian.list        
        sed -i -r "/deb-src/ s/^([^#])/#\1/" /etc/apt/sources.list.d/debian.list
        sed -i -r "/testing/ s/^#+//" /etc/apt/sources.list.d/antix.list 
        sed -i -r "/stretch/ s/^/#/" /etc/apt/sources.list.d/antix.list
    fi
    # Sid
    if [ "$sid" = true ]; then
        sed -i -r "/unstable/ s/^#+//" /etc/apt/sources.list.d/debian.list
        sed -i -r "/http:.*multimedia\.org.* unstable/ s/^([^#])/#\1/" /etc/apt/sources.list.d/debian.list    
        sed -i -r "/stretch/ s/^([^#])/#\1/" /etc/apt/sources.list.d/debian.list 
        sed -i -r "/testing/ s/^([^#])/#\1/" /etc/apt/sources.list.d/debian.list  
        sed -i -r "/deb-src/ s/^([^#])/#\1/" /etc/apt/sources.list.d/debian.list
        sed -i -r "/sid/ s/^#+//" /etc/apt/sources.list.d/antix.list 
        sed -i -r "/stretch/ s/^/#/" /etc/apt/sources.list.d/antix.list
    fi
}

function success
{
	# tell user 
	yad --image "info" --center --title "$title" --text=$"Your Debian and antiX repositories are set to $x"
}

function minstall
{
        yad --image "info" --center --title "$title" --text=$"The installer will now run."
        rsp=$?
        if [ $rsp != 0 ]; then
        exit 0
        else
        sudo fskbsetting
        fi
        sudo minstall
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
ans=$(yad --center --title "$title" \
             --width "$WIDTH" --height 220 \
             --list --separator=":" \
             --text $"Choose ONE repository for Debian and antiX" \
             --radiolist  --column $"Choose" --column $"Repository"\
              TRUE "Stretch" \
             FALSE "Testing" \
             FALSE "Sid")

#echo $ans

# transform the list separated by ':' into arr
arr=$(echo $ans | tr ":" "\n")

selected=""
for x in $arr
do
    #echo "> [$x]"
    case $x in
    Stretch)
        stretch='true'
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
