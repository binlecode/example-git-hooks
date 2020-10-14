#!/bin/sh

# use shell script instead of ruby for scan IO efficiency on possibly
# many files in the target repo


TODO_FOUND="no"

# -E using extended regular expression
# -i case insensitive
# -r recursive

TODO_OFFENDING_FILES=$(
    grep -irE "(TODO|FIXME)" ./* |
        tr ':' ' ' | awk '{ print $1 }' |
        sort | uniq
)

for WITH_TODO in $TODO_OFFENDING_FILES; do
    echo "! TODO or FIXME found in: $WITH_TODO"
    TODO_FOUND="yes"
done

TAB_FOUND="no"
TAB_OFFENDING_FILES=$(
    grep -r "$(printf '\t')" ./* |
        tr ':' ' ' | awk '{ print $1 }' |
        sort | uniq
)

for WITH_TAB in $TAB_OFFENDING_FILES; do
    echo "! TAB found in: $WITH_TAB"
    FIXME_FOUND="yes"
done

# TODO and FIXME is ok, TAB is not ok !
if [ "$TODO_FOUND" = "no" ]; then
    echo "* No TODO or FIXME detected - you are lucky this time..."
fi

if [ "$TAB_FOUND" = "no" ]; then
    echo "* No TAB detected - you are lucky this time..."
else
    echo "! TAB in source code is NO GO!"
    exit 1
fi
