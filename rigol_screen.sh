#/bin/bash

ff=false
ip=0

while [ $# -gt 0 ]
do
    case $1 in
        -a|--address)
        ip=$2
        ;;
        -h|--help)
        echo "Help"
        ;;
        -f|--filename)
        filename=$2
        ff=true
        ;;
    esac
    shift
done

if [ "$ff" = false ]
then
    filename=$(date +"%d-%m-%y_%T.bmp")
fi

if [ "$ip" = 0 ]
then
    echo "No address"
else
    echo ':display:data?' | netcat -w 20 $ip 5555 | tail -c +12 > $filename
fi    
