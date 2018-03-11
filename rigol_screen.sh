echo $1

if [ -z "$1" ]
    then
        echo "No arguments"
else
    echo ':display:data?' | netcat -w 20 $1 5555 | tail -c +12 > capture.bmp
fi    
