# Simple Counters Service

Simple Counters Service is a very simple utility that allows generating sequential numbers via RESTful Api.

## Example

Initialize a new counter "test" by issuing a PUT request:
```
curl -XPUT 'https://xxxxxxxxxx.execute-api.eu-west-1.amazonaws.com/public/counter/test'
```
Response:
```
{ "counter_id": test, "status": "OK" }

```

Increment and get the new value by issuing a POST request:
```
curl -XPOST 'https://xxxxxxxxxx.execute-api.eu-west-1.amazonaws.com/public/counter/test'
```
Response:
```
{ "counter_id": "test", "counter_value": 1, "status": "OK" }
```

## Implementation

The service is implemented by forwarding AWS Api Gateway requests directly to DynamoDB REST Api. Except for some simple Apache Velocity Templates in request and response mapping, no imperative code is needed.

The service and its components are described in the cloudformation template: src/cloudformation.template .

## Deployment

The deploy.sh bash scripts allows to easily create and deploy new instances of the cloudformation stack, and to generate client libraries for it.

### Usage

```
./deploy.sh "stack-name" "eu-west-1" "default"
```

Here, "stack-name" is ... well, name of the stack to instantiate, "eu-west-1" - name of the region in which the stack will be created, and "default" is the name of a local AWS credentials profile.

### Artifacts

The deployment scripts produces the following artifacts:

1. Cloudformation Stack consisting of DynamoDB table and REST Api
2. Swagger documentation in the clients/[stack-name] folder
3. Service clients for different platforms in the clients/[stack-name] folder

The service clients are generated using the "swagger-codegen" project.

