import time
from celery import Celery
import os

app = Celery('tasks', broker=os.environ['BROKER_URL'])

@app.task
def sleep_task(duration: int):
    time.sleep(duration)
