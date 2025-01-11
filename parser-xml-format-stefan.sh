#!/bin/bash
stack=()


push() {
    local value="$1"
    stack+=("$value")
}

pop() {
    if [ ${#stack[@]} -eq 0 ]; then
        echo "Stack is empty!"
        return
    fi
    local top_index=$(( ${#stack[@]} - 1 ))
    local value="${stack[$top_index]}"
    unset stack[$top_index]
}
peek() {
    if [ ${#stack[@]} -eq 0 ]; then
        echo "Stack is empty!"
        return
    fi
    local top_index=$(( ${#stack[@]} - 1 ))
    echo "Top element: ${stack[$top_index]}"
}


display_stack() {
    echo " ${stack[@]}"
}



XML_FILE=$1
OUTPUT_FILE=$2



STATE=0
#0 = nu a inceput
#1 = tag
#2 = input tag
#3 = out tag
#4 = InnerText
#5 = tag Attributes

STRING=""
ATTRIBUTESTRING=""
while read -r line; do

    for (( i=0; i<${#line}; i++ )); do
        ch="${line:$i:1}"
        
        if [[ ${ch} = '<' ]]; then 
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
            fi
        elif [[ ${ch} = '/' ]]; then
            if [[ $STATE = 1 ]]; then
                STATE=3
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