FROM golang:1.24-alpine AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY main.go ./
RUN CGO_ENABLED=0 GOOS=linux go build -o dr-app .

FROM alpine:3.20

RUN apk --no-cache add ca-certificates

WORKDIR /root/

COPY --from=builder /app/dr-app .

EXPOSE 80

CMD ["./dr-app"]