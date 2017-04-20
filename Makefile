default: present

build-image:
	docker build -t protochron/hsinchu-do-meetup .

present-dev: build-image
	docker run --rm -it -p 8000:8000 \
		-v $(shell pwd)/contents.md:/reveal/contents.md \
		-v $(shell pwd)/assets:/reveal/assets \
		-v $(shell pwd)/index.html:/reveal/index.html \
	protochron/hsinchu-do-meetup

present: build-image
	docker run --rm -it -p 8000:8000 protochron/hsinchu-do-meetup

push-image: build-image
	docker push protochron/hsinchu-do-meetup
