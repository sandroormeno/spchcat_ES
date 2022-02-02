###
### From topdir, first use multistrap to prepare a raspbian buster armhf root
### $ multistrap -d multistrap-raspbian-buster -f native_client/multistrap_raspbian_buster.conf
###
### You can make a tarball after:
### $ touch multistrap-raspbian-buster.tar && sudo tar cf multistrap-raspbian-buster.tar multistrap-raspbian-buster/ && xz multistrap-raspbian-buster.tar
###
### Then cross-build:
### $ make -C native_client/ TARGET=rpi3 TFDIR=../../tensorflow/tensorflow/
###

.PHONY: clean run print-toolchain

include definitions.mk

default: $(SPCHCAT_BIN)

clean:
	rm -f spchcat

$(SPCHCAT_BIN): src/spchcat.cc src/pa_list_devices.cc Makefile
	$(CXX) $(CFLAGS) $(CFLAGS_STT) $(SOX_CFLAGS) src/pa_list_devices.cc src/spchcat.cc $(LDFLAGS) $(SOX_LDFLAGS)
ifeq ($(OS),Darwin)
	install_name_tool -change bazel-out/local-opt/bin/native_client/libstt.so @rpath/libstt.so stt
endif

run: $(SPCHCAT_BIN)
	${META_LD_LIBRARY_PATH}=${TFDIR}/bazel-bin/native_client:${${META_LD_LIBRARY_PATH}} ./stt ${ARGS}

debug: $(SPCHCAT_BIN)
	${META_LD_LIBRARY_PATH}=${TFDIR}/bazel-bin/native_client:${${META_LD_LIBRARY_PATH}} gdb --args ./stt ${ARGS}

install: $(SPCHCAT_BIN)
	install -d ${PREFIX}/lib
	install -m 0644 ${TFDIR}/bazel-bin/native_client/libstt.so ${PREFIX}/lib/
	install -d ${PREFIX}/include
	install -m 0644 coqui-stt.h ${PREFIX}/include
	install -d ${PREFIX}/bin
	install -m 0755 stt ${PREFIX}/bin/

uninstall:
	rm -f ${PREFIX}/bin/spchcat
	rmdir --ignore-fail-on-non-empty ${PREFIX}/bin
	rm -f ${PREFIX}/lib/libstt.so
	rmdir --ignore-fail-on-non-empty ${PREFIX}/lib

print-toolchain:
	@echo $(TOOLCHAIN)
