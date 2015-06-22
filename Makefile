image = validator-test-image
dist  = dist/binning-validator.tar.gz
build = validate-binning

.PHONY: build test bootstrap

files   = reads.fq.gz test.fna schema/input.yaml README.md
objects = $(addprefix $(build)/,$(files))

##############################
#
# Test and push the package
#
##############################

all: test

publish: ./plumbing/push-to-s3 VERSION $(dist)
	bundle exec $^

test: $(dist)
	mkdir -p $@
	tar -xzf $< -C $@ --strip-components 1
	bundle exec kramdown $@/README.md > $@/README.html
	bundle exec htmlproof $@/README.html
	./$@/validate $(image) default

$(dist): $(objects)
	mkdir -p $(dir $@)
	tar -czf $@ --exclude '$(build)/tmp' --exclude 'Gemfile.lock' $(dir $<)

##############################
#
# Build the distributable
#
##############################

build: $(objects)

$(build)/README.md: doc/binning-validator.md
	cp $< $@

$(build)/schema/output.yaml: $(build)
	wget $(output) --quiet --output-document $@

$(build)/schema/input.yaml: $(build)
	wget $(input) --quiet --output-document $@

$(build)/reads.fq.gz: $(build)
	wget $(reads) --quiet --output-document $@

$(build)/test.fna: $(build)
	wget $(fasta) --quiet --output-document $@

$(build): $(shell find src)
	cp -R src $@
	mkdir -p $@/schema
	touch $@

##############################
#
# Bootstrap initial resources
#
##############################

bootstrap: image Gemfile.lock

Gemfile.lock: Gemfile
	bundle install --path vendor/bundle

image:
	git clone https://github.com/bioboxes/metaBAT.git $@
	./plumbing/cache_docker $@ $(image)

clean:
	rm -rf $(build) dist

##############################
#
# Urls
#
##############################

fasta  = 'https://www.dropbox.com/s/245lfefz3b1dw4g/test.fna?dl=1'
reads  = 'https://www.dropbox.com/s/11hqge1j0ms5v1d/test.fq.gz?dl=1'
input  = 'https://raw.githubusercontent.com/pbelmann/rfc/feature/new_binning_spec/container/binning/input_schema.yaml'
