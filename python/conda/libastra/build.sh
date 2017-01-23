#!/bin/sh

cd $SRC_DIR/build/linux

$SRC_DIR/build/linux/autogen.sh

# Add C++11 to compiler flags if nvcc supports it, mostly to work around a boost bug
NVCC=$CUDA_ROOT/bin/nvcc
echo "int main(){return 0;}" > $CONDA_PREFIX/test.cu
$NVCC $CONDA_PREFIX/test.cu -ccbin $CC --std=c++11 -o $CONDA_PREFIX/test.out > /dev/null 2>&1 && EXTRA_NVCCFLAGS="--std=c++11" || true
rm -f $CONDA_PREFIX/test.out

$SRC_DIR/build/linux/configure --with-install-type=prefix --with-cuda=$CUDA_ROOT --prefix=$CONDA_PREFIX NVCCFLAGS="-ccbin $CC -I$CONDA_PREFIX/include $EXTRA_NVCCFLAGS" CC=$CC CXX=$CXX CPPFLAGS="-I$CONDA_PREFIX/include"

make install-libraries


test -d $CUDA_ROOT/lib64 && LIBPATH="$CUDA_ROOT/lib64" || LIBPATH="$CUDA_ROOT/lib"

case `uname` in
  Darwin*)
    cp -P $LIBPATH/libcudart.*.dylib $CONDA_PREFIX/lib
    cp -P $LIBPATH/libcufft.*.dylib $CONDA_PREFIX/lib
  *)
    cp -P $LIBPATH/libcudart.so.* $CONDA_PREFIX/lib
    cp -P $LIBPATH/libcufft.so.* $CONDA_PREFIX/lib
    ;;
esac
