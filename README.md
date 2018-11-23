<p align="center">
    <img src="https://user-images.githubusercontent.com/1342803/36623515-7293b4ec-18d3-11e8-85ab-4e2f8fb38fbd.png" width="320" alt="API Template">
    <br>
    <br>
    <a href="https://discord.gg/vapor">
        <img src="https://img.shields.io/discord/431917998102675485.svg" alt="Team Chat">
    </a>
    <a href="LICENSE">
        <img src="http://img.shields.io/badge/license-MIT-brightgreen.svg" alt="MIT License">
    </a>
    <a href="https://circleci.com/gh/vapor/api-template">
        <img src="https://circleci.com/gh/vapor/api-template.svg?style=shield" alt="Continuous Integration">
    </a>
    <a href="https://swift.org">
        <img src="http://img.shields.io/badge/swift-4.1-brightgreen.svg" alt="Swift 4.1">
    </a>
</p>

ms-assets is a **[Vapor 3](https://vapor.codes)** based microservice to hold all assets information of your application using [Minio](https://www.minio.io/), so you can select your storage provider

## Assets workflows

- Upload file using PreSignedURL WorkFlow
<img src="https://i.imgur.com/8J4Z40D.png" alt="Swift 4.1">


## Installation 📦

- Go to the root folder and run the next command
```bash
    $ vapor build
```
- Create a database PostgreSQL we are using docker for this
```bash
    $ docker run --name postgres -e POSTGRES_DB=assets -p 5432:5432 -e POSTGRES_PASSWORD=123456 -d postgres
```
- Create a minio instance
```bash
// We recommend to generate your own keys
$ docker run -p 9000:9000 --rm --name minio1 \
  -e MINIO_ACCESS_KEY="36J9X8EZI4KEV1G7EHXA" \
  -e MINIO_SECRET_KEY="ECk2uqOoNqvtJIMQ3WYugvmNPL_-zm3WcRqP5vUM" \
  -v ~/Documents/minion-data/data:/data \
  -v ~/Documents/minion-data/config:/root/.minio \
  minio/minio server --config-dir /root/.minio /data
```

- Duplicate the .env.TEMPLATE to .env and set your values
```bash
    $ cp .env.TEMPLATE .env
```

## Running the project 🚀 
- Go to the root folder and run the next command
```bash
    $ vapor run
```

## Documentation 📄
 The documentation for this microservice its written using Swagger

#### There are two ways to use：

### **Docker use：**
- Create a database PostgreSQL we are using docker for this
```bash
    $ docker run --rm -p 8081:8080 swagger API/swagger-ui
```
- With the application running you can use ```http://localhost:8080/docs/swagger.yml``` in the swagger input to get the docs

### **Docker hub：**

- Get the documentation in ```http://localhost:8080/docs/swagger.yml```
- Paste documentation into ```https://app.swaggerhub.com```

## Running the tests

We recommend run tests with xcode

**Note:** In order to test works correctly you must have the minio and database configured