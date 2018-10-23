#!/bin/bash
pythonver=2
if [[ $# != 1 ]]; then
	echo "ex) $0 2"
	echo "ex) $0 3"
	echo PYTHONPATH=$PYTHONPATH
	exit 0
fi

if [[ $# == 1 ]]; then
	pythonver=$1
fi

echo pythonver = $pythonver

if [[ $(uname) == 'Darwin' ]]; then
	if [[ $pythonver == 3 ]]; then
		export PYTHONPATH=/usr/local/lib/python3.6/site-packages
	elif [[ $pythonver == 2 ]]; then
		export PYTHONPATH=/Library/Python/2.7/site-packages
	fi
elif [[ $(uname) == 'Linux' ]]; then
	if [[ $pythonver == 3 ]]; then
		export PYTHONPATH=/usr/local/lib/python3.6/site-packages
	elif [[ $pythonver == 2 ]]; then
		export PYTHONPATH=/usr/local/lib/python2.7/site-packages
	fi
fi
echo PYTHONPATH=$PYTHONPATH
