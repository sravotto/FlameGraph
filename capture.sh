#!/bin/bash

label="perf"
iterations=1
sleep=0
dir=/tmp/$$


OPTIND=1
while getopts "l:i:s:d:" opt; do
  case "$opt" in
    l) label=$OPTARG ;;
    i) iterations=$OPTARG ;;
    s) sleep=$OPTARG ;;
    d) dir=$OPTARG ;;
    \?) echo "Usage: ./capture.sh [-d output_dir] [-s sleep] [-i iterations] [-l label]" >&2; 
        echo "Defaults output_dir=/tmp/[pid] sleep=0 iterations=1 label=perf" >&2; 
        exit 1 ;;
  esac
done
shift $((OPTIND-1))


echo "Running perf $iterations times. Sleeping $sleep seconds after each run"
echo "Output=$dir Label=$label" 

mkdir -p $dir
host=`hostname -s`

>  $dir/$host.txt
for i in `seq 1 $iterations`
do
  date=`date +%Y%m%d_%H%M%S`
  perf record -N -F 99 -ag -e cycles:pp --call-graph dwarf,4096 -o  $dir/${label}_${host}_${date}.data -- sleep 60
  echo  $dir/${label}_${host}_${date} >> $dir/$host.txt
  sleep $sleep
done

for f in `cat $dir/$host.txt`
do
  perf script -f -i $f.data | sed 's/V8 WorkerThread/v8WorkerThread/'  | ./stackcollapse-perf.pl | ./flamegraph.pl  --colors ml > $f.svg
done
