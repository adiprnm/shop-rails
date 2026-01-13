# RajaOngkir Integration Guides

* Rajaongkir uses `Key` header to authenticate request instead of `Bearer`.

## Search Province

### URL

GET https://rajaongkir.komerce.id/api/v1/destination/province

### Description

Retrieves a comprehensive list of all Indonesian provinces with their corresponding unique identifiers. This data serves as the first level in the location hierarchy and is required to subsequently fetch cities and districts within each province.

### Request

```bash
curl --location 'https://rajaongkir.komerce.id/api/v1/destination/province' \
--header 'Key: YOUR_API_KEY'

```

### Response

200 OK
```json
{
  "meta": {
    "message": "Success Get Province",
    "code": 200,
    "status": "success"
  },
  "data": [
    {
      "id": 1,
      "name": "NUSA TENGGARA BARAT (NTB)"
    },
    {
      "id": 2,
      "name": "NUSA TENGGARA BARAT"
    },
    // and so much more
  ]
}
```

400 Bad Request
```json
{
  "meta": {
    "message": "Invalid Api key, key not found",
    "code": 400,
    "status": "failed"
  },
  "data": null
}
```

## Search City

### URL

GET https://rajaongkir.komerce.id/api/v1/destination/city/{province_id}

### Description

Retrieves a comprehensive list of all cities within a specified Indonesian province using the province ID. This data serves as the second level in the location hierarchy and is required to subsequently fetch districts within each selected city.

### Request

```bash
curl --location 'https://rajaongkir.komerce.id/api/v1/destination/city/12' \
--header 'Key: YOUR_API_KEY'
```

### Response

200 OK
```json
{
  "meta": {
    "message": "Success Get District By City ID",
    "code": 200,
    "status": "success"
  },
  "data": [
    {
      "id": 1360,
      "name": "JAKARTA SELATAN",
      "zip_code": "0"
    },
    {
      "id": 1361,
      "name": "JAGAKARSA",
      "zip_code": "12630"
    },
    // and so much more
  ]
}
```

400 Bad Request
```json
{
  "meta": {
    "message": "Invalid Api key, key not found",
    "code": 400,
    "status": "failed"
  },
  "data": null
}
```

## Search District

### URL

GET https://rajaongkir.komerce.id/api/v1/destination/district/{city_id}

### Description

Retrieves a list of all districts within a specified Indonesian city using the city ID. This endpoint provides the third level in the location hierarchy and is essential for completing the destination input needed for shipping cost calculations and logistic planning.

### Request

```bash
curl --location 'https://rajaongkir.komerce.id/api/v1/destination/district/575' \
--header 'Key: YOUR_API_KEY'
```

### Response

200 OK
```json
{
  "meta": {
    "message": "Success Get District By City ID",
    "code": 200,
    "status": "success"
  },
  "data": [
    {
      "id": 1360,
      "name": "JAKARTA SELATAN",
      "zip_code": "0"
    },
    {
      "id": 1361,
      "name": "JAGAKARSA",
      "zip_code": "12630"
    },
    // and so much more
  ]
}
```

400 Bad Request
```json
{
  "meta": {
    "message": "Invalid Api key, key not found",
    "code": 400,
    "status": "failed"
  },
  "data": null
}
```

## Subdistrict

### URL

GET https://rajaongkir.komerce.id/api/v1/destination/sub-district/{district_id}

### Description

Retrieves a list of all subdistrict within a specified Indonesian district using the district ID. This endpoint provides the third level in the location hierarchy and is essential for completing the destination input needed for shipping cost calculations and logistic planning.

### Request

```bash
curl --location 'https://rajaongkir.komerce.id/api/v1/destination/sub-district/5823' \
--header 'Key: YOUR_API_KEY'
```

### Response

200 OK
```json
{
    "meta": {
        "message": "Success Get Sub District By District ID",
        "code": 200,
        "status": "success"
    },
    "data": [
        {
            "id": 68513,
            "name": "BALERAKSA",
            "zip_code": "53355"
        },
        {
            "id": 68514,
            "name": "GRANTUNG",
            "zip_code": "53355"
        },
        // and so much more
    ]
}
```

400 Bad Request
```json
{
  "meta": {
    "message": "Invalid Api key, key not found",
    "code": 400,
    "status": "failed"
  },
  "data": null
}
```

## Calculate Shipping Cost

### URL

POST https://rajaongkir.komerce.id/api/v1/calculate/district/domestic-cost

### Description

Calculates domestic shipping costs between two Indonesian districts using the selected couriers and package weight. The result includes shipping options, estimated delivery times, and total fees from multiple courier services.

### Request

```bash
curl --location 'https://rajaongkir.komerce.id/api/v1/calculate/district/domestic-cost' \
--header 'key: YOUR_API_KEY' \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'origin=1391' \
--data-urlencode 'destination=1376' \
--data-urlencode 'weight=1000' \
--data-urlencode 'courier=jne:sicepat:ide:sap:jnt:ninja:tiki:lion:anteraja:pos:ncs:rex:rpx:sentral:star:wahana:dse' \
--data-urlencode 'price=lowest'
```

### Response

200 OK
```json
{
  "meta": {
    "message": "Success Calculate Domestic Shipping cost",
    "code": 200,
    "status": "success"
  },
  "data": [
    {
      "name": "Lion Parcel",
      "code": "lion",
      "service": "JAGOPACK",
      "description": "Economy Service",
      "cost": 7000,
      "etd": "1-4 day"
    },
    {
      "name": "Lion Parcel",
      "code": "lion",
      "service": "REGPACK",
      "description": "Regular Service",
      "cost": 7500,
      "etd": "1-2 day"
    },
    // and so much more
  ]
}
```

400 Bad Request
```json
{
  "meta": {
    "message": "Invalid Api key, key not found",
    "code": 400,
    "status": "failed"
  },
  "data": null
}
```
