FROM ubuntu:18.04

RUN apt update --fix-missing
RUN apt install -y iproute2 git make sudo vim pciutils net-tools python2.7

RUN useradd -m user
RUN echo "user:user" | chpasswd
RUN adduser user sudo

RUN groupadd vpp
RUN adduser user vpp

# Ensure sudo group users are not 
# asked for a password when using 
# sudo command by ammending sudoers file
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER user

RUN git clone \
	--depth 1 \
	--branch v21.10.1 \
	https://gerrit.fd.io/r/vpp \
	/home/user/vpp

WORKDIR /home/user/vpp

COPY --chown=user:user increase-nat-frame-queue-size.patch .
RUN git apply increase-nat-frame-queue-size.patch

RUN yes | make install-deps
RUN make build-release

RUN mkdir nfs
RUN mkdir scripts

COPY --chown=user:user nfs nfs
COPY --chown=user:user scripts scripts
COPY --chown=user:user vpp-startup.conf .

CMD [ "./scripts/run-vpp.sh" ]