# Kubernetes Cluster Operations at DigitalOcean

Slides from https://www.meetup.com/DigitalOceanHsinchu/events/239131644/

## Build
```
make build-image
```

## Run
```
make present
```

---
## For pure container environment (e.g. CoreOS)

## Build
```
git clone https://github.com/protochron/hsinchu-DO-meetup-2017.git
cd hsinchu-DO-meetup-2017
docker build -t hc-do-meetup-2017 .
```

## Run
```
docker run -it -p 8000:8000 hc-do-meetup-2017
```

## View in a Browser
Open up a browser to `127.0.0.1:8000` on Linux or your Docker VM ip address on Mac or Windows (usually 192.168.99.100:8000)
