################################################################################
#      This file is part of OpenELEC - http://www.openelec.tv
#      Copyright (C) 2009-2012 Stephan Raue (stephan@openelec.tv)
#
#  This Program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2, or (at your option)
#  any later version.
#
#  This Program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with OpenELEC.tv; see the file COPYING.  If not, write to
#  the Free Software Foundation, 51 Franklin Street, Suite 500, Boston, MA 02110, USA.
#  http://www.gnu.org/copyleft/gpl.html
################################################################################

PKG_NAME="Mesa"
PKG_VERSION="ckoenig-8d56907"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="OSS"
PKG_SITE="http://www.mesa3d.org/"
# PKG_URL="ftp://freedesktop.org/pub/mesa/9.2/MesaLib-$PKG_VERSION.tar.bz2"
PKG_URL="$DISTRO_SRC/Mesa-$PKG_VERSION.tar.xz"
PKG_DEPENDS="libXdamage libdrm expat libXext libXfixes libX11"
PKG_BUILD_DEPENDS_TARGET="toolchain Python-host makedepend:host libxml2-host expat glproto dri2proto libdrm libXext libXdamage libXfixes libXxf86vm libxcb libX11"
PKG_PRIORITY="optional"
PKG_SECTION="graphics"
PKG_SHORTDESC="mesa: 3-D graphics library with OpenGL API"
PKG_LONGDESC="Mesa is a 3-D graphics library with an API which is very similar to that of OpenGL*. To the extent that Mesa utilizes the OpenGL command syntax or state machine, it is being used with authorization from Silicon Graphics, Inc. However, the author makes no claim that Mesa is in any way a compatible replacement for OpenGL or associated with Silicon Graphics, Inc. Those who want a licensed implementation of OpenGL should contact a licensed vendor. While Mesa is not a licensed OpenGL implementation, it is currently being tested with the OpenGL conformance tests. For the current conformance status see the CONFORM file included in the Mesa distribution."

PKG_IS_ADDON="no"
PKG_AUTORECONF="yes"

# configure GPU drivers and dependencies:
  get_graphicdrivers

if [ "$LLVM_SUPPORT" = "yes" ]; then
  PKG_BUILD_DEPENDS_TARGET="$PKG_BUILD_DEPENDS_TARGET llvm"
  PKG_DEPENDS="$PKG_DEPENDS llvm"
  export LLVM_CONFIG="$SYSROOT_PREFIX/usr/bin/llvm-config-host"
  MESA_GALLIUM_LLVM="--enable-gallium-llvm --with-llvm-shared-libs"
else
  MESA_GALLIUM_LLVM="--disable-gallium-llvm"
fi

if [ "$VDPAU" = "yes" ]; then
  PKG_BUILD_DEPENDS_TARGET="$PKG_BUILD_DEPENDS_TARGET libvdpau"
  PKG_DEPENDS="$PKG_DEPENDS libvdpau"
  MESA_VDPAU="--enable-vdpau"
else
  MESA_VDPAU="--disable-vdpau"
fi

if [ "$MESA_VAAPI_SUPPORT" = "yes" ]; then
  PKG_BUILD_DEPENDS_TARGET="$PKG_BUILD_DEPENDS_TARGET libva"
  PKG_DEPENDS="$PKG_DEPENDS libva"
fi

XA_CONFIG="--disable-xa"
for drv in $GRAPHIC_DRIVERS; do
  [ "$drv" = "vmware" ] && XA_CONFIG="--enable-xa"
done

PKG_CONFIGURE_OPTS_TARGET="CC_FOR_BUILD=$HOST_CC \
                           CXX_FOR_BUILD=$HOST_CXX \
                           CFLAGS_FOR_BUILD= \
                           CXXFLAGS_FOR_BUILD= \
                           LDFLAGS_FOR_BUILD= \
                           X11_INCLUDES= \
                           DRI_DRIVER_INSTALL_DIR=$XORG_PATH_DRI \
                           DRI_DRIVER_SEARCH_DIR=$XORG_PATH_DRI \
                           --disable-debug \
                           --enable-texture-float \
                           --enable-asm \
                           --disable-selinux \
                           --enable-opengl \
                           --enable-glx-tls \
                           --enable-driglx-direct \
                           --disable-gles1 \
                           --disable-gles2 \
                           --disable-openvg \
                           --enable-dri \
                           --enable-glx \
                           --disable-osmesa \
                           --disable-egl \
                           --disable-xorg \
                           $XA_CONFIG \
                           --disable-gbm \
                           --disable-xvmc \
                           $MESA_VDPAU \
                           --disable-opencl \
                           --disable-xlib-glx \
                           --disable-gallium-egl \
                           --disable-gallium-gbm \
                           --disable-r600-llvm-compiler \
                           --disable-gallium-tests \
                           --enable-shared-glapi \
                           --disable-glx-tls \
                           --disable-gallium-g3dvl \
                           $MESA_GALLIUM_LLVM \
                           --disable-silent-rules \
                           --with-gl-lib-name=GL \
                           --with-osmesa-lib-name=OSMesa \
                           --with-gallium-drivers=$GALLIUM_DRIVERS \
                           --with-dri-drivers=$DRI_DRIVERS \
                           --with-expat=$SYSROOT_PREFIX/usr"

post_makeinstall_target() {
  # rename and relink for cooperate with nvidia drivers
    rm -rf $INSTALL/usr/lib/libGL.so
    rm -rf $INSTALL/usr/lib/libGL.so.1
    ln -sf libGL.so.1 $INSTALL/usr/lib/libGL.so
    ln -sf /var/lib/libGL.so $INSTALL/usr/lib/libGL.so.1
    mv $INSTALL/usr/lib/libGL.so.1.2.0 $INSTALL/usr/lib/libGL_mesa.so.1
}
