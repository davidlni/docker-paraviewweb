FROM ubuntu:16.10

MAINTAINER Thomas Wollmann <thomas.wollmann@bioquant.uni-heidelberg.de>

RUN apt-get -q update && \
    apt-get -q -y install build-essential software-properties-common \
    curl wget git python python-dev make libosmesa6-dev libglu1-mesa-dev && \
    curl -s https://bootstrap.pypa.io/get-pip.py | python2

RUN apt-get -q -y install cmake libhdf5-dev libpng-dev libjpeg-dev libtiff5-dev libxml2-dev zlib1g-dev libpugixml-dev libogg-dev libtheora-dev python-twisted python-autobahn expat libfreetype6-dev python-zope.interface libgl2ps-dev liblz4-dev libprotobuf-dev python-protobuf protobuf-compiler

# libprotobuf-dev liblz4-dev libgl2ps-dev  libnetcdf-dev

#        -D VTK_USE_SYSTEM_JSONCPP:BOOL=OFF \
#	-D VTK_USE_SYSTEM_NETCDF=OFF \	
#         -D PARAVIEW_BUILD_PLUGIN_*:BOOL=OFF \

#protobuf
#verdict
#exodusII
# KWSys
# alglib
# netcdf
# VPIC

# Compile 
RUN mkdir -p /root/build && cd /root/build && \
    git clone -b v5.1.0 --single-branch git://paraview.org/ParaView.git pv-git && cd pv-git && git submodule init && git submodule update && \
    mkdir -p /root/build/pv-bin && cd /root/build/pv-bin && \
    cmake \
        -D CMAKE_BUILD_TYPE=Release \
	-D VTK_Group_CoProcessing:BOOL=OFF \
	-D VTK_Group_Imaging:BOOL=OFF \
	-D VTK_Group_MPI:BOOL=OFF \
	-D VTK_Group_ParaViewCore:BOOL=OFF \
	-D VTK_Group_ParaViewQt:BOOL=OFF \
	-D VTK_Group_ParaViewRendering:BOOL=OFF \
	-D VTK_Group_Qt:BOOL=OFF \
	-D VTK_Group_Rendering:BOOL=OFF \
	-D VTK_Group_StandAlone:BOOL=OFF \
	-D VTK_Group_Tk:BOOL=OFF \
	-D VTK_Group_Views:BOOL=OFF \
	-D VTK_Group_ParaViewPython:BOOL=ON \
        -D BUILD_TESTING:BOOL=OFF \
        -D BUILD_DOCUMENTATION:BOOL=OFF \
	-D BUILD_EXAMPLES:BOOL=OFF \
	-D PARAVIEW_BUILD_QT_GUI:BOOL=OFF \
        -D PARAVIEW_ENABLE_PYTHON:BOOL=ON \
	-D PARAVIEW_ENABLE_WEB:BOOL=ON \
        -D PARAVIEW_INSTALL_DEVELOPMENT_FILES:BOOL=OFF \
        -D OPENGL_INCLUDE_DIR=/usr/include \
        -D OPENGL_gl_LIBRARY="" \
        -D OPENGL_glu_LIBRARY=/usr/lib/x86_64-linux-gnu/libGLU.so \
        -D VTK_USE_X:BOOL=OFF \
	-D VTK_USE_OFFSCREEN:BOOL=ON \
	-D VTK_USE_SYSTEM_PROTOBUF:BOOL=ON \
	-D VTK_USE_SYSTEM_HDF5:BOOL=ON \
	-D VTK_USE_SYSTEM_ZLIB:BOOL=ON \
	-D VTK_USE_SYSTEM_JPEG:BOOL=ON \
	-D VTK_USE_SYSTEM_PNG:BOOL=ON \
	-D VTK_USE_SYSTEM_TIFF:BOOL=ON \
	-D VTK_USE_SYSTEM_OGGTHEORA=ON \
	-D VTK_USE_SYSTEM_PUGIXML:BOOL=ON \
	-D VTK_USE_SYSTEM_LIBXML2:BOOL=ON \
	-D VTK_USE_SYSTEM_FREETYPE:BOOL=ON \
	-D VTK_USE_SYSTEM_TWISTED:BOOL=ON \
        -D VTK_USE_SYSTEM_AUTOBAHN:BOOL=ON \
	-D VTK_USE_SYSTEM_GL2PS:BOOL=ON \
	-D VTK_USE_SYSTEM_EXPAT:BOOL=ON \
	-D VTK_USE_SYSTEM_ZOPE:BOOL=ON \
        -D VTK_OPENGL_HAS_OSMESA:BOOL=ON \
        -D OSMESA_INCLUDE_DIR=/usr/include \
        -D OSMESA_LIBRARY=/usr/lib/x86_64-linux-gnu/libOSMesa.so \
        ../pv-git && \
    make -j4 && make install && \
    cd / && rm -rf /root/build

# Proxy
RUN apt-get -q -y install nginx
ADD nginx.conf /etc/nginx/sites-available/paraviewweb
RUN ln -s /etc/nginx/sites-available/paraviewweb /etc/nginx/sites-enabled/paraviewweb && \
    rm /etc/nginx/sites-enabled/default

RUN mkdir /input
RUN mkdir /output
WORKDIR /input

ENV DEBUG=false \
    GALAXY_WEB_PORT=10000 \
    NOTEBOOK_PASSWORD=none \
    CORS_ORIGIN=none \
    DOCKER_PORT=none \
    API_KEY=none \
    HISTORY_ID=none \
    REMOTE_HOST=none \
    GALAXY_URL=none

EXPOSE 8777

ADD startup.sh /
RUN chmod +x /startup.sh
CMD /startup.sh
