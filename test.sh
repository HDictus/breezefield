#!/bin/bash
mkdir test/breezefield
cp * test/breezefield
love test 

mkdir test/test_deep/deps
mkdir test/test_deep/deps/breezefield
cp * test/test_deep/deps/breezefield
love test/test_deep
