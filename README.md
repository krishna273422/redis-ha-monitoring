# High-Availability Redis & Prometheus on Kubernetes

This repository contains the configuration and automation needed to deploy a production-ready, high-availability (HA) Redis cluster on Kubernetes, complete with a full monitoring stack provided by Prometheus and Grafana.

The entire deployment process is automated using a `Makefile`, making it easy to create, manage, and tear down the environment with simple commands.

---

## Features

* **High-Availability Redis:** Deploys a Redis master with multiple replicas using a `StatefulSet`.
* **Automatic Failover:** Utilizes Redis Sentinel to monitor the master and automatically promote a replica if the master fails, ensuring minimal downtime.
* **Prometheus Monitoring:** Includes a Redis Exporter sidecar to expose metrics, which are automatically scraped by a pre-configured Prometheus server.
* **Makefile Automation:** Simplifies the entire lifecycle of the deployment, from setup to cleanup, with easy-to-use `make` commands.
* **Customizable:** All configurations are exposed in `values.yaml` files, allowing for easy customization of both Redis and Prometheus.

---

## Prerequisites

Before you begin, ensure you have the following tools installed and configured:

* **kubectl:** The Kubernetes command-line tool.
* **Helm:** The package manager for Kubernetes.
* **make:** The build automation tool.
* A running **Kubernetes cluster** (e.g., `kind`, `minikube`, GKE, EKS, AKS).

---

## File Structure

* `Makefile`: Contains all the automation for deploying and managing the stack.
* `redis-values.yaml`: The configuration file for the Redis Helm chart.
* `prometheus-values.yaml`: The configuration file for the Prometheus Helm chart.

---

## Quick Start

1.  **Clone the Repository:**
    ```sh
    git clone <your-repo-url>
    cd <your-repo-directory>
    ```

2.  **Deploy Everything:**
    Run the default `make` target to set up the namespaces, add the Helm repos, and deploy both Redis and Prometheus.
    ```sh
    make all
    ```

3.  **Access the Prometheus UI:**
    Once the deployment is complete, open a new terminal and run:
    ```sh
    make prometheus-ui
    ```
    Now, open your web browser and navigate to `http://localhost:9090`.

---

## Makefile Targets

The following commands are available to manage your deployment:

| Command                      | Description                                                                                              |
| ---------------------------- | -------------------------------------------------------------------------------------------------------- |
| `make all`                   | **(Default)** Runs the entire deployment process in the correct order.                                   |
| `make setup`                 | Creates the necessary Kubernetes namespaces and adds the required Helm repositories.                     |
| `make redis-install`         | Installs the Redis HA cluster.                                                                           |
| `make prometheus-install`    | Installs the Kube Prometheus Stack.                                                                      |
| `make redis-upgrade-monitoring` | Upgrades the Redis deployment to enable the `ServiceMonitor` for Prometheus.                             |
| `make redis-login`           | Opens a `redis-cli` session inside the Redis master pod for administrative tasks.                        |
| `make prometheus-ui`         | Forwards the Prometheus UI to `http://localhost:9090`.                                                   |
| `make clean`                 | **(Destructive)** Uninstalls all Helm releases and deletes the namespaces.                               |

---

## Configuration

To customize the deployment, you can modify the `redis-values.yaml` and `prometheus-values.yaml` files before running `make`. For example, you can change the number of Redis replicas, adjust resource limits, or modify Prometheus scrape configurations.

