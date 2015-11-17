#!/usr/bin/make -f
# *-*- Mode: makefile -*-*
MACHINE ?= taptest
VERSION ?= $$(cat /usr/share/clear/version)
#LOGDIR ?= $(CURDIR)/taplogs-$(MACHINE)-$(VERSION)
LOGDIR ?= $(CURDIR)/taplogs
#TESTS ?= $$(echo ${TEST}|awk 'BEGIN{FS=","} {for (i=1;i<=NF;i++) {print $$i}}' | sort )
TESTS ?= swupd 
d := $(dir $(lastword $(MAKEFILE_LIST)))

export CI=yes

all: $(LOGDIR)
	-for i in `find -name "quick-*.t"`; do\
		pushd $$(dirname $$i); \
		mkdir -p $(LOGDIR)/$$(dirname $$i); \
		prove --archive $(LOGDIR)/$$(dirname $$i) quick-*.t -vvv; \
		popd; \
	done
	-for i in `find -name "slow-*.t"`; do\
		pushd $$(dirname $$i); \
		mkdir -p $(LOGDIR)/$$(dirname $$i); \
		prove --archive $(LOGDIR)/$$(dirname $$i) slow-*.t -vvv; \
		popd; \
	done

allNew: $(LOGDIR)
	 -for i in $$(find -name *.t | grep "slow\|quick"); do \
	     pushd $$(dirname $$i); \
		 echo "$$i";\
		 prove --archive $(LOGDIR) *.t; \
		 popd;\
	 done

quick: $(LOGDIR)
	-for i in `find -name "quick-*.t" | sort`; do\
		pushd $$(dirname $$i); \
        	mkdir -p $(LOGDIR)/$$(dirname $$i); \
		prove --archive $(LOGDIR)/$$(dirname $$i) quick-*.t -vvv; \
		popd; \
	done

quick-trc: $(LOGDIR)
	-for i in `find -name "quick-*.t" | sort`; do\
        	pushd $$(dirname $$i); \
        	mkdir -p $(LOGDIR)/$$(dirname $$i); \
        	timeout 1200s prove --archive $(LOGDIR)/$$(dirname $$i)  quick-*.t -vvv || echo $$(dirname $$i) >> timeout_tests; \
        	popd; \
    	done

slow: $(LOGDIR)
	-for i in `find -name "slow-*.t"`; do\
		pushd $$(dirname $$i); \
		mkdir -p $(LOGDIR)/$$(dirname $$i); \
		prove --archive $(LOGDIR)/$$(dirname $$i) slow-*.t -vvv; \
		popd; \
	done

specific: $(LOGDIR)
	-for i in ${TESTS}; do\
                pushd $$i; \
                mkdir -p $(LOGDIR)/$$i; \
		prove --archive $(LOGDIR)/$$i quick-*.t -vvv; \
                popd; \
        done

$(LOGDIR):
	mkdir -p $(LOGDIR)

submit-status:
	$(d)submit-status $(MACHINE) $(VERSION) $(LOGDIR)

submit-trc:
	$(d)submit-trc $(MACHINE) $(VERSION) $(LOGDIR)

.PHONY: $(LOGDIR) all slow quick submit-status submit-trc
