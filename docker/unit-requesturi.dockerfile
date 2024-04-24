FROM php:8.3-cli-bullseye

LABEL org.opencontainers.image.title="Unit (php8.3 custom)"
LABEL org.opencontainers.image.description="Local build of unit from specific point"
LABEL org.opencontainers.image.url="https://unit.nginx.org"
LABEL org.opencontainers.image.source="https://github.com/nginx/unit"
LABEL org.opencontainers.image.documentation="https://unit.nginx.org/installation/#docker-images"
LABEL org.opencontainers.image.vendor="NGINX Docker Maintainers <docker-maint@nginx.com>"
LABEL org.opencontainers.image.version="1.32.0-local"

WORKDIR /usr/src/unit/unit
COPY unit/ .

RUN set -ex \
    && apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y ca-certificates git build-essential libssl-dev libpcre2-dev curl pkg-config

RUN mkdir -p /usr/lib/unit/modules /usr/lib/unit/debug-modules

RUN NCPU="$(getconf _NPROCESSORS_ONLN)" \
    && DEB_HOST_MULTIARCH="$(dpkg-architecture -q DEB_HOST_MULTIARCH)" \
    && CC_OPT="$(DEB_BUILD_MAINT_OPTIONS="hardening=+all,-pie" DEB_CFLAGS_MAINT_APPEND="-Wp,-D_FORTIFY_SOURCE=2 -fPIC" dpkg-buildflags --get CFLAGS)"

RUN LD_OPT="$(DEB_BUILD_MAINT_OPTIONS="hardening=+all,-pie" DEB_LDFLAGS_MAINT_APPEND="-Wl,--as-needed -pie" dpkg-buildflags --get LDFLAGS)" \
    && CONFIGURE_ARGS_MODULES="--prefix=/usr \
                --statedir=/var/lib/unit \
                --control=unix:/var/run/control.unit.sock \
                --runstatedir=/var/run \
                --pid=/var/run/unit.pid \
                --logdir=/var/log \
                --log=/var/log/unit.log \
                --tmpdir=/var/tmp \
                --user=unit \
                --group=unit \
                --openssl \
                --libdir=/usr/lib/$DEB_HOST_MULTIARCH"

RUN CONFIGURE_ARGS="$CONFIGURE_ARGS_MODULES \
                --njs"

RUN make -j $NCPU -C pkg/contrib .njs
RUN export PKG_CONFIG_PATH=$(pwd)/pkg/contrib/njs/build
RUN ./configure $CONFIGURE_ARGS --cc-opt="$CC_OPT" --ld-opt="$LD_OPT" --modulesdir=/usr/lib/unit/debug-modules --debug
RUN make -j $NCPU unitd
RUN install -pm755 build/sbin/unitd /usr/sbin/unitd-debug
RUN make clean
RUN ./configure $CONFIGURE_ARGS --cc-opt="$CC_OPT" --ld-opt="$LD_OPT" --modulesdir=/usr/lib/unit/modules
RUN make -j $NCPU unitd
RUN install -pm755 build/sbin/unitd /usr/sbin/unitd
RUN make clean \
    && /bin/true
RUN ./configure $CONFIGURE_ARGS_MODULES --cc-opt="$CC_OPT" --modulesdir=/usr/lib/unit/debug-modules --debug
RUN ./configure php
RUN make -j $NCPU php-install
RUN make clean
RUN ./configure $CONFIGURE_ARGS_MODULES --cc-opt="$CC_OPT" --modulesdir=/usr/lib/unit/modules
RUN ./configure php
RUN make -j $NCPU php-install
RUN cd \
    && rm -rf /usr/src/unit \
    && for f in /usr/sbin/unitd /usr/lib/unit/modules/*.unit.so; do \
        ldd $f | awk '/=>/{print $(NF-1)}' | while read n; do dpkg-query -S $n; done | sed 's/^\([^:]\+\):.*$/\1/' | sort | uniq >> /requirements.apt; \
       done

RUN savedAptMark="$(apt-mark showmanual)" \
    && apt-mark showmanual | xargs apt-mark auto > /dev/null \
    && { [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; } \
    && ldconfig

RUN mkdir -p /var/lib/unit/ \
    && mkdir -p /docker-entrypoint.d/

RUN groupadd --gid 999 unit \
    && useradd \
         --uid 999 \
         --gid unit \
         --no-create-home \
         --home /nonexistent \
         --comment "unit user" \
         --shell /bin/false \
         unit

RUN apt-get update \
    && apt-get --no-install-recommends --no-install-suggests -y install curl $(cat /requirements.apt) \
    && apt-get purge -y --auto-remove build-essential

RUN rm -rf /var/lib/apt/lists/* \
    && rm -f /requirements.apt \
    && ln -sf /dev/stderr /var/log/unit.log

COPY unit/pkg/docker/docker-entrypoint.sh /usr/local/bin/
COPY unit/pkg/docker/welcome.* /usr/share/unit/welcome/

STOPSIGNAL SIGTERM

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
EXPOSE 80
CMD ["unitd", "--no-daemon", "--control", "unix:/var/run/control.unit.sock"]
