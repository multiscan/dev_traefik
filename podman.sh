podman stop --all
podman network create traefik
podman run --network traefik --name proxy -d \
    -v $(realpath $PWD)/traefik.yml:/traefik.yml \
    -v $(realpath $PWD)/certs:/certs \
    -v $(realpath $PWD)/config:/config \
    -p 80:80 -p 443:443 -p 9090:9090 \
    traefik:v2.2 \
    --api.insecure=true --providers.docker 

podman run --network traefik --name redis -d \
    -p 6379:6379 \
    redis:7.0 \
    --save "" --appendonly no
 
podman generate kube proxy redis > aaa.yml
