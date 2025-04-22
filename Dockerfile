FROM denoland/deno:alpine AS builder

RUN apk add --no-cache git

RUN git clone https://github.com/iv-org/invidious-companion.git /app

WORKDIR /app

RUN rm deno.lock

RUN rm deno.json

COPY ./deno.json /app/deno.json

RUN deno upgrade

RUN deno outdated --update --latest

RUN deno task compile

RUN mkdir -p /var/tmp/youtubei.js

FROM scratch

COPY --from=builder /lib/ld-linux-* /lib/
COPY --from=builder /usr/local/lib/libgcc_s.so.1 /usr/local/lib/libgcc_s.so.1
COPY --from=builder /usr/local/lib/libdl.so.2 /usr/local/lib/libdl.so.2
COPY --from=builder /usr/local/lib/libpthread.so.0 /usr/local/lib/libpthread.so.0
COPY --from=builder /usr/local/lib/libm.so.6 /usr/local/lib/libm.so.6
COPY --from=builder /usr/local/lib/libc.so.6 /usr/local/lib/libc.so.6

ENV LD_LIBRARY_PATH="/usr/local/lib"

WORKDIR /app

COPY --from=builder /app/invidious_companion /app/invidious_companion
COPY --from=builder /app/config/ /app/config/
COPY --from=builder /var/tmp/youtubei.js /var/tmp/youtubei.js

ENV PORT="8282" \
    HOST="::"

EXPOSE 8282/tcp
CMD ["/app/invidious_companion"]
