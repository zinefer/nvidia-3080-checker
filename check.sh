#!/bin/bash

MONITOR_URL="https://api-prod.nvidia.com/direct-sales-shop/DR/products/en_us/USD/5438481700"
OOS_STRING="PRODUCT_INVENTORY_OUT_OF_STOCK"
ALERT_URL="https://your-home-assistant:8123/api/webhook/some_hook_id"

checkUrl() {
    TS=$(date +%s)
    FILE=data/$TS

    curl -s "$1" > $FILE

    if cat $FILE | grep -q "$2"; then
        return 0 # $2 exists in $1
    else
        return 1
    fi
}

LAST_MINUTE=-1
while : ; do
    MINUTE=$(date +"%-M")
    TIME=$(date +"%H:%M")

    if [ $LAST_MINUTE -eq -1 ] ||
      (( $LAST_MINUTE != $MINUTE && ($MINUTE == 0 || $MINUTE == 30) ));
    then
        [ $LAST_MINUTE -gt -1 ] && echo ''
        echo -ne "$TIME "
        LAST_MINUTE=$MINUTE
    fi

	checkUrl $MONITOR_URL $OOS_STRING
	if (( $? == 1 )); then
        echo -e "\n$TIME API SAYS 3080 IN STOCK"
        curl -X POST $ALERT_URL
    else
        echo -ne '.'
    fi

    sleep 30
done