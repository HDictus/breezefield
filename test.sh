#!/bin/bash
mkdir test/breezefield
cp * test/breezefield
love test 

mkdir test/test_deep/deps
mkdir test/test_deep/deps/breezefield
cp * test/test_deep/deps/breezefield
love test/test_deep

mkdir test/test_rendering/breezefield
cp * test/test_rendering/breezefield
love test/test_rendering

mkdir test/test_queryareas/breezefield
cp * test/test_queryareas/breezefield
love test/test_queryareas