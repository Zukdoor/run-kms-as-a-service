#!/bin/bash -x
set -e

exec /kms-omni-build/build-Debug/kurento-media-server/server/kurento-media-server \
  --modules-path=/kms-omni-build/build-Debug \
  --modules-config-path=/kms-omni-build/build-Debug/modules_config \
  --conf-file=/kms-omni-build/build-Debug/config/kurento.conf.json \
  --gst-plugin-path=/kms-omni-build/build-Debug "$@"
