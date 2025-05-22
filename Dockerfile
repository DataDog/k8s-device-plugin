ARG BUILDER_IMAGE
ARG BASE_IMAGE

FROM ${BUILDER_IMAGE} AS build

WORKDIR /build
COPY . .

RUN mkdir /artifacts
RUN make PREFIX=/artifacts cmds

FROM ${BASE_IMAGE}

LABEL maintainers="Compute"

ENV NVIDIA_DISABLE_REQUIRE="true"
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility

COPY --from=build /artifacts/config-manager         /usr/bin/config-manager
COPY --from=build /artifacts/gpu-feature-discovery  /usr/bin/gpu-feature-discovery
COPY --from=build /artifacts/mps-control-daemon     /usr/bin/mps-control-daemon
COPY --from=build /artifacts/nvidia-device-plugin   /usr/bin/nvidia-device-plugin

ENTRYPOINT ["nvidia-device-plugin"]
