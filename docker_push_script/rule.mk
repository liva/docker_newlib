define dps_check_variables
ifndef $1
$$(error Please define the variable '$1')
endif
endef

$(eval $(call dw_check_variables,NAME))

TAG    := $(shell git log -1 --pretty=%H)
IMG    := ${NAME}:${TAG}
LATEST := ${NAME}:latest

build:
	@if [ `bash -c "( git diff; git diff --cached; ) | wc -l"` -ne 0 ]; then echo "please commit all changes before building docker image.";exit 1; fi
	docker build -t ${IMG} .
	docker tag ${IMG} ${LATEST}

push:
	-docker rmi -f `docker images -q $(NAME) | sed -n '10,$$p'`
	docker push ${IMG}
	docker push ${LATEST}

