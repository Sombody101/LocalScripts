#!/bin/bash

prof.start() {
    export __PROFILER_RUN=running
    PROF_LOG="/tmp/prof-$$.log"
    export PS4='+ [${EPOCHREALTIME}] [${BASH_SOURCE}:${LINENO}] '
    exec 4>&2 2>"$PROF_LOG"
    set -x
}

prof.stop() {
    set +x
    exec 2>&4 4>&-
    unset __PROFILER_RUN
}

prof.show() {
    local log="${1:-/tmp/prof-$$.log}"
    if [[ ! -f "$log" ]]; then
        echo "Profile log $log not found." >&2
        return 1
    fi

    awk '
    BEGIN { last = 0 }
    
    # Matched one or more + symbols at the start of the trace line
    /^\++ \[/ {
        # Extract floating-point seconds timestamp
        split($0, parts, "[[]|]"); 
        time = parts[2];
        
        # Strip PS4 prefix matching variable depth (+ or ++ or +++)
        cmd = $0;
        sub(/^\++ \[[0-9.]+] /, "", cmd);

        if (last > 0) {
            delta_ms = (time - last) * 1000.0;
            total_time_ms[prev_cmd] += delta_ms;
            counts[prev_cmd]++;
        }
        last = time;
        prev_cmd = cmd;
    }
    END {
        if (last > 0) {
            total_time_ms[prev_cmd] += 0;
            counts[prev_cmd]++;
        }
        
        print "================ TOP SLOWEST COMMANDS ================";
        for (c in total_time_ms) {
            printf "%10.3f ms total (%4d calls) | %s'$NORM'\n", total_time_ms[c], counts[c], c;
        }
    }' "$log" | sort -rn -k1,1
}

prof.run() {
    prof.start
    "$@"
    prof.stop
    prof.show "/tmp/prof-$$.log"
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

#regmod prof
#export -f prof.start prof.stop