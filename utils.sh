#!/usr/bin/env bash

BOLD='\e[1m'
BLUE='\e[34m'
RED='\e[31m'
YELLOW='\e[33m'
GREEN='\e[92m'
NC='\e[0m'

# Helper functions that help categorize the verbose outputs

info() {
    printf "\n${BOLD}${BLUE}====> $(echo $@ ) ${NC}\n"
}

error() {
    printf "\n${BOLD}${RED}====> $(echo $@ )  ${NC}\n"
    exit 1
}

success() {
    printf "\n${BOLD}${GREEN}====> $(echo $@ ) ${NC}\n"
}

print_error() {
  echo "Error on line $1"
}
