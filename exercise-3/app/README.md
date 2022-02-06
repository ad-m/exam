# Basic Celery application

This is a basic application to demonstrate Celery's capabilities. Redis transport is used as Celery broker. Flower has been configured to provide minimal observability.

## Services

Application is build on following services:

* `producer` - commands to trigger a new Celery tasks
* `redis` - broker transport for Celery
* `worker` - Celery worker responsible to perform operations
* `flower` - a Flower instance to provide minimal observability

## Flow

1. `producer` schedule a new tasks and send it to `redis`.
2. `redis` receive, persist and provide tasks to `worker`.
3. `worker` executes a tasks scheduled by `producer`.
4. `flower` track everything what happening in application.

Docker periodically kick in `producer` thanks to restart policy.

## Usage

Use command to start application:

```bash
docker-compose up -d
```

See logs of:

* `worker` to track executed tasks
* `producer` to track scheduled tasks

Use Flower exposed at [http://localhost:5566](localhost:5566) to see metrics in browser. You can use also use [http://localhost:5566/metrics](localhost:5566) to preview Prometheus metrics.
