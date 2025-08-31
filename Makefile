build:
	cd src/zip2epub && docker build -t zip2epub .
shell:
	docker run --rm -it -v $$(pwd):/data zip2epub bash
run:
	convert.sh /data/filename123.html
test:
	docker run --rm -v $$(pwd):/data zip2epub /data/filename123.zip


build-ebook-convert:
	cd src/ebook-convert && docker build -t ebook-convert .

sh-ebook-convert:
	docker run --rm -it -v $$(pwd):/data ebook-convert bash
