#!/bin/bash

checkit() {
    if curl -s "$1" | grep -q "$2"; then
        return 0 # $2 exists in $1
    else
        return 1
    fi
}

c=0
while :
do  
    c=$(( c+1 ))
    if (( $c >= 10 )); then
        c=0
        echo ''
    fi

	checkit https://api-prod.nvidia.com/direct-sales-shop/DR/products/en_us/USD/5438481700 PRODUCT_INVENTORY_OUT_OF_STOCK
	if (( $? == 1 )); then
        echo 'API SAYS 3080 IN STOCK'
    else
        echo -ne '.'
    fi   
    
    sleep 30
done

