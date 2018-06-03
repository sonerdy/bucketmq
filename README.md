# BucketMQ
BucketMQ is a productive integration engine.
Fully configured via YAML files checked into Git repositories.
Supports multiple transports via a modular system.

![BucketMQ](https://media.giphy.com/media/PJnZwj2O7LKHC/giphy.gif)

## Terminology
- Project: A github repository containing YAML config files.
- Bucket: Queues input and processes through a set of configured steps.
- Intake: An entrypoint into a bucket.
- Step: An individual operation within a bucket.

## YAML Based Config
BucketMQ watches Git repositories and reads in YAML files to create buckets.

