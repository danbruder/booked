FROM rust:1.58.1 as planner
WORKDIR /app
RUN cargo install cargo-chef 
COPY . .
RUN cargo chef prepare  --recipe-path recipe.json

FROM rust:1.58.1 as cacher
WORKDIR /app
RUN cargo install cargo-chef
COPY --from=planner /app/recipe.json recipe.json
RUN cargo chef cook --release --recipe-path recipe.json

FROM rust:1.58.1 AS builder
WORKDIR /app
COPY . .
COPY --from=cacher /app/target target
COPY --from=cacher $CARGO_HOME $CARGO_HOME
RUN cargo build --release

FROM rust:1.58.1 AS runtime
WORKDIR /app
EXPOSE 3030
COPY --from=builder /app/target/release/booked /usr/local/bin/booked
COPY --from=builder /app/assets assets
CMD ["booked"]
