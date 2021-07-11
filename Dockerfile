FROM rust as planner
WORKDIR tideexample
# We only pay the installation cost once, 
# it will be cached from the second build onwards
# To ensure a reproducible build consider pinning 
# the cargo-chef version with `--version X.X.X`
RUN cargo install cargo-chef 
COPY . .
RUN cargo chef prepare  --recipe-path recipe.json

FROM rust as cacher
WORKDIR tideexample
RUN cargo install cargo-chef
COPY --from=planner /tideexample/recipe.json recipe.json
RUN cargo chef cook --release --recipe-path recipe.json

FROM rust as builder
WORKDIR tideexample
COPY . .
# Copy over the cached dependencies
COPY --from=cacher /tideexample/target target
COPY --from=cacher /usr/local/cargo /usr/local/cargo
RUN cargo build --release --bin tideexample

FROM rust as runtime
WORKDIR tideexample

COPY --from=builder /tideexample/target/release/tideexample /usr/local/bin

# Add Tini, allowing us to avoid running as PID 1, which doesn't pickup SIGTERM signals
RUN apt-get update 
RUN apt-get install tini
ENTRYPOINT ["/usr/bin/tini", "--"]

# ENTRYPOINT ["/usr/local/bin/tideexample"]
CMD ["/usr/local/bin/tideexample"]

