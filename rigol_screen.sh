#!/bin/bash

ip_def=false
file_flag=false

echo $#

while (( "$#" )); do
    case $1 in
        -h|-\?|--help)
            echo "RIGOL screen capture script"
            echo "-a, --address     Defines IP address of osciloscope."
            echo "                  If not defined script will scan LAN for RIGOL"
            echo "                  device."
            printf "\n"
            echo "-f, --file        Defines filename in current directory to which screenshoot will be saved."
            echo "                  If not defined, file will be saved in timestamp file in current directory."
            exit
            ;;
        -a|--address)
            echo "RIGOL IP address defined: $2"
            ip=$2
            ip_def=true
            ;;
        -f|--file)
            echo "Filename defined: $2"
            filename=$2
            file_flag=true
            ;;
    esac 
    shift
done

if [ "$1" = "-h" ]; then
    echo "Usage: $0 [filename]"
    exit
fi

if $ip_def; then
    echo "Manualy defined IP address"
else
    # Get the IP automatically - this will prompt for a password because of sudo usage
    ip=`sudo arp-scan -localnet | perl -ne 'print $1 if /(\S+).*Rigol/i'`
    if [ "$ip" = "" ]; then
        echo "Could not detect a Rigol device connected to the LAN. Aborting!"
        exit
    else
        echo "Found a Rigol at $ip"
    fi
fi

# The user can optionally supply a name for the capture
if [ $file_flag = true ]; then
    echo "Manualy defined filename"
else
    if [ "$filename" = "" ]; then
        # Generate a capture name if not supplied
        now=`date +%d%m%Y_%H%M%S`
        filename="capture_${now}"
    else
        # Otherwise just make sure no path/suffix is given
        filename=`basename $filename`
        filename=`echo $filename | sed -e 's/\..*//'`
    fi
    filename="${filename}.bmp"
fi

output_dir="$PWD"
mkdir -p $output_dir

# Capture
output="${output_dir}/$filename"
if [ -e $output ]; then
    echo "File $output already exists. Delete or move it first. Aborting!"
    exit
fi
echo -n "Capturing..."
echo ':display:data?' | netcat -w 20 $ip 5555 | tail -c +12 > $output
echo "done"

# Let the user know where the output is
echo "capture saved at '${output}'"