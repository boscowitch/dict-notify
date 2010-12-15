ifndef ${DESTDIR}
DESTDIR=/
endif

all:
	valac dict-notify.vala dictclientlib/dictconnection.vala  --pkg glib-2.0 --pkg libnotify --pkg gio-2.0 
install:
	sudo cp dict-notify ${DESTDIR}/usr/bin/dict-notify
