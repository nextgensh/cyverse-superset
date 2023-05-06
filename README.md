`docker build -t ua-superset:latest .`

`docker run -d --name=ua_superset --mount source=ua_superset,target=/home/superset/ --env-file env -p 9088:9088 ua-superset:latest`
