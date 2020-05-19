#!/bin/bash
echo 'Creating .env'
IFS=$'\n'
for line in $(cat .env-template)
do
	line="${line/=/}"
	branch="$(echo $CI_COMMIT_BRANCH | tr [a-z] [A-Z])"
	secret=$branch"-"$line
	value="$(google-cloud-sdk/bin/gcloud secrets versions access latest --secret=$secret --project=$GCLOUD_PROJECT_ID)"
	echo $line"="$value >> .env
done
echo '.env finished'

echo 'Deleting old images of container registry'
IFS=$'\n\t'
set -eou pipefail

C=0
NUMBER_OF_IMAGES_TO_REMAIN=$((${1} - 1))
LIST=$(google-cloud-sdk/bin/gcloud container images list-tags gcr.io/$GCLOUD_PROJECT_ID/$CI_PROJECT_NAME-$CI_COMMIT_BRANCH --limit=unlimited  --sort-by=~TIMESTAMP --format=json)

if [ "$LIST" != "[]" ]
then
  CUTOFF=$(google-cloud-sdk/bin/gcloud container images list-tags gcr.io/$GCLOUD_PROJECT_ID/$CI_PROJECT_NAME-$CI_COMMIT_BRANCH --limit=unlimited \
    --sort-by=~TIMESTAMP --format=json | TZ=/usr/share/zoneinfo/UTC jq -r '.['$NUMBER_OF_IMAGES_TO_REMAIN'].timestamp.datetime | sub("(?<before>.*):"; .before ) | strptime("%Y-%m-%d %H:%M:%S+0000") | mktime | strftime("%Y-%m-%d %H:%M:%S+0000")')

  for digest in $(google-cloud-sdk/bin/gcloud container images list-tags gcr.io/$GCLOUD_PROJECT_ID/$CI_PROJECT_NAME-$CI_COMMIT_BRANCH --limit=unlimited --sort-by=~TIMESTAMP \
    --filter="timestamp.datetime < '${CUTOFF}'" --format='get(digest)'); do
    (
      set -x
      google-cloud-sdk/bin/gcloud container images delete -q --force-delete-tags "gcr.io/$GCLOUD_PROJECT_ID/$CI_PROJECT_NAME-$CI_COMMIT_BRANCH@${digest}"
    )
    let C=C+1
  done
fi

echo "Deleted ${C} images in ${CI_PROJECT_NAME}." >&1
