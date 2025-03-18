FROM rust:1.85.0 as build-env
LABEL maintainer="yanorei32"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /usr/src
RUN cargo new timed-rs
COPY LICENSE Cargo.toml Cargo.lock /usr/src/timed-rs/
WORKDIR /usr/src/timed-rs
ENV CARGO_REGISTRIES_CRATES_IO_PROTOCOL=sparse
RUN	cargo install cargo-license && cargo license \
	--authors \
	--do-not-bundle \
	--avoid-dev-deps \
	--avoid-build-deps \
	--filter-platform "$(rustc -vV | sed -n 's|host: ||p')" \
	> CREDITS

RUN cargo build --release
COPY src/ /usr/src/timed-rs/src/

RUN touch src/* && cargo build --release

FROM debian:bullseye-slim@sha256:90e6d3bc46c9e60fd2285d7df3a931e6c9f106bfbca41772cf5c8779d5d835c3

WORKDIR /

COPY --chown=root:root --from=build-env \
	/usr/src/timed-rs/CREDITS \
	/usr/src/timed-rs/LICENSE \
	/usr/share/licenses/timed-rs/

COPY --chown=root:root --from=build-env \
	/usr/src/timed-rs/target/release/timed-rs \
	/usr/bin/timed-rs

CMD ["/usr/bin/timed-rs"]
