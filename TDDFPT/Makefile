# Makefile for TDDFPT
include ../make.inc

default: all

all: bindir tddfpt

bindir:
	if [ ! -d bin ] ; then mkdir bin; fi;

tddfpt:
	( cd src ; $(MAKE) all || exit 1 ) 

clean :
	( cd src ; $(MAKE) clean ; )

doc:
	if test -d Doc ; then \
        ( cd Doc ; $(MAKE) all || exit 1 ) ; fi

doc_clean:
	if test -d Doc ; then \
        (cd Doc ; $(MAKE) clean ) ; fi

distclean: clean
	if [ -d bin ] ; then rm -rf bin; fi;

