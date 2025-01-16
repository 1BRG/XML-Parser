#!/bin/bash
stack=()

push() {
    local value="$1"
    stack+=("$value")
}

pop() {
    if [ ${#stack[@]} -eq 0 ]; then
        echo "ERROR L${linCont}C${colCont}: Too many close tags"
        exit 1
    fi
    
    local top_index=$(( ${#stack[@]} - 1 ))
    local value="${stack[$top_index]}"
    if [[ $value != $STRING ]];then
        echo "ERROR L${linCont}C${colCont}: Closing tag is not the same as opening tag"
        exit 1
    fi
    unset stack[$top_index]
}



# Path to XML file
XML_FILE=$1
OUTPUT_FILE=$2

echo "" > ${OUTPUT_FILE}

STATE=0
#0 = nu a inceput
#1 = tag
#2 = input tag
#3 = out tag
#4 = InnerText
#5 = tag Attributes
#6 = tag attribute value
#7 = tag attribute finish
linCont=0
STRING=""
ATTRIBUTESTRING=""

while read -r line; do
    linCont=$(($linCont+1))
    for (( colCont=0; colCont<${#line}; colCont++ )); do
        ch="${line:$colCont:1}"

        if [[ $STATE = 6 ]]; then
            if [[ ${ch} = '"' ]]; then 
               STATE=5 
            fi 
            ATTRIBUTESTRING+="${ch}"
        elif [[ ${ch} = '<' ]]; then 
            if [[ $STATE = 0 ]]; then 
                STRING=""
                STATE=1
            elif [[ $STATE = 4 ]]; then
                TABS=""
                for (( j=0; j<${#stack[@]}  ; j++ ))
                do
                    TABS+="   "
                done 
                echo "$TABS${STRING}" >> ${OUTPUT_FILE}
                STRING=""
                STATE=1
            elif [[ $STATE = 2 ]]; then
                echo "ERROR L${linConStack is empty!t}C${colCont}: tag is already open"
                exit 1
            elif [[ $STATE = 1 ]]; then
                echo "ERROR L${linCont}C${colCont}: tag is already open"
                exit 1
            elif [[ $STATE = 3 ]]; then
                echo "ERROR L${linCont}C${colCont}: tag is already open"
                exit 1
            fi
        elif [[ ${ch} = '/' ]]; then
            if [[ $STATE = 1 ]]; then
                STATE=3
            else
                echo "ERROR L${linCont}C${colCont}: file not well formated, \"/\" is not use correctly"
                exit 1
            fi
        elif [[ ${ch} = '>' ]]; then 
            if [[ $STATE = 2 ]] || [[ $STATE = 3 ]] || [[ $STATE = 5 ]]; then 
                if [[ $STATE = 2 ]] || [[ $STATE = 5 ]]; then
                    TABS=""
                    for (( j=0; j<${#stack[@]}  ; j++ ))
                    do
                        TABS+="   "
                    done 
                    push "${STRING}"
                    echo "${TABS}${STRING}(${ATTRIBUTESTRING}){" >> ${OUTPUT_FILE}
                else

                    pop #CHECK IF IS THE SAME TAG
                    TABS=""
                    for (( j=0; j<${#stack[@]}  ; j++ ))
                    do
                        TABS+="   "
                    done 
                    echo "${TABS}}" >> ${OUTPUT_FILE}
                fi
                ATTRIBUTESTRING=""
                STRING=""
                STATE=0
            else
                echo "ERROR L${linCont}C${colCont}: a tag is not open, wrong use of >"
                exit 1
            fi 
        elif [[ ${ch} = ' ' ]]; then
            if [[ $STATE = 2 ]]; then
                STATE=5
            elif [ $STATE = 5 ]; then
                ATTRIBUTESTRING+="${ch}"
            else
                STRING+="${ch}"
            fi 
        else
            if [ $STATE = 5 ]; then
                ATTRIBUTESTRING+="${ch}"
                if [ ${ch} = '"' ]; then
                    STATE=6
                fi
            else
                STRING+="${ch}" 
                if [ $STATE = 1 ]; then
                    STATE=2
                elif [ $STATE = 0 ]; then
                    STATE=4
                fi
            fi
        fi
    done

  
done < "$XML_FILE"

if [ ${#stack[@]} -ne 0 ]; then
    echo "ERROR: Unclosed tags detected: ${stack[@]}"
    exit 1
fi