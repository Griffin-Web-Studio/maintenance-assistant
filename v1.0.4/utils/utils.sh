#!/bin/bash

#function to print message array from parameters it receives
print_message_array() {
    for i in "${@}"; do
        printf "$i"
    done
}

# Print Table
function printTable() {
    local -r delimiter="${1}"
    local -r data="$(removeEmptyLines "${2}")"

    if [[ "${delimiter}" != '' && "$(isEmptyString "${data}")" = 'false' ]]; then
        local -r numberOfLines="$(wc -l <<<"${data}")"

        if [[ "${numberOfLines}" -gt '0' ]]; then
            local table=''
            local i=1

            for ((i = 1; i <= "${numberOfLines}"; i = i + 1)); do
                local line=''
                line="$(sed "${i}q;d" <<<"${data}")"

                local numberOfColumns='0'
                numberOfColumns="$(awk -F "${delimiter}" '{print NF}' <<<"${line}")"

                # Add Line Delimiter

                if [[ "${i}" -eq '1' ]]; then
                    table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
                fi

                # Add Header Or Body

                table="${table}\n"

                local j=1

                for ((j = 1; j <= "${numberOfColumns}"; j = j + 1)); do
                    table="${table}$(printf '#| %s' "$(cut -d "${delimiter}" -f "${j}" <<<"${line}")")"
                done

                table="${table}#|\n"

                # Add Line Delimiter

                if [[ "${i}" -eq '1' ]] || [[ "${numberOfLines}" -gt '1' && "${i}" -eq "${numberOfLines}" ]]; then
                    table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
                fi
            done

            if [[ "$(isEmptyString "${table}")" = 'false' ]]; then
                echo -e "${table}" | column -s '#' -t | awk '/^\+/{gsub(" ", "-", $0)}1'
            fi
        fi
    fi
}

# Remove Empty Lines
function removeEmptyLines() {
    local -r content="${1}"

    echo -e "${content}" | sed '/^\s*$/d'
}

# Repeat String
function repeatString() {
    local -r string="${1}"
    local -r numberToRepeat="${2}"

    if [[ "${string}" != '' && "${numberToRepeat}" =~ ^[1-9][0-9]*$ ]]; then
        local -r result="$(printf "%${numberToRepeat}s")"
        echo -e "${result// /${string}}"
    fi
}

# Check if String is Empty
function isEmptyString() {
    local -r string="${1}"

    if [[ "$(trimString "${string}")" = '' ]]; then
        echo 'true' && return 0
    fi

    echo 'false' && return 1
}

# Trim String
function trimString() {
    local -r string="${1}"

    sed 's,^[[:blank:]]*,,' <<<"${string}" | sed 's,[[:blank:]]*$,,'
}

# Print Message
log_answer() {
    printf "[$(date)] \n\tTask: $task_name\n\t\tStep:\t\t$1\n\t\tAnswer:\t\t$2\n\n" >>$logFile
    # printTable "," "Time, Task, Step, Answare\n $(date), $task_name, $1, $2" >>$logFile
}

# Print Message
log_task() {
    printf "[$(date)] $1\n\n" >>$logFile
}

# Define the function center_heading_text
center_heading_text() {
    # Store the input text in the variable "text"
    local text="$1"

    # Store the length of the text in the variable "text_len"
    local text_len=${#text}

    # Calculate the amount of padding required on either side of the text
    # The amount of padding is equal to half the remaining space in the 80 columns, minus 2 to account for the equal signs on either end
    local padding_len=$(((80 - text_len) / 2 - 2))
    # echo $text_len
    # echo $padding_len

    # Initialize an empty string "padding" to store the padding
    local padding=""

    # Use a for loop to create the padding by appending equal signs to the string "padding"
    for ((i = 0; i < padding_len + 1; i++)); do
        padding="=$padding"
    done

    # Output the centered text with equal signs on either side
    printf "$padding $text $padding"

    # If the text length is odd, add an additional equal sign to the right side of the padding
    if ((text_len % 2 == 1)); then
        printf "="
    fi
}


# Generate Password
generate_password() {
  password=$(head -c "$1" /dev/random | base64 | tr -dc '[:alnum:][:punct:]')
  echo $password
}