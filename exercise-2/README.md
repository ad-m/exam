# Celery over-fetched tasks

A web application implemented with Django performs various operations asynchronously using Celery. Some tasks are quick, such as indexing, and some require significant processing, mainly network data retrieval.

The occurrence of unfairly distribution of tasks during processing was reported. That is, the worker reserves two tasks - one that is currently executing and one for future execution. Double reservation causes inefficient load distribution - worker reserve a task that is waiting for him to be executed in future, while another worker could execute it immediately. This situation particularly affects time-consuming tasks.

A Celery with a Redis transport was used on top of Django application.

## Reproduction

To reproduce the issue simple Django application with multiple workers was created and two tasks:

* `exam_app.users.tasks.early_acknowledge`
* `exam_app.users.tasks.late_acknowledge`

Some configuration was adjusted:

```python
# https://docs.celeryproject.org/en/stable/userguide/configuration.html#worker-concurrency
CELERY_WORKER_CONCURRENCY = 1
# https://docs.celeryproject.org/en/stable/userguide/configuration.html#worker-prefetch-multiplier
CELERY_worker_prefetch_multiplier = 1
```

Configuration options:

* reduce number of threads to make issue easier to debug
* maximum number of messages unacknowledged a consumer can hold

Start application:

```
docker-compose build && docker-compose up
```

Open [Flower](http://debug:debug@localhost:5555/tasks) to see tasks state.

Execute in Django shell:

```python
from exam_app.users import tasks
[tasks.early_acknowledge.delay() for x in range(1, 10)]
```

You will notice in Flower a few tasks in state `RECEIVED` or `RUNNING` or `SUCCESS` for `early_acknowledge` tasks.

Execute in Django shell:

```python
from exam_app.users import tasks
[tasks.late_acknowledge.delay() for x in range(1, 10)]
```

You will notice in Flower a few tasks in state `RUNNING` or `SUCCESS`, but no tasks in state `RECEIVED` for `late_acknowledge` tasks.

## Explanation

To understand the disappearance of state `RECEIVED` for `late_acknowledge` tasks, it is worth looking at the flow of worker:

![](https://ptuml.hackmd.io/svg/ZS-n2W8n30RWFK-HKOTx0K4v7Nm2mL52-olIUeKqFNryMy-XcouX8Sb7CcOJjVA8TD0Ke3pi-9oqPXisoO4L3lSPH1ADnOLyYMBOdhI0ba4UkXsyu8hXizlt5_rhxXiqfMU4lrKPCQEZZzBgbSTLIhJrdyglMmYJfx66zkiR)

Parameter `worker_prefetch_multiplier` control number of messages unacknowledged a consumer can hold. This parameter must effectively be non-zero (regardless of the fact that 0 is not settable because it means infinity in Celery) so that the worker can hold the message for at least a moment before processing it.

Changing the order of acknowledge has some disadvantages - if the worker fails to complete his task in a catastrophic situation, such as killing a process, the message may be picked up by another worker, and then some part of the work will be performed twice. In such a case, it should be ensured that such a task implementation are idempotent (does not perform the data manipulation twice – see [What is idempotency?](https://medium.com/airbnb-engineering/avoiding-double-payments-in-a-distributed-payments-system-2981f6b070bb#b7bb), e.g. through a declarative approach to state expectation. In the case of Django, this might mean using `Model.objects.get_or_create` instead of `Model.objects.create`, but each case requires an individual approach assessment

Reduce the number of prefetched messages also has some disadvantages - it limits task throughput, because the worker must synchronously wait for the next task after completing a task (& deal with network latency), instead of quickly fetching it from memory. This delay for large jobs is negligible, but can be noticeable when there is a high throughput on small tasks. In this case, you can create separate pools of workers and routing tasks accordingly.
