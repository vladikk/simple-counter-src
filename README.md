# Simple Counters Service

Simple Counters Service is an Apache2 Licensed utility that allows generating sequential numbers via RESTful API.

## Example

Initialize a new counter "test" by issuing a PUT request:
```
curl -XPUT 'https://xxxxxxxxxx.execute-api.eu-west-1.amazonaws.com/public/counter/test'
```

{ "counter_id": test, "status": "OK" }

```
Increment and get the new value by issuing a POST request:
curl -XPOST 'https://xxxxxxxxxx.execute-api.eu-west-1.amazonaws.com/public/counter/test'
```

{ "counter_id": "test", "counter_value": 1, "status": "OK" }
curl -XPOST 'https://xxxxxxxxxx.execute-api.eu-west-1.amazonaws.com/public/counter/test'
{ "counter_id": "test", "counter_value": 2, "status": "OK" }
curl -XPOST 'https://xxxxxxxxxx.execute-api.eu-west-1.amazonaws.com/public/counter/test'
{ "counter_id": "test", "counter_value": 3, "status": "OK" }
....

