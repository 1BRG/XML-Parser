#!/bin/bash
v=()

push()
{
    local a="$1"
    v+=("$a")
}

pop()
{
    local size=${#v[@]}
    if [[ $size = 0 ]]; then
    echo "nasol"
    fi
    size=$(($size - 1))
    unset v[$size]
}

top()
{
    local size=${#v[@]}
       if [[ $size = 0 ]]; then
    echo "nasol"
    fi
    size=$(( $size - 1))
    echo "${v[$size]}"
}

OUTPUT_FILE="output.xml"

#0 = nu a inceput
#1 = tag sau element liber
#2 = (
#3 = id nume
#4 = atribut id
#5 = id nume
#4 = ) scot din stiva locala
#5 = = atribut id
#6 = } scot din stiva globala
state=0
fisier=$1
            loc=()
            l=()

while read -r line; do
    w=()
    for (( i=0; i<${#line}; i++ )); do
        ch="${line:i:1}" 
        w+=("$ch")  
    done
    w+=(" ")
    for (( i=0; i<${#w[@]}; i++ )); do
        ch=${w[$i]}
        if [[ "$ch" =~ [a-zA-Z0-9_] ]]; then
            if [[ $state = 0 ]]; then
                state=1
                nume=""
                nume+="$ch"
            elif [[ $state = 1 ]]; then
                nume+="$ch"
            elif [[ $state = 2 ]]; then
                state=3
                nume=""
                nume+="$ch"
            elif [[ $state = 3 ]]; then
                nume+="$ch"
            elif [[ $state = 4 ]]; then
                state=5
                nume=""
                nume+="$ch"
            fi
        elif [[ "$ch" = '{' ]]; then
            afisare="<"
            afisare+=$(top)
            afisare1=""
            tabs=""
            for (( j=0; j<${#v[@]}; j = j+1 )); do
            tabs+="   "
            done
            for (( j=0; j<${#l[@]}; j = j+2 )); do
                afisare+=" ${l[$j]}"
                afisare+="\""
                afisare+="=${l[$(($j + 1))]}"
                afisare+="\""
            done
            if [[ ${#loc[@]} > 0 ]]; then
            echo "${tabs}${loc[@]}" >> "$OUTPUT_FILE"
            fi
            
            loc=()
            l=()
            afisare+=">"
            echo "${tabs}$afisare" >> "$OUTPUT_FILE"
            state=0
        elif [[ "$ch" = '(' ]]; then
            state=2
            push "$nume"
        elif [[ "$ch" = '}' ]]; then
            state=0
            tabs=""
            for (( j=0; j<${#v[@]}; j = j+1 )); do
                tabs+="   "
            done
            if [[ ${#loc[@]} > 0 ]]; then
            echo "${tabs}${loc[@]}" >> "$OUTPUT_FILE"
            fi
            loc=()
            afisare="</"
            afisare+=$(top)
            pop
            afisare+=">"
            echo "${tabs}$afisare" >> "$OUTPUT_FILE"
        elif [[ "$ch" = '=' ]]; then
            state=2
        elif [[ "$ch" = '"' ]]; then
            l+=($nume)
            state=2
        elif [[ "$ch" = ' ' ]]; then
            if [[ $state = 1 ]]; then
                state=0
                loc+=($nume)
            fi

        fi
    done
done < "$fisier"
echo "Rezultat in: $OUTPUT_FILE"