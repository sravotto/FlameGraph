#/bin/bash
# Simple script to create a series of perf flamegraphs
label=$1
iterations=$2
sleep=$3
dir=$4
if [ -d $dir  ]
then
  host=`hostname -s`

  >  $dir/$host.txt
  for i in `seq 1 $iterations`
  do
  date=`date +%Y%m%d_%H%M%S`
    perf record -N -F 99 -ag -e cycles:pp -o  $dir/perf_${label}_${host}_${date}.data -- sleep 60
    echo  $dir/perf_${label}_${host}_${date} >> $dir/$host.txt
    sleep $sleep
  done

  for f in `cat $dir/$host.txt`
  do
    perf script -i $f.data | sed 's/V8 WorkerThread/v8WorkerThread/' \
                              | ./stackcollapse-perf.pl | ./flamegraph.pl  --colors ml > $f.svg
 done
else
  echo "$dir does not exist"
fi  
