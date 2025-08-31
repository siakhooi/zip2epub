# zip2epub
convert htmligator output directory or zip file into epub

## Reference
- https://github.com/siakhooi/python-htmligator

## Build
```
cd src
docker build -t zip2epub .
```

## Usage
```
docker run --rm -v $(pwd):/data zip2epub /data/filename123.zip
```
