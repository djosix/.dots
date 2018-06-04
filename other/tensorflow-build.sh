#!/bin/bash

cd /tmp

[ ! "`which bazel`" ] \
    && wget 'https://github.com/bazelbuild/bazel/releases/download/0.5.3/bazel-0.5.3-installer-linux-x86_64.sh' -o install-bazel.sh \
    && sudo bash install-bazel.sh

[ ! -d tensorflow ] \
    && git clone --depth 1 https://github.com/tensorflow/tensorflow

cd tensorflow

./configure

bazel build --config=opt //tensorflow/tools/pip_package:build_pip_package
bazel-bin/tensorflow/tools/pip_package/build_pip_package ./tensorflow_pkg
pip install ./tensorflow_pkg/*.whl

