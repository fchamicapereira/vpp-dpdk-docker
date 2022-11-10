FROM ubuntu:18.04

RUN apt update
RUN apt install -y iproute2 git make sudo vim pciutils net-tools python3

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

COPY --chown=user:user increase-nat-frame-queue-size.patch /home/user/vpp/
RUN git apply increase-nat-frame-queue-size.patch

RUN yes | make install-deps
RUN make build-release

COPY --chown=user:user vpp-startup.conf /home/user/
COPY --chown=user:user nat.vpp /home/user/

CMD [ "sudo", "./build-root/install-vpp-native/vpp/bin/vpp", "-c", "/home/user/vpp-startup.conf" ]