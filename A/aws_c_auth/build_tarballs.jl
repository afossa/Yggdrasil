# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder, Pkg

name = "aws_c_auth"
version = v"0.7.3"

# Collection of sources required to complete build
sources = [
    GitSource("https://github.com/awslabs/aws-c-auth.git",
              "df370cabd6bdfee7ce7d550daca19b6d14eb54b4"),
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/aws-c-auth
mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=${prefix} \
    -DCMAKE_PREFIX_PATH=${prefix} \
    -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TARGET_TOOLCHAIN} \
    -DBUILD_TESTING=OFF \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=OFF \
    ..
cmake --build . -j${nproc} --target install
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = supported_platforms()
filter!(p -> !(Sys.iswindows(p) && arch(p) == "i686"), platforms)

# The products that we will ensure are always built
products = [
    FileProduct("lib/libaws-c-auth.a", :libaws_c_auth),
]

# Dependencies that must be installed before this package can be built
dependencies = [
    # Direct deps
    BuildDependency("aws_c_cal_jll"),
    BuildDependency("aws_c_http_jll"),
    BuildDependency("aws_c_sdkutils_jll"),
    # Transitive deps
    BuildDependency("aws_c_compression_jll"),
    BuildDependency("aws_c_common_jll"),
    BuildDependency("aws_c_io_jll"),
    BuildDependency("aws_lc_jll"),
    BuildDependency("s2n_tls_jll"),
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies;
               julia_compat="1.6", preferred_gcc_version = v"5")