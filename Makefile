default: build

build:
	zola build

deploy: build
	rsync -avz --exclude .well-known --delete public/ blog:/home/public/

post:
	scripts/generate-post

serve:
	zola serve
