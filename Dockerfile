FROM ubuntu:16.04 AS build

ARG TARGET="x86_64-none-elf"
RUN apt update
RUN apt install -y build-essential git
RUN mkdir /tmp_newlib
WORKDIR /tmp_newlib
RUN git clone git://sourceware.org/git/newlib-cygwin.git --depth=1
RUN for bin in ar as ld nm objcopy objdump ranlib readelf strip; do ln -s `which $bin` ${TARGET}-$bin ; done
# INC_PATH=$(gcc --print-file-name=include)
# -I ${INC_PATH} -nostdinc -nostdlib
RUN echo -e "#!/bin/sh\ncc -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=0 \${@+\"\$@\"}" > ${TARGET}-cc
RUN echo -e "#!/bin/sh\ngcc -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=0 \${@+\"\$@\"}" > ${TARGET}-gcc
RUN chmod +x ${TARGET}-cc ${TARGET}-gcc
RUN mkdir build-newlib
WORKDIR build-newlib
RUN env PATH="`pwd`/../:$PATH" ../newlib-cygwin/configure --target=${TARGET} --disable-multilib --prefix=/newlib
RUN env PATH="`pwd`/../:$PATH" make -j$(grep -c ^processor /proc/cpuinfo 2>/dev/null)
RUN env PATH="`pwd`/../:$PATH" make install

FROM ubuntu:16.04
MAINTAINER Shinichi Awamoto <sap.pcmail@gmail.com>
COPY --from=build /newlib .
