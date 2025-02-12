#!/bin/bash

function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}

function json_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${P1PORT}/$7/" \
        -e "s/\${ORGC}/$6/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        ccp-template.json
}

function yaml_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${P1PORT}/$7/" \
        -e "s/\${ORGC}/$6/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        ccp-template.yaml | sed -e $'s/\\\\n/\\\n          /g'
}

ORG=manufacturer
ORGC=Manufacturer
P0PORT=9051
P1PORT=10051
CAPORT=7054
PEERPEM=crypto-config/peerOrganizations/manufacturer.vrs.com/tlsca/tlsca.manufacturer.vrs.com-cert.pem
CAPEM=crypto-config/peerOrganizations/manufacturer.vrs.com/ca/ca.manufacturer.vrs.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $ORGC $P1PORT)" > crypto-config/peerOrganizations/manufacturer.vrs.com/connection-profile-manufacturer.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $ORGC $P1PORT)" > crypto-config/peerOrganizations/manufacturer.vrs.com/connection-profile-manufacturer.yaml

