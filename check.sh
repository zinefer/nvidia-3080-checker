#!/bin/bash

PRODUCT_URL="https://www.nvidia.com/en-us/geforce/graphics-cards/30-series/rtx-3080/"
MONITOR_URL_BASE="https://api-prod.nvidia.com/direct-sales-shop/DR/products/en_us/USD"
OOS_STRING="PRODUCT_INVENTORY_OUT_OF_STOCK"
ALERT_URL="https://your-home-assistant:8123/api/webhook/some_hook_id"
SKU=$(cat .sku)

echo "MONITORING FOR SKU $SKU"

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

    if (( $LAST_MINUTE != $MINUTE )); then

        # Check for a new SKU every 5 minutes
        if [ $LAST_MINUTE == -1 ] || (( $MINUTE % 5 )); then
            NEW_SKU=$(curl -s $PRODUCT_URL | python parseForSku.py)
            if (( $NEW_SKU != $SKU )); then
                echo -e "\n$TIME NEW SKU FOUND $NEW_SKU"
                echo $NEW_SKU > .sku
                SKU=$NEW_SKU
            fi
        fi

        # Print a time header every 30 minutes
        if [ $LAST_MINUTE == -1 ] || (( ($MINUTE == 0 || $MINUTE == 30) )); then
            [ $LAST_MINUTE -gt -1 ] && echo ''
            echo -ne "$TIME "
        fi

        LAST_MINUTE=$MINUTE
    fi

    # Monitor our api every sleep seconds
    checkUrl $MONITOR_URL_BASE/$SKU $OOS_STRING
	if (( $? == 1 )); then
        echo -e "\n$TIME API SAYS 3080 IN STOCK"
        curl -X POST $ALERT_URL
    else
        echo -ne '.'
    fi

    sleep 30
done