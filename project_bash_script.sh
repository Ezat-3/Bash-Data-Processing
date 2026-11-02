#!/usr/bin/env bash
set -euo pipefail

log_message() {
	local color
	local reset='\033[0m'
	local timestamp
	local log_entry

	case "$1" in
	INFO) color='\033[0;34m' ;;
	SUCCESS) color='\033[0;32m' ;;
	WARNING) color='\033[0;33m' ;;
	ERROR) color='\033[0;31m' ;;
	*)
		echo "invalid log type: $1" >&2
		return 1
		;;
	esac

	timestamp=$(date '+%Y-%m-%d %H:%M:%S')
	log_entry="[$timestamp] [$1] $2"

	printf '%b%s%b\n' "$color" "$log_entry" "$reset"
	printf '%s\n' "$log_entry" >>/home/ezat/Projects_DevOps/bash-data-processing/logs/project.log

}

#log_message INFO "Starting process"
#log_message SUCCESS "File processed"
#log_message WARNING "Some rows were skipped"
#log_message ERROR "File not found"

validate_file() {
	local file="$1"

	if [[ ! -f "$file" ]]; then
		log_message ERROR "File does not exist or is not a regular file: $file"
		return 1

	elif [[ ! -r "$file" ]]; then
		log_message ERROR "File is not readable: $file"
		return 1

	elif [[ ! -s "$file" ]]; then
		log_message WARNING "File is empty: $file"
		return 1

	else
		log_message SUCCESS "File is valid: $file"
		return 0
	fi
}
#  if validate_file "data/sample.txt"; then
#    echo "Sample test finished"
#    fi
#
#   if validate_file "data/missing.txt"; then
#	        echo "Missing test finished"
#    fi
#
#   if validate_file "data/empty.txt"; then
#	        echo "Empty test finished"
#    fi
#
#   if validate_file "data"; then
#	        echo "Directory test finished"
#    fi

count_lines() {
	local file="$1"

	if validate_file "$file"; then
		local line_count
		line_count=$(wc -l <"$file")
		echo "${line_count}"
	fi

}
#count_lines "data/sample.txt"
#count_lines "data/same.txt"

