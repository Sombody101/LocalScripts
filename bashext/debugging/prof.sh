#!/bin/bash

prof.start() {
    # see https://stackoverflow.com/a/20855353
    exec 3>&2 2> >(tee /tmp/sample-$$.log |
        sed -u 's/^.*$/now/' |
        date -f - +%s.%N >/tmp/sample-$$.tim)
    set -x
}

prof.stop() {
    set +x
    exec 2>&3 3>&-

    echo "To view timing log:"
    echo "bash_prof_show $$"
}

prof.show() {
    local pid=${1:?missing pid}
    local tim_file=/tmp/sample-${pid}.tim
    local log_file=/tmp/sample-${pid}.log

    paste <(
        while read -r tim; do
            [[ -z "$last" ]] && last="${tim//./}" && first="${tim//./}"
            crt=000000000$((${tim//./} - 10#0$last))
            ctot=000000000$((${tim//./} - 10#0$first))
            
            printf "%12.9f %12.9f\n" ${crt:0:${#crt}-9}.${crt:${#crt}-9} \
                ${ctot:0:${#ctot}-9}.${ctot:${#ctot}-9}
            
            last="${tim//./}"
        done <"${tim_file}"
    ) "${log_file}"
}

prof.bench() {
    local iter="${1:-500000}" test="$2"

    [[ ! "$test" ]] && {
        core::error "No test supplied"
        return
    }

    echo "Running $iter times..."
    local TIMEFORMAT='%3R,%3U,%3S'
    local out=$(time { eval "for ((i=0;i<iter;++i)); do $2; done"; })
    echo "$out" | head -n -1
    out="$(echo "$out" | tail -1 | cut -d',' -f1)"
    echo "Average time: $((out/iter))"
}

prof.fbench() {
    local iter="${1:-500000}" test="$2"

    [[ ! "$test" ]] && {
        core::error "No test supplied"
        return
    }

    echo "Running $iter times..."
    
    local TIMEFORMAT='%3R,%3U,%3S'
    
    local tmp_time
    tmp_time=$(mktemp)

    exec 3>&2
    {
        time {
            eval "for ((i=0; i<iter; ++i)); do $test; done"
        }
    } 2> "$tmp_time" 3>&2
    exec 3>&-

    local metrics
    metrics=$(cat "$tmp_time")
    rm -f "$tmp_time"

    local raw_real
    raw_real=$(echo "$metrics" | cut -d',' -f1)

    local ms_real
    ms_real=$(echo "$raw_real" | tr -d '.')
    
    command -v bc || {
        core::warn "bc not found, no iteration-specific timings can be processed."

        
        return
    }

    echo "Average time: $((ms_real / iter))ms per iteration"
}

register_module prof
export -f prof.start prof.stop