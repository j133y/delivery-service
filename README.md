## Delivery service

The delivery service project is designed to find the most economical path for a delivery.

Given a map with routes, all that is needed is inform the origin, destination, autonomy and liter price, with these attributes the service will find the most economical path according to database.

## Getting Started


* Install Ruby version 2.0.0 or newer
* Install Sqlite3

After setting the prerequisites you can start the project:

1. Clone the project at the command prompt:

  ```sh
  $ git clone https://github.com/j133y/delivery-service.git
  $ cd delivery-service
  ```

2. Install the required gems:
  ```sh
  $ bundle install
  ```

3. Create the database and migrate the necessary database structure:
  ```sh
  $ rake db:create
  $ rake db:migrate
  ```
  
4. Run the tests:
  ```sh
  $ RAILS_ENV=test rake db:migrate
  $ rspec
  ```

5. Run the service:
  ```sh
  $ rails s
  ```

6. After following the steps above, the project will bootup. The next section shows how to use the service.


## Using the delivery service

The following examples uses the ```curl``` library, if you don't have it installed yet, please install it before moving on. 

### Versioning

This service is intented to be versioned, that requires each request having the correct version on headers.

By default, all requests receive the v1 version of the API. I encourage you to explicitly request this version via the Accept header:


```
Accept: application/vnd.delivery.v1
```

### Schema

All API access is over HTTP, if you are on development enviroment, the API can be accessed from the ```http://localhost:3000/api/```. All data is sent and received as JSON.


### Client Errors

There are three possible types of client errors on API calls that receive request bodies:


1. Sending invalid JSON will result in a 400 Bad Request response.

```
HTTP/1.1 400 Bad Request
Content-Length: 38
{"status":"400","error":"Bad Request"}
```

2. Sending invalid fields will result in a 422 Unprocessable Entity response.

```
HTTP/1.1 422 Unprocessable Entity
Content-Length: 70
{ "routes.origin": ["has already been taken"], "name": ["can't be blank"] }
```

3. Requesting invalid entity will result in a 404 Not Found response.

```
HTTP/1.1 404 Not Found
Content-Length: 36
{"status":"404","error":"Not Found"}%
```


### Maps


#### Create a map with routes

Create a map resource with routes.

```
POST /maps
```

**Parameters**

| Name              | Type        | Description  |
| ----------------- |-------------| ----------------------------------------|
| name              | string      | **Required**. The map name. |
| routes_attributes | array       | **Required**. An array of route objects.|

**Route attributes**

| Name              | Type        | Description  |
| ----------------- |-------------| ----------------------------------------|
| origin            | string      | **Required**. The origin name. |
| destination       | string      | **Required**. The destination name.|
| distance          | integer     | **Required**. The distance between origin and destination.|

**Example**

```sh
curl -XPOST -H 'Accept: application/vnd.delivery.v1' -H "Content-Type: application/json" -d '{ "map": { "name": "Mapa SP", "routes_attributes": [{ "origin": "Barueri", "destination": "Sao Paulo", "distance": 50 }, { "origin": "Osasco", "destination": "Sao Paulo", "distance": 30 }, { "origin": "Sao Paulo", "destination": "Santos", "distance": 100 }] } }' http://localhost:3000/api/maps -v
```

**Response**

```
POST /api/maps HTTP/1.1
Host: localhost:3000
User-Agent: curl/7.43.0
Accept: application/vnd.delivery.v1

HTTP/1.1 201 Created
Location: http://localhost:3000/api/maps/5

{
  "id": 5,
  "name": "Mapa SP",
  "created_at": "2015-12-05T21:35:32.314Z",
  "updated_at": "2015-12-05T21:35:32.314Z",
  "routes": [
    {
      "id": 8,
      "origin": "Barueri",
      "destination": "Sao Paulo",
      "distance": 50,
      "url": "http://localhost:3000/api/routes/8"
    },
    {
      "id": 9,
      "origin": "Osasco",
      "destination": "Sao Paulo",
      "distance": 30,
      "url": "http://localhost:3000/api/routes/9"
    },
    {
      "id": 10,
      "origin": "Sao Paulo",
      "destination": "Santos",
      "distance": 100,
      "url": "http://localhost:3000/api/routes/10"
    }
  ]
}
```

#### Estimate Delivery

Estimate the most econimical path for the given delivery information.

```
GET /maps/estimate_delivery
```

**Parameters**

| Name              | Type        | Description  |
| ----------------- |-------------| ----------------------------------------|
| name              | string      | **Required**. The map name. |
| origin            | string      | **Required**. The delivery origin. |
| destination       | string      | **Required**. The delivery destination. |
| liter_price       | integer     | **Required**. The fuel price per liter. |
| autonomy          | integer     | **Required**. The autonomy of the transportation. |


**Example**

```sh
curl -H 'Accept: application/vnd.delivery.v1' http://localhost:3000/api/maps/estimate_delivery?name=mapa%20rio%20de%20janeiro&origin=parati&destination=Rio%20de%20janeiro&liter_price=2.5&autonomy=10 -v
```

or

