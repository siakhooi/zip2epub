build:
	cd src && docker build -t zip2epub .
shell:
	docker run --rm -it -v $$(pwd):/data zip2epub bash

run:
	convert.sh /data/filename123.html
test:
	docker run --rm -v $$(pwd):/data zip2epub /data/filename123.zip

