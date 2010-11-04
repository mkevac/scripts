#!/bin/bash

MINPARAMS=2

if [ $# -lt "$MINPARAMS" ]
then
	echo
	echo "usage: $0 <url> <count>"
	exit
fi

url=$1
count=$2

# clean data file
> /tmp/datafull

for x in $(seq $count)
do
	echo "query $x of $count"
	curl "$url" -o /dev/null -w '%{time_connect} %{time_total}\n' -s >> /tmp/datafull
done

cat /tmp/datafull | awk '{print $1}' > /tmp/column1
cat /tmp/datafull | awk '{print $2}' > /tmp/column2

echo "plot '/tmp/column1', '/tmp/column2'" > /tmp/gnuplotcmd
gnuplot -p /tmp/gnuplotcmd