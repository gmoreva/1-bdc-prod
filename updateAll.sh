#!/usr/bin/env bash

IFS='
'
export $(egrep -v '^#' .env | xargs -0)
IFS=
prodDir=$PWD
branch=$@
if [  -z "$@" ]
  then
    if [  -z "$PROJECTS_BRANCH" ]
      then
        branch=release
      else
        branch=$PROJECTS_BRANCH
      fi
fi
echo "Working branch " $branch

curl -F chat_id=$TELEGRAM_ADMIN_CHAT -F text="start deploy ${BASE_DOMAIN} ${branch}" \
https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage

folders=(\
    $SERVICE_1_SRC_DIR \
    $SERVICE_2_SRC_DIR \
    $INTERFACE_SRC_DIR \
      )

for folder in ${folders[*]}
do
    echo "update " $folder
    cd $folder && git fetch
    cd $folder && git reset --hard origin/$branch
done

cd $prodDir && docker-compose up -d --build

curl -F chat_id=$TELEGRAM_ADMIN_CHAT -F text="finish deploy ${BASE_DOMAIN}" \
https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage
