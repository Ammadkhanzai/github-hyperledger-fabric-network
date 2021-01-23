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

ORG=excise
ORGC=Excise
P0PORT=7051
P1PORT=8051
CAPORT=9054
PEERPEM=crypto-config/peerOrganizations/excise.vrs.com/tlsca/tlsca.excise.vrs.com-cert.pem
CAPEM=crypto-config/peerOrganizations/excise.vrs.com/ca/ca.excise.vrs.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $ORGC $P1PORT)" > crypto-config/peerOrganizations/excise.vrs.com/connection-profile-excise.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $ORGC $P1PORT)" > crypto-config/peerOrganizations/excise.vrs.com/connection-profile-excise.yaml

