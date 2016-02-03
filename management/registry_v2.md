# For Docker Registry v2

### with External Volume Mount

```sh
docker run -d -p 5000:5000  \
--name="registry-2" --restart=always \
-v /data/registry2/image:/data \
-e REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY=/data \
-e REGISTRY_STORAGE_DELETE_ENABLED=true \
registry:2
```

### with Backend Storage : AWS S3

```sh
docker run -d -p 5000:5000  \
--name="registry-2" --restart=always \
-e REGISTRY_STORAGE_DELETE_ENABLED=true \
-e REGISTRY_STORAGE=s3 \
-e REGISTRY_STORAGE_S3_accesskey= \
-e REGISTRY_STORAGE_S3_secretkey= \
-e REGISTRY_STORAGE_S3_region= \
-e REGISTRY_STORAGE_S3_bucket= \
registry:2
```

# Check Registry Images with API

```sh
curl -X GET http://localhost:5000/v2/
curl -X GET http://localhost:5000/v2/_catalog
curl -X GET http://localhost:5000/v2/search?q=ubuntu
```
