# Makefile
.PHONY: dev setup db

dev:
	bin/dev -b 0.0.0.0

devsolid:
	SOLID_QUEUE_IN_PUMA=1 bin/dev -b 0.0.0.0

pc:
	EDITOR=nvim bin/rails credentials:edit --environment production

dc:
	EDITOR=nvim bin/rails credentials:edit --environment development

setup:
	bundle install
	bin/rails db:prepare

db:
	bin/rails db:migrate

