from tasks import sleep_task
import os

min_duration = int(os.environ["TASK_MIN_DURATION"])
max_duration = int(os.environ["TASK_MAX_DURATION"])
step_duration = int(os.environ.get("TASK_STEP_DURATION", 1))

tasks = [sleep_task.delay(x) for x in range(min_duration, max_duration, step_duration)]
print(f'Successfully scheduled {len(tasks)} tasks: {tasks}')