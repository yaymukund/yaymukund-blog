default: build

build:
	gutenberg build

deploy: build
	rsync -avz --exclude .well-known --delete public/ blog:/home/public/

serve:
	gutenberg serve
