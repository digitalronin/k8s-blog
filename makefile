server:
	hugo server -D

build:
	HUGO_ENV=production hugo

# Remove 'draft: true' from front-matter of new post
# before publishing
publish:
	make build
	git add docs
	git commit -m "Publish: $$(date)"
	git push

# ruby -e 'puts "Foo Bar".downcase.gsub(" ", "-") + ".md"'
# Usage: make new-post file=whatever (creates content/posts/whatever.md)
new-post:
	hugo new posts/$(file).md
