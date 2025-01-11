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
    echo -e "Continutul are acolade in plus!  \nEroare la linia: $ct caracterul $i"
    exit 1
    fi
    size=$(($size - 1))
    unset v[$size]
}

top()
{
    local size=${#v[@]}
       if [[ $size = 0 ]]; then
    echo -e "Continutul are acolade in plus!  \nEroare la linia: $ct caracterul $i"
    exit 1
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
#5 = )
#6 = } 
#7 = =
state=0
eg=0
fisier=$1
            loc=()
            l=()
ct=0
echo "" > "$OUTPUT_FILE"
while read -r line; do
    ct=$((${ct} + 1))
    w=()
    for (( i=0; i<${#line}; i++ )); do
        ch="${line:i:1}" 
        w+=("$ch")  
    done
    w+=(" ")
    for (( i=0; i<${#w[@]}; i++ )); do
        ch=${w[$i]}

        if [[ $state = 0 && "$ch" = '{' ]]; then
            echo -e "Tag-ul trebuie să inceapa cu un nume valid! \nEroare la linia: $ct caracterul $i"
            exit 1
        elif [[ $state = 1 && "$ch" = '{' ]]; then
            echo -e "Nu poti incepe continutul unui tag fara a specifica atributele acestuia! \nEroare la linia: $ct caracterul $i"
            exit 1
        elif [[ $state = 2 && "$ch" = '(' ]]; then
            echo -e "Paranteza deschisa nu este permisa aici! \nEroare la linia: $ct caracterul $i"
            exit 1
        elif [[ $state = 3 && "$ch" = ')' ]];then
            echo -e "Atribute nefinalizate! \nEroare la linia: $ct caracterul $i"
            exit 1
        elif [[ $state != 2 && "$ch" = ')' ]]; then
            echo -e "Paranteza închisa apare într-un loc nevalid sau nu are corespondenta! \nEroare la linia: $ct caracterul $i"
            exit 1
        elif [[ $state = 5 && "$ch" != '{' && "$ch" != ' ' ]]; then
            echo -e "Daca atribui un set de atribute trebuie sa incepi continutul tagului! \nEroare la linia: $ct caracterul $i"
            exit 1
        elif [[ $state != 5 && "$ch" = '{' ]]; then
            echo -e "Nu poti deschide continutul unui tag intr-o stare invalida! \nEroare la linia: $ct caracterul $i"
            exit 1
        elif [[ $state != 0 && "$ch" = '}' ]]; then
            echo -e "Nu poti închide continutul unui tag intr-o stare invalida! \nEroare la linia: $ct caracterul $i"
            exit 1
        elif [[ $state != 3 && "$ch" = '=' ]]; then
            echo -e "Semnul '=' trebuie să fie precedat de un nume de atribut! \nEroare la linia: $ct caracterul $i"
            exit 1
        elif [[ $eg = 7 && "$ch" != '"' && "$ch" != ' ' ]]; then
            echo -e "Semnul '=' trebuie sa fie urmat de valoarea un atribut! \nEroare la linia: $ct caracterul $i"
            exit 1
        elif [[ $state != 2 && $state != 3 && "$ch" = '"' ]]; then
            echo -e "Valorile intre ghilimele trebuie să fie parte a unui atribut valid! \nEroare la linia: $ct caracterul $i"
            exit 1
        fi


        if [[ "$ch" =~ [a-zA-Z0-9_] ]]; then
            eg=0
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
            eg=0

            afisare="<"
            afisare+=$(top)
            afisare1=""
            tabs=""
            for (( j=0; j<${#v[@]}; j = j+1 )); do
            tabs+="   "
            done
            for (( j=0; j<${#l[@]}; j = j+2 )); do
                afisare+=" ${l[$j]}"
                afisare+="=\""
                afisare+="${l[$(($j + 1))]}"
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
            eg=0
            state=2
            push "$nume"
        elif [[ "$ch" = ')' ]]; then
            eg=0
            state=5
        elif [[ "$ch" = '}' ]]; then
            eg=0
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
            eg=7
            state=2
        elif [[ "$ch" = '"' ]]; then
            l+=($nume)
            state=2
            eg=0
        elif [[ "$ch" = ' ' ]]; then
            if [[ $state = 1 ]]; then
                state=0
                loc+=($nume)
            fi

        fi
    done
done < "$fisier"
echo "Rezultat in: $OUTPUT_FILE"


            





