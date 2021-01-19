FROM linuxserver/code-server:arm64v8-latest

ENV THEOS /opt/theos
ENV PATH "$THEOS/bin:$PATH"

ENV BUILD_DEPS "gcc g++ cmake autoconf git curl rename chrpath cpio libssl1.0-dev libxml2-dev"
ENV SDK_REPO "DavidSkrundz/sdks"
ENV SDK_LIST "iPhoneOS12.2.sdk"

RUN apt-get update
RUN apt-get upgrade --yes
RUN apt-get install --yes clang make perl rsync $BUILD_DEPS

WORKDIR /opt
RUN git clone https://github.com/theos/theos.git

WORKDIR /opt/theos
RUN git submodule update --init --recursive

WORKDIR /opt
RUN git clone https://github.com/kabiroberai/ios-toolchain-linux.git toolchain

WORKDIR /opt/toolchain
RUN ./prepare-toolchain
RUN cp /usr/lib/llvm-6.0/lib/libLTO.so* staging/linux/iphone/lib/
RUN mv staging/linux ../theos/toolchain/

WORKDIR /opt
RUN rm -rf toolchain

RUN git clone https://github.com/$SDK_REPO.git sdk

WORKDIR /opt/sdk
RUN mv $SDK_LIST ../theos/sdks/

WORKDIR /opt
RUN rm -rf sdk

RUN curl -LO https://github.com/sbingner/llvm-project/releases/download/v10.0.0-1/linux-ios-arm64e-clang-toolchain.tar.lzma

RUN mkdir -p /arm64eToolchain
RUN tar --lzma -xvf linux-ios-arm64e-clang-toolchain.tar.lzma -C /arm64eToolchain

WORKDIR /arm64eToolchain/ios-arm64e-clang-toolchain/bin
RUN find * ! -name clang-10 -and ! -name ldid -and ! -name ld64 -exec mv {} arm64-apple-darwin14-{} \;
RUN find * -xtype l -exec sh -c "readlink {} | xargs -I{LINK} ln -f -s arm64-apple-darwin14-{LINK} {}" \;

RUN mkdir -p $THEOS/toolchain/linux/iphone
RUN rsync -a /arm64eToolchain/ios-arm64e-clang-toolchain/* $THEOS/toolchain/linux/iphone/

RUN apt-get purge --yes --autoremove $BUILD_DEPS
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*
