#!/bin/bash

set -e

sudo ldconfig

exec "$@"