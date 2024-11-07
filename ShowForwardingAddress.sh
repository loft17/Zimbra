
#!/bin/bash
random_number=$RANDOM

zmprov -l gaa $1 > /tmp/EMAILS.$random_number

cat /tmp/EMAILS.$random_number | while read EMAIL; do
    FORWARD_EMAIL=`zmprov -l ga $EMAIL zimbraPrefMailForwardingAddress | grep -v "#" | awk '!/^$/' | awk -F": " '{print $2";"}' | tr -d '\n' | head -c-1`
    if [[ $FORWARD_EMAIL = "" ]]
        then
            echo "email: $EMAIL limpio"
            echo "email: $EMAIL limpio" >> /tmp/forwardemail.log.$random_number
        else
            echo "email: $EMAIL // $FORWARD_EMAIL"
            echo "email: $EMAIL // $FORWARD_EMAIL" >> /tmp/forwardemail.log.$random_number
    fi
done

rm /tmp/EMAILS.$random_number
