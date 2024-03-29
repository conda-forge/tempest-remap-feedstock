#!/usr/bin/env bash

set -x
set -e

if [[ -n "$mpi" && "$mpi" != "nompi" ]]; then
  export CC=mpicc
  export CXX=mpicxx
fi

# Attempting to fix:
#   dyld: lazy symbol binding failed: Symbol not found: _nc__create
#     Referenced from: .../lib/libTempestRemap.0.dylib
#     Expected in: flat namespace
# By following libnetcdf-feedstock's resolution of a similar problem, See:
# https://github.com/conda-forge/libnetcdf-feedstock/blob/1657d526348306d6e3e1f517e8c438b94ca484f9/recipe/build.sh#L9-L30
if [[ ${HOST} =~ .*darwin.* ]]; then
    export LDFLAGS=$(echo "${LDFLAGS}" | sed "s/-Wl,-dead_strip_dylibs//g")
fi

autoreconf -vif
./configure --prefix=${PREFIX} --host=${HOST} \
    --with-blas=${PREFIX} \
    --with-lapack=${PREFIX} \
    --with-netcdf=${PREFIX} \
    --with-hdf5=${PREFIX}
make install
