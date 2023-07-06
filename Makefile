WAYLAND_PROTOCOLS_DIR != pkg-config --variable=pkgdatadir wayland-protocols
WAYLAND_SCANNER := wayland-scanner

PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin

VERSION="0.5.0"

CFLAGS ?= -Wall -Wextra -Wno-unused-parameter -Wno-parentheses -Wno-format-overflow -I/usr/local/include -I/usr/local/include/libepoll-shim
override CFLAGS += -DVERSION=\"$(VERSION)\"


VPATH=$(WAYLAND_PROTOCOLS_DIR)/stable/xdg-shell:$(WAYLAND_PROTOCOLS_DIR)/unstable/xdg-decoration
LIBS=-L/usr/local/lib -R/usr/local/lib -lm -lutil -lwayland-client -lwayland-cursor -lxkbcommon -Ltsm -lhtsm -lepoll-shim
OBJ=xdg-shell.o xdg-decoration-unstable-v1.o gtk-primary-selection.o glyph.o main.o
GEN=xdg-shell.c xdg-shell.h xdg-decoration-unstable-v1.c \
	xdg-decoration-unstable-v1.h gtk-primary-selection.c gtk-primary-selection.h

havoc: tsm $(OBJ)
	$(CC) $(LDFLAGS) -o $@ $(OBJ) $(LIBS)

install: havoc
	install -D -t $(DESTDIR)$(BINDIR) havoc

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/havoc

clean:
	$(MAKE) -C tsm clean
	rm -f havoc $(GEN) $(OBJ)

$(OBJ): $(GEN)

%.c: %.xml
	$(WAYLAND_SCANNER) private-code < $< > $@

%.h: %.xml
	$(WAYLAND_SCANNER) client-header < $< > $@

tsm:
	$(MAKE) -C $@

.PHONY: install uninstall clean tsm
