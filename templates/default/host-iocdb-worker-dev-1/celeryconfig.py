# Max time in seconds that a celery task is allowed to run.  Prevents
#   long running tasks from blocking the worker from running other tasks. 
CELERYD_TASK_TIME_LIMIT = 55 * 60 
