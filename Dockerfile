FROM denoland/deno:alpine AS builder

RUN apk add --no-cache git

RUN git clone https://github.com/iv-org/invidious-companion.git /app

WORKDIR /app

RUN rm deno.lock

RUN rm deno.json

COPY ./deno.json /app/deno.json

RUN deno outdated --update --latest -- --allow-import

RUN deno task compile

FROM gcr.io/distroless/cc

WORKDIR /app

COPY --from=builder /app/invidious_companion /app/invidious_companion
COPY --from=builder /app/config/ /app/config/

ENV PORT="8282" \
    HOST="::"

EXPOSE 8282/tcp
CMD ["/app/invidious_companion"]
