#!/bin/bash -ue

file="$1"

output_file="dest.img"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# echo "Writing $file to hypershare"

CR=$(echo -ne '\r')

(
cat - "$DIR/$file" <(echo -en "\r\n--$BOUNDARY--") << EOF
POST / HTTP/1.0$CR
Host: localhost$CR
Connection: close$CR
Content-Type: multpart/form-data;boundary="$BOUNDARY"$CR
$CR
--$BOUNDARY$CR
Content-Disposition: form-data; filename="$output_file"$CR
$CR
EOF
) | nc -t localhost $PORT | head -n1 | sed -e 's/^/ >>> response: /'

# echo "Comparing files"

res="$(md5sum "$DIR/$file" "$DIR/$output_file" | awk '{ print $1 }')"

res1=$(echo $res | awk '{ print $1 }')
res2=$(echo $res | awk '{ print $2 }')

if [[ "$res1" ==  "$res2" ]]
then
    echo -e "${GREEN}Passed${NC}"
else
    echo -e "${RED}Failed!!!${NC}"
    echo "Source: $res1"
    echo "Output: $res2"
fi

rm "$DIR/$output_file"
