from django.contrib.auth import get_user_model
import time
from  random import random
from config import celery_app
from celery.utils.log import get_task_logger

User = get_user_model()
logger = get_task_logger(__name__)

def block_task_likely():
    # pass
    # if random() < 0.5:
        logger.info('Waiting for task')
        time.sleep(10)
 
@celery_app.task()
def get_users_count():
    """A pointless Celery task to demonstrate usage."""
    return User.objects.count()

# https://docs.celeryproject.org/en/stable/userguide/optimizing.html#prefetch-limits
# The prefetch limit is a limit for the number of tasks (messages) a worker can reserve for itself. 

@celery_app.task(acks_late=True)
# https://docs.celeryproject.org/en/stable/userguide/optimizing.html#reserve-one-task-at-a-time
# https://docs.celeryproject.org/en/stable/reference/celery.app.task.html#celery.app.task.Task.acks_late
# When enabled acks_late messages for task will be acknowledged after the task has been executed, and 
# not just before (the default behavior). Having a prefetch multiplier setting of one and acks_late disabled, means 
# the worker will reserve at most one extra task for every worker process
def late_acknowledge():
    block_task_likely()
    # WARN: recursive call infinity
    # late_acknowledge.delay()
@celery_app.task(
    acks_late=False # default
)
def early_acknowledge():
    block_task_likely()
    # recursive call infinity
    # early_acknowledge.delay()

 