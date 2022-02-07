# Celery observability

Demonstration of technology for Celery observability for an American startup.

The project consists of the following elements:

* a Python application (directory `app`) that:
  * uses GitHub Packages to store Docker images,
  * uses Docker-compose to describe the environment,
  * uses Flower for observability,
  * provides consumer producer and worker Celery
  * provides Redis for transport of Celery components
* a Helm Chart (directory `helm`) to deploy observable environment in one command:
  * Python application from directory `app`:
  * Redis instance for transport
  * Prometheus to collect metrics about environment:
    * Flower for Python application metrics
    * Node-export for Kubernetes Node metrics
    * `kube-state-metrics` for Kubernetes resources metrics
  * Grafana to provide UI for observability and – in future – alerting via eg. Slack / SMTP
