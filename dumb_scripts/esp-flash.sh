#!/usr/bin/env bash

set -u

DEFAULT_PORT="/dev/cu.usbmodem101"
DEFAULT_BAUD="921600"
DEFAULT_ADDRESS="0x20000"
DEFAULT_BINARY="generated_assets.bin"

DRY_RUN=false

usage() {
    cat <<'EOF'
Usage: esp-flash.sh [--dry-run] [--help]

Interactively select a serial port, baud rate, flash address, and binary,
then write the binary with esptool.
EOF
}

die() {
    printf 'Error: %s\n' "$*" >&2
    exit 1
}

find_esptool() {
    if command -v esptool >/dev/null 2>&1; then
        ESPTOOL_COMMAND=(esptool)
    elif command -v esptool.py >/dev/null 2>&1; then
        ESPTOOL_COMMAND=(esptool.py)
    elif command -v python3 >/dev/null 2>&1 \
        && python3 -c 'import esptool' >/dev/null 2>&1; then
        ESPTOOL_COMMAND=(python3 -m esptool)
    else
        die "esptool was not found. Install it with: python3 -m pip install esptool"
    fi
}

choose_port() {
    local ports=()
    local port
    local choice
    local custom_number

    shopt -s nullglob
    for port in \
        /dev/cu.usbmodem* \
        /dev/cu.usbserial* \
        /dev/ttyUSB* \
        /dev/ttyACM*; do
        ports+=("$port")
    done
    shopt -u nullglob

    if ((${#ports[@]} == 0)); then
        read -r -p "Serial port [$DEFAULT_PORT]: " port
        SELECTED_PORT="${port:-$DEFAULT_PORT}"
        return
    fi

    printf '\nConnected serial ports:\n'
    for choice in "${!ports[@]}"; do
        printf '  %d) %s\n' "$((choice + 1))" "${ports[$choice]}"
    done
    custom_number=$((${#ports[@]} + 1))
    printf '  %d) Enter another port\n' "$custom_number"

    while true; do
        read -r -p "Choose a port [1]: " choice
        choice="${choice:-1}"

        if [[ "$choice" =~ ^[0-9]+$ ]] \
            && ((choice >= 1 && choice <= ${#ports[@]})); then
            SELECTED_PORT="${ports[$((choice - 1))]}"
            return
        fi

        if [[ "$choice" == "$custom_number" ]]; then
            read -r -p "Port path [$DEFAULT_PORT]: " port
            SELECTED_PORT="${port:-$DEFAULT_PORT}"
            return
        fi

        printf 'Please enter a number from 1 to %d.\n' "$custom_number"
    done
}

choose_baud() {
    local baud_rates=(921600 460800 230400 115200)
    local choice
    local baud

    printf '\nBaud rates:\n'
    printf '  1) 921600\n'
    printf '  2) 460800\n'
    printf '  3) 230400\n'
    printf '  4) 115200\n'
    printf '  5) Enter another baud rate\n'

    while true; do
        read -r -p "Choose a baud rate [1]: " choice
        choice="${choice:-1}"

        if [[ "$choice" =~ ^[1-4]$ ]]; then
            SELECTED_BAUD="${baud_rates[$((choice - 1))]}"
            return
        fi

        if [[ "$choice" == "5" ]]; then
            read -r -p "Baud rate [$DEFAULT_BAUD]: " baud
            baud="${baud:-$DEFAULT_BAUD}"
            if [[ "$baud" =~ ^[1-9][0-9]*$ ]]; then
                SELECTED_BAUD="$baud"
                return
            fi
            printf 'The baud rate must be a positive whole number.\n'
            continue
        fi

        printf 'Please enter a number from 1 to 5.\n'
    done
}

choose_address() {
    local address

    while true; do
        printf '\n'
        read -r -p "Flash memory address [$DEFAULT_ADDRESS]: " address
        address="${address:-$DEFAULT_ADDRESS}"

        if [[ "$address" =~ ^0[xX][0-9a-fA-F]+$ || "$address" =~ ^[0-9]+$ ]]; then
            SELECTED_ADDRESS="$address"
            return
        fi

        printf 'Enter a hexadecimal address such as 0x20000, or a decimal address.\n'
    done
}

choose_binary() {
    local binaries=()
    local binary
    local choice
    local custom_number

    shopt -s nullglob
    binaries=(*.bin)
    shopt -u nullglob

    if ((${#binaries[@]} == 0)); then
        printf '\n'
        read -r -p "Binary file [$DEFAULT_BINARY]: " binary
        SELECTED_BINARY="${binary:-$DEFAULT_BINARY}"
        return
    fi

    printf '\nBinary files in %s:\n' "$PWD"
    for choice in "${!binaries[@]}"; do
        printf '  %d) %s\n' "$((choice + 1))" "${binaries[$choice]}"
    done
    custom_number=$((${#binaries[@]} + 1))
    printf '  %d) Enter another file path\n' "$custom_number"

    while true; do
        read -r -p "Choose a binary [1]: " choice
        choice="${choice:-1}"

        if [[ "$choice" =~ ^[0-9]+$ ]] \
            && ((choice >= 1 && choice <= ${#binaries[@]})); then
            SELECTED_BINARY="${binaries[$((choice - 1))]}"
            return
        fi

        if [[ "$choice" == "$custom_number" ]]; then
            read -r -p "Binary path [$DEFAULT_BINARY]: " binary
            SELECTED_BINARY="${binary:-$DEFAULT_BINARY}"
            return
        fi

        printf 'Please enter a number from 1 to %d.\n' "$custom_number"
    done
}

confirm_and_flash() {
    local command=(
        "${ESPTOOL_COMMAND[@]}"
        -p "$SELECTED_PORT"
        -b "$SELECTED_BAUD"
        write_flash "$SELECTED_ADDRESS" "$SELECTED_BINARY"
    )
    local answer

    printf '\nReady to flash:\n'
    printf '  Port:    %s\n' "$SELECTED_PORT"
    printf '  Baud:    %s\n' "$SELECTED_BAUD"
    printf '  Address: %s\n' "$SELECTED_ADDRESS"
    printf '  Binary:  %s\n' "$SELECTED_BINARY"
    printf '\nCommand:\n  '
    printf '%q ' "${command[@]}"
    printf '\n\n'

    if "$DRY_RUN"; then
        printf 'Dry run only; nothing was flashed.\n'
        return
    fi

    read -r -p "Type yes to start flashing: " answer
    if [[ "$answer" != "yes" ]]; then
        printf 'Cancelled; nothing was flashed.\n'
        return
    fi

    "${command[@]}"
}

main() {
    while (($# > 0)); do
        case "$1" in
            --dry-run)
                DRY_RUN=true
                ;;
            -h | --help)
                usage
                return
                ;;
            *)
                usage >&2
                die "unknown option: $1"
                ;;
        esac
        shift
    done

    find_esptool

    printf 'ESP binary flasher\n'
    choose_port
    choose_baud
    choose_address
    choose_binary

    [[ -e "$SELECTED_PORT" ]] || die "serial port does not exist: $SELECTED_PORT"
    [[ -f "$SELECTED_BINARY" ]] || die "binary file does not exist: $SELECTED_BINARY"
    [[ -r "$SELECTED_BINARY" ]] || die "binary file is not readable: $SELECTED_BINARY"

    confirm_and_flash
}

main "$@"
