FROM debian:testing

ENV PATH "/root/.cargo/bin:${PATH}"

RUN apt-get update
RUN apt-get dist-upgrade -y
RUN apt-get install -y \
        apt-transport-https build-essential clang-16 cmake curl git \
        libjsoncpp-dev libyaml-cpp-dev lld-16 pkg-config python3 python3-pip \
        wget
RUN pip3 install --break-system-packages pypeg2 toposort

RUN for target in aarch64-unknown-cloudabi armv6-unknown-cloudabi-eabihf \
                  armv7-unknown-cloudabi-eabihf i686-unknown-cloudabi \
                  x86_64-unknown-cloudabi; do \
      for tool in ar nm objdump ranlib size; do \
        ln -s ../lib/llvm-16/bin/llvm-${tool} /usr/bin/${target}-${tool}; \
      done && \
      ln -s ../lib/llvm-16/bin/clang /usr/bin/${target}-cc && \
      ln -s ../lib/llvm-16/bin/clang /usr/bin/${target}-c++ && \
      ln -s ../lib/llvm-16/bin/lld /usr/bin/${target}-ld && \
      ln -s ../../${target} /usr/lib/llvm-16/${target}; \
    done

RUN echo deb https://nuxi.nl/distfiles/cloudabi-ports/debian/ cloudabi cloudabi > /etc/apt/sources.list.d/cloudabi.list && \
    wget -qO - 'https://pgp.mit.edu/pks/lookup?op=get&search=0x0DA51B8531344B15' | apt-key add - && \
    apt-get update && \
    apt-get install -y x86-64-unknown-cloudabi-cxx-runtime

RUN git clone https://github.com/NuxiNL/argdata.git && \
    cd argdata && \
    cmake . && \
    make && \
    make install && \
    cd .. && \
    rm -Rf argdata/

RUN git clone https://github.com/NuxiNL/arpc.git && \
    cd arpc && \
    cmake . && \
    make && \
    make install && \
    cd .. && \
    rm -Rf arpc/

RUN git clone https://github.com/NuxiNL/cloudabi.git && \
    install -m 444 cloudabi/headers/* /usr/include/ && \
    rm -Rf cloudabi/

RUN git clone https://github.com/NuxiNL/flower.git && \
    cd flower && \
    cmake . && \
    make && \
    make install && \
    cd .. && \
    rm -Rf flower/

RUN git clone https://github.com/NuxiNL/yaml2argdata.git && \
    mkdir /usr/include/yaml2argdata/ && \
    install -m 444 yaml2argdata/yaml2argdata/* /usr/include/yaml2argdata/ && \
    rm -Rf yaml2argdata/

RUN git clone https://github.com/NuxiNL/cloudabi-utils.git && \
    cd cloudabi-utils && \
    cmake . && \
    make && \
    make install && \
    cd .. && \
    rm -Rf cloudabi-utils/

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && \
    rustup toolchain install nightly && \
    rustup default nightly && \
    rustup target add x86_64-unknown-cloudabi

RUN ldconfig
