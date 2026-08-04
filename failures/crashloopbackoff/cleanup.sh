#!/bin/bash

set -e

kubectl delete deployment crashloop-demo -n chaos-lab --ignore-not-found=true