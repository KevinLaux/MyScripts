cd C:\repo\rtpsug.github.io\
docker run --rm -v=C:\repo\rtpsug.github.io\:/srv/jekyll -p 4000:4000 -it jekyll/jekyll jekyll serve --force_polling