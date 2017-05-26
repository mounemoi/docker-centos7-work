build:
	cp ${HOME}/.ssh/id_rsa.pub ./
	docker build --rm --build-arg USER=${USER} -t local/centos7-work .
	rm -f id_rsa.pub
