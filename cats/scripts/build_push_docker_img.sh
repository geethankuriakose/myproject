#!/bin/bash
sudo docker images
sudo docker build -t sosamma2018/myapp:v10.
sudo docker push sosamma2018/myapp:v10
sudo docker build -t sosamma2018/myapp:v11 .
sudo docker push sosamma2018/myapp:v11
sudo docker images
#docker run  -p 8000:8000 --name mydemoapp  myapp:v11
#curl localhost:8000
#docker exec -it mydemoapp -- /bin/bash

