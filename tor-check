#!/bin/sh
fail=$(printf " [\e[31m fail \e[0m]")
pass=$(printf " [\e[32m pass \e[0m]")

echo "Testing connection to Onion Pages ..."
curl --socks5-hostname localhost:9050 http://privacy34kn4ez3y3nijweec6w4g54i3g54sdv7r5mr6soma3w4begyd.onion/latest > /dev/null 2>&1
HC=$?
if [ $HC -ne 0 ]
then
        echo " ${fail}: Start9 Page not reachable."
elif [ $HC -eq 0 ]
then
        echo " ${pass}: Start9 Page reachable"
fi

curl --socks5-hostname localhost:9050 http://mempoolhqx4isw62xs7abwphsq7ldayuidyx2v2oethdhhj6mlo2r6ad.onion > /dev/null 2>&1
HC=$?
if [ $HC -ne 0 ]
then
        echo " ${fail}: Mampool Page not reachable."
elif [ $HC -eq 0 ]
then
        echo " ${pass}: Mempool Page reachable"
fi

curl --socks5-hostname localhost:9050 https://duckduckgogg42xjoc72x3sjasowoarfbgcmvfimaftt6twagswzczad.onion/ > /dev/null 2>&1
HC=$?
if [ $HC -ne 0 ]
then
        echo " ${fail}: DuckDuckGo Page not reachable."
elif [ $HC -eq 0 ]
then
        echo " ${pass}: DuckDuckGo Page reachable"
fi
echo
echo "Done."
