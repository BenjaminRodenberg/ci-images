FROM centos:7

# Add the precice user to run test with mpi
RUN useradd -m -s /bin/bash precice
ENV PRECICE_USER=precice

# Install necessary dependencies for preCICE and PETSc
RUN yum -y install epel-release centos-release-scl scl-utils && \
    yum -y groupinstall 'Development Tools' && \
    yum -y update  && \
    yum -y install \
        blas-devel \
        boost169-devel \
        ccache \
        centos-release-scl \
        cmake3 \
        curl \
        devtoolset-7 \
        eigen3 \
        lapack-devel \
        libxml2-devel \
        openmpi-devel \
        python3-devel \
        wget \
    && \
    echo "module load mpi/openmpi-x86_64" > /etc/modules-load.d/openmpi.conf && \
    echo -e "export BOOST_LIBRARYDIR=/usr/lib64/boost169\nexport BOOST_INCLUDEDIR=/usr/include/boost169" > /etc/profile.d/99-boost.sh

# Install PETSc
COPY petsc/99-petsc-env.sh /etc/profile.d/99-petsc-env.sh
COPY petsc/petsc-install.sh  petsc/petsc-install.sh

# We have to compile petsc with devtoolset-7 enabled
RUN [ "/usr/bin/scl", "enable", "devtoolset-7", "bash --login -c 'module load mpi/openmpi-x86_64 && ./petsc/petsc-install.sh && rm -r petsc/'" ]

# Run interactively in a devtoolset-7 environment using a bash login shell
CMD [ "/usr/bin/scl", "enable", "devtoolset-7", "bash --login" ]
