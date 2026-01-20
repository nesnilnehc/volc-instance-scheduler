# Volc Instance Scheduler

![License](https://img.shields.io/github/license/recloud/volc-instance-scheduler)
![Build Status](https://img.shields.io/github/actions/workflow/status/recloud/volc-instance-scheduler/publish.yml)

A lightweight, containerized scheduler to manage cloud instances on **Volcengine (火山引擎)**.
Designed to automatically stop instances during non-working hours using the **resource-saving mode** (`StoppedMode=StopCharging`), significantly reducing cloud costs.

## Features

- **💰 Cost Saving**: Uses `StoppedMode=StopCharging` to pause billing for vCPU and RAM while keeping storage and IP.
- **⏰ Precision Scheduling**: Powered by standard Cron expressions (e.g., "Every day at 22:00").
- **🌍 Timezone Aware**: Fully configurable timezone support (default: `Asia/Shanghai`).
- **🐳 Container Native**: Zero code dependencies—runs as a tiny Docker container using the official Volcengine CLI.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

## Quick Start

### 1. Configure
Copy the example configuration:
```bash
cp .env.example .env
```

Edit `.env` with your credentials and schedule:
```ini
VOLCENGINE_ACCESS_KEY=your_ak
VOLCENGINE_SECRET_KEY=your_sk
VOLCENGINE_REGION=cn-beijing
INSTANCE_ID=i-your_instance_id

# Schedule: Every day at 22:00
STOP_SCHEDULE=0 22 * * *
TZ=Asia/Shanghai
```

### 2. Run
Start the scheduler in the background:
```bash
docker-compose up -d --build
```

### 3. Monitor
Check logs to verify the scheduler is running:
```bash
docker-compose logs -f
```

## How It Works

1.  **Image**: The container is built on `alpine:latest` and installs the official [Volcengine CLI (`ve`)](https://github.com/volcengine/volcengine-cli).
2.  **Entrypoint**: The `entrypoint.sh` script generates a runtime script with your environment variables.
3.  **Cron**: A `crond` daemon is started in the foreground, executing the stop command according to your `STOP_SCHEDULE`.

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