extract_columns() {
	local file="$1"
	local column="$2"
	local invalid_column

	if ! validate_file "$file"; then
		return 1
	fi
	invalid_column=$(awk -F ',' -v cols="$column" '
        NF > 0 {
            n = split(cols, arr, ",")
            for (i = 1; i <= n; i++) {
                if (arr[i] > NF || arr[i] < 1) {
                    print arr[i]
                    exit
                }
            }
            exit
        }
    ' "$file")

	if [[ -n "$invalid_column" ]]; then
		log_message ERROR "Invalid column number: $invalid_column"
		return 1
	fi

	awk -F ',' -v cols="$column" '
        NF > 0 {
            n = split(cols, arr, ",")
            for (i = 1; i <= n; i++) {
                printf "%s%s", $(arr[i]), (i == n ? "\n" : ",")
            }
        }
    ' "$file"
}

#  if extract_columns 'data/data.csv' "1,2,4"; then
#      echo "Extraction completed successfully"
#   fi
#
#   if ! extract_columns 'data/data.csv' "1,8"; then
#      echo "Extraction failed, but the script will continue"
#   fi
#
#   if ! extract_columns 'data/missing.csv' "1,2"; then
#    echo "Extraction failed as expected"
#   fi

filter_data() {
	local file="$1"
	local pattern="$2"
	local status

	if ! validate_file "$file"; then
		return 1
	fi

	if grep -E -- "$pattern" "$file"; then
		return 0
	else
		status=$?

		if [[ $status -eq 1 ]]; then
			log_message WARNING "No matching records found."
			return 0
		else
			log_message ERROR "Failed to search file: $file"
			return "$status"
		fi
	fi
}
#filter_data "logs/project.log" "ERROR"
#filter_data "data/data.csv" "THIS_PATTERN_SHOULD_NOT_EXIST"
#filter_data "data/missing.csv" "ERROR"


calculate_stats(){
	local file="$1"
        local count minimum maximum average 
	if ! validate_file "$file"; then
		return 1
	fi

	count=$( wc -l <  "$file" )
	minimum=$( sort -n "$file" | head -1 )
	maximum=$( sort -n "$file" | tail -1 )
        average=$(  awk ' {sum=sum+$1  } END  { print sum / NR } ' "$file" )

	echo " Statistics "
	echo "-------------------"
	echo " count : $count  "
	echo " Minimum : $minimum  "
	echo " Maximum : $maximum  "
	echo " Average : $average  "



}

#calculate_stats "data/numbers.txt"

merge_files(){
local output_file="output/merged.txt"
	if [[ "$#" -lt 2  ]]; then
	       log_message ERROR "At least two files are required to merge."
		return 1
	fi

	for file in "$@" ;
	do
		if ! validate_file "$file"; then

		return 1

		fi
	done

    log_message INFO "Starting merging files..."
    cat "$@" > "$output_file"
    log_message SUCCESS "Files merged successfully into $output_file"	

 }

#merge_files "file1.missimg"
#merge_files "data/file1.txt" "data/file2.txt"

deduplicate(){
	local file="$1"
	local original unique duplicate
	if ! validate_file "$file" ; then 
	return 1 
	fi

	cat "$file" | sort | uniq > output/unique.txt


	original=$(wc -l < "$file")
	unique=$(cat "$file" | sort | uniq   | wc -l)
	duplicate=$(( original - unique))

	log_message INFO " Original line : $original   "
	log_message SUCCESS "Unique lines : $unique    "
	log_message SUCCESS " Dublicates removed : $duplicate  "

}
#deduplicate "data/data.txt"

command_exists(){
	local tool="$1"

	if command -v "$tool"  > /dev/null 2>&1  ; then 
		log_message SUCCESS "$tool is installed"
		return 0
	else 
		log_message ERROR "$tool is not installed"
		return 1
	fi


}

#command_exists "awk"
#command_exists "trysomthing"


check_dependencies(){
	local tool

	log_message INFO "cheking dependecies......"

	for tool in "$@";
	do
		if !  command_exists "$tool" ; then
			return 1


		fi



	done
	log_message SUCCESS "All required dependencies are installed"
	return 0


}

#check_dependencies "awk" "sed" "grep" "sort" "wc"

init_directories(){
	local dir_s=("data/" "output/" "logs/" )
	log_message INFO "Initializing directories.."

	for file in "${dir_s[@]}";
	do
		mkdir -p "$file"

	done
log_message SUCCESS "Required directories are ready."



}

trap 'log_message ERROR "Script interrupted by user."' INT
trap 'log_message ERROR "An unexpected error occurred."' ERR

#init_directories

main_menu() {
    local choice file cols pattern files

    while true; do
        echo
        echo "========================================"
        echo "      Bash Data Processing Toolkit"
        echo "========================================"
        echo "1. Count Lines"
        echo "2. Extract CSV Columns"
        echo "3. Filter Data"
        echo "4. Calculate Statistics"
        echo "5. Merge Files"
        echo "6. Remove Duplicates"
        echo "7. Check Dependencies"
        echo "8. Initialize Directories"
        echo "9. Exit"
        echo "========================================"

        read -rp "Choose an option: " choice

        case "$choice" in
            1)
                read -rp "Enter file path: " file
                count_lines "$file"
                ;;
            2)
                read -rp "Enter CSV file path: " file
                read -rp "Enter columns (e.g. 1,3): " cols
                extract_columns "$file" "$cols"
                ;;
            3)
                read -rp "Enter file path: " file
                read -rp "Enter regex pattern: " pattern
                filter_data "$file" "$pattern"
                ;;
            4)
                read -rp "Enter numeric file path: " file
                calculate_stats "$file"
                ;;
            5)
                read -rp "Enter files to merge (space-separated): " -a files
                merge_files "${files[@]}"
                ;;
            6)
                read -rp "Enter file path to deduplicate: " file
                deduplicate "$file"
                ;;
            7)
                check_dependencies "awk" "sed" "grep" "sort" "wc"
                ;;
            8)
                init_directories
                ;;
            9)
                log_message INFO "Exiting script. Goodbye!"
                exit 0
                ;;
            [0-9]*)
                log_message ERROR "Invalid choice."
                ;;
            *)
                log_message ERROR "Invalid option. Please enter a number between 1 and 9."
                ;;
        esac

        echo
        read -rp "Press Enter to continue..."
    done
}
main_menu


