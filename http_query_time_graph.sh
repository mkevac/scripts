#!/bin/bash

usage()
{
cat << EOF
usage: $0 options

This script runs queries to URL and graphs resulting connection and total times.

OPTIONS:
  -h   Show this message
  -x   Use this proxy
  -g   Compress data
  -u   URL to use
  -r   How much retries?
EOF
}

PROXY=
GZIP=
URL=
RETRIES=500

while getopts "x:ghu:r:" OPTION
do
        case $OPTION in
                h)
                        usage
                        exit 1
                        ;;
                x)
                        PROXY=$OPTARG
                        ;;
                g)
                        GZIP=1
                        ;;
                u)
                        URL=$OPTARG
                        ;;
                r)
                        RETRIES=$OPTARG
                        ;;
                ?)
                        usage
                        exit 1
                        ;;
        esac
done

if [[ -z $URL ]]
then
        usage
        exit 1
fi

if [[ ! -z $PROXY ]]
then
        PROXYCMD="-x $PROXY"
fi

if [[ ! -z $GZIP ]]
then
        GZIPCMD="-H Content-Encoding:gzip"
fi

# clean data file
> /tmp/datafull

for x in $(seq $RETRIES)
do
	echo "query $x of $RETRIES"
        curl "$URL" -o /dev/null -w "%{time_connect} %{time_total}\n" -s $GZIPCMD $PROXYCMD >> /tmp/datafull

done

cat /tmp/datafull | awk '{print $1}' > /tmp/connect
cat /tmp/datafull | awk '{print $2}' > /tmp/total

echo "plot '/tmp/connect', '/tmp/total'" > /tmp/gnuplotcmd
gnuplot -p /tmp/gnuplotcmd