```sh
curl -XGET -H 'Accept: application/vnd.delivery.v1' -H "Content-Type: application/json" -d '{ "name": "mapa rio de janeiro", "origin": "Parati", "destination": "Rio de janeiro", "liter_price": 2.5, "autonomy": 10}' http://localhost:3000/api/maps/estimate_delivery -v
```

**Response**

```
GET /api/maps/estimate_delivery HTTP/1.1
Host: localhost:3000
User-Agent: curl/7.43.0
Accept: application/vnd.delivery.v1

HTTP/1.1 200 OK

{
  "route": [
    "parati",
    "rio de janeiro"
  ],
  "cost": 37.5
}
```

#### List maps

List all maps resources with routes.

```
GET /maps
```

**Example**

```sh
curl -H 'Accept: application/vnd.delivery.v1' http://localhost:3000/api/maps -v
```

**Reponse**
```
GET /api/maps HTTP/1.1
Host: localhost:3000
User-Agent: curl/7.43.0
Accept: application/vnd.delivery.v1

HTTP/1.1 200 OK

[
  {
    "id": 1,
    "name": "Mapa Sao Paulo",
    "routes": [
      {
        "id": 1,
        "origin": "Barueri",
        "destination": "São Paulo",
        "distance": 50,
        "url": "http://localhost:3000/api/routes/1"
      },
      {
        "id": 2,
        "origin": "São Paulo",
        "destination": "Santos",
        "distance": 150,
        "url": "http://localhost:3000/api/routes/2"
      }
    ],
    "url": "http://localhost:3000/api/maps/1"
  },
  {
    "id": 2,
    "name": "Mapa Rio de Janeiro",
    "routes": [
      {
        "id": 3,
        "origin": "Parati",
        "destination": "Rio de Janeiro",
        "distance": 150,
        "url": "http://localhost:3000/api/routes/3"
      }
    ],
    "url": "http://localhost:3000/api/maps/2"
  }
]
```

#### List a single Map

List a single map resource with routes.

```
GET /map/:id
```

**Example**

```sh
curl -H 'Accept: application/vnd.delivery.v1' http://localhost:3000/api/maps/1 -v
```

**Reponse**

```
GET /api/maps/1 HTTP/1.1
Host: localhost:3000
User-Agent: curl/7.43.0
Accept: application/vnd.delivery.v1

{
  "id": 1,
  "name": "Mapa Sao Paulo",
  "created_at": "2015-12-05T19:53:43.006Z",
  "updated_at": "2015-12-05T19:53:43.006Z",
  "routes": [
    {
      "origin": "Barueri",
      "destination": "São Paulo",
      "distance": 50,
      "url": "http://localhost:3000/api/routes/1"
    },
    {
      "origin": "S\u00e3o Paulo",
      "destination": "Santos",
      "distance": 150,
      "url": "http://localhost:3000/api/routes/2"
    }
  ]
}
```

#### Update a map with routes

Update a single map and its routes.

```
PUT /map/:id
```

**Parameters**

| Name              | Type        | Description  |
| ----------------- |-------------| ----------------------------------------|
| name              | string      | The map name. |
| routes_attributes | array       | An array of route objects.|

**Route attributes**

| Name              | Type        | Description  |
| ----------------- |-------------| ----------------------------------------|
| id            | integer      | The resource id. |
| origin            | string      | The origin name. |
| destination       | string      |  The destination name.|
| distance          | integer     | The distance between origin and destination.|

**Example**

```sh
curl -XPUT -H 'Accept: application/vnd.delivery.v1' -H "Content-Type: application/json" -d '{ "map": { "name": "Mapa Sao Paulo", "routes_attributes": [{ "id": "1", "origin": "Osasco", "destination": "Sao Paulo", "distance": 30 }] } }' http://localhost:3000/api/maps/1 -v
```

**Response**

```
PUT /api/maps/1 HTTP/1.1
Host: localhost:3000
User-Agent: curl/7.43.0
Accept: application/vnd.delivery.v1

HTTP/1.1 200 OK
Location: http://localhost:3000/api/maps/1

{
  "id": 1,
  "name": "Mapa Sao Paulo",
  "created_at": "2015-12-05T19:53:43.006Z",
  "updated_at": "2015-12-05T19:53:43.006Z",
  "routes": [
    {
      "origin": "Osasco",
      "destination": "Sao Paulo",
      "distance": 30,
      "url": "http://localhost:3000/api/routes/1"
    },
    {
      "origin": "S\u00e3o Paulo",
      "destination": "Santos",
      "distance": 150,
      "url": "http://localhost:3000/api/routes/2"
    }
  ]
}
```

#### Delete a map with routes

Delete a single map and its routes

```
DELETE /map/:id
```

**Example**

```sh
curl -XDELETE -H 'Accept: application/vnd.delivery.v1' http://localhost:3000/api/maps/1 -v
```

**Response**

```
DELETE /api/maps/1 HTTP/1.1
Host: localhost:3000
User-Agent: curl/7.43.0
Accept: application/vnd.delivery.v1

HTTP/1.1 204 No Content
```
