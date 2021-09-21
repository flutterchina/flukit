#!/bin/sh
git filter-branch --env-filter  '
OLD_EMAIL=""
CORRECT_NAME="wendux"
CORRECT_EMAIL="824783146@qq.com"
if [ "$GIT_COMMITTER_EMAIL" = "$OLD_EMAIL" ]
then
    export GIT_COMMITTER_NAME="$CORRECT_NAME"
    export GIT_COMMITTER_EMAIL="$CORRECT_EMAIL"
fi
if [ "$GIT_AUTHOR_EMAIL" = "$OLD_EMAIL" ]
then
    export GIT_AUTHOR_NAME="$CORRECT_NAME"
    export GIT_AUTHOR_EMAIL="$CORRECT_EMAIL"
fi
' --original -f --tag-name-filter  cat -- --branches --tags

#git push --force --tags origin 'refs/heads/*'
