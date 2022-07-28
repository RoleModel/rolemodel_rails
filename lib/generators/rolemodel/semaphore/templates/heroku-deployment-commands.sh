checkout --use-cache
heroku git:remote -a $HEROKU_APP_NAME
git push heroku -f $SEMAPHORE_GIT_BRANCH:main
