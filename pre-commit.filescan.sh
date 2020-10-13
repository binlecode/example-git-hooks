#!/bin/sh

# use shell script instead of ruby for scan IO efficiency on possibly
# many files in the target repo


TODO_FOUND="no"
FIXME_FOUND="yes"

TODO_OFFENDING_FILES=$(
    grep -irE "(TODO)" ./* |
        tr ':' ' ' | awk '{ print $1 }' |
        sort | uniq
)

for WITH_TODO in $TODO_OFFENDING_FILES; do
    echo "! TODO found in: $WITH_TODO"
    TODO_FOUND="yes"
done


FIXME_OFFENDING_FILES=$(
    grep -irE "(FIXME)" ./* |
        tr ':' ' ' | awk '{ print $1 }' |
        sort | uniq
)

for WITH_FIXME in $FIXME_OFFENDING_FILES; do
    echo "! FIXME found in: $WITH_FIXME"
    FIXME_FOUND="yes"
done

# TODO is ok, FIXME is not ok

if [ "$FIXME_FOUND" = "no" ]; then
    echo "* No FIXME detected"
else
    exit 1
fi
