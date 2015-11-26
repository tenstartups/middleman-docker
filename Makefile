DOCKER_IMAGE_NAME := tenstartups/middleman

build: Dockerfile
	docker build --file Dockerfile --tag $(DOCKER_IMAGE_NAME) .

clean_build: Dockerfile
	docker build --no-cache --file Dockerfile --tag $(DOCKER_IMAGE_NAME) .

run: build
	docker run -it --rm ${DOCKER_IMAGE_NAME} ${ARGS}

push: build
	docker push ${DOCKER_IMAGE_NAME}:latest
