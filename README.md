# BucketMQ
BucketMQ is a low barrier to entry message queue.
Ideal for integrating micro-services via asynchronous messaging.

## Terminology
- Message: A JSON message containing 2 parts
  - Payload: The JSON data being delivered
  - Envelope: Metadata about the message
- Bucket: A place where messages are initially sent
- Pail: A subscription to a bucket. It carries messages from a Bucket to a subscriber.

## HTTP-Only Integration
Send and recieve messages with BucketMQ via HTTP post.
BucketMQ will coordinate requests to HTTP endpoints that you configure, so you don't have to run
background processes that pull from a work queue or install any additional libraries.
Use whatever web-stack you're used to and let BucketMQ handle the rest.

## Contractual Messages
Use JSON-schema when you need a clear contract for message subscribers.

## YAML Based Config
Point BucketMQ to a folder that you can keep in a Git repository.
Explicit configuration for your architecture encourages communication and clear contracts
between services.

### Example Bucket Config Folder
```
TODO
```

## Bucket Configuration
```
TODO
```
