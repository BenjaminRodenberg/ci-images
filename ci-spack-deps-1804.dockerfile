# Build stage with Spack pre-installed and ready to be used
FROM spack/ubuntu-bionic:latest as builder

# " \

# What we want to install and how we want to install it
# is specified in a manifest file (spack.yaml)
RUN mkdir /opt/precice \
&&  (echo "spack:" \
&&   echo "  specs:" \
&&   echo "  - autoconf@2.69" \
&&   echo "  - automake@1.16.2" \
&&   echo "  - berkeley-db@18.1.40" \
&&   echo "  - boost@1.74.0" \ 
&&   echo "  - bzip2@1.0.8" \ 
&&   echo "  - cmake@3.18.4" \ 
&&   echo "  - diffutils@3.7" \ 
&&   echo "  - eigen@3.3.8" \ 
&&   echo "  - expat@2.2.9" \ 
&&   echo "  - gdbm@1.18.1" \ 
&&   echo "  - gettext@0.21" \ 
&&   echo "  - hdf5@1.10.7" \ 
&&   echo "  - hwloc@1.11.11" \ 
&&   echo "  - hypre@2.20.0" \ 
&&   echo "  - libbsd@0.10.0" \ 
&&   echo "  - libffi@3.3" \ 
&&   echo "  - libiconv@1.16" \ 
&&   echo "  - libpciaccess@0.16" \ 
&&   echo "  - libsigsegv@2.12" \ 
&&   echo "  - libtool@2.4.6" \ 
&&   echo "  - libuuid@1.0.3" \  
&&   echo "  - libxml2@2.9.10" \ 
&&   echo "  - m4@1.4.18" \ 
&&   echo "  - metis@5.1.0" \ 
&&   echo "  - ncurses@6.2" \ 
&&   echo "  - numactl@2.0.14" \  
&&   echo "  - openblas@0.3.10" \ 
&&   echo "  - openmpi@3.1.6" \ 
&&   echo "  - openssl@1.1.1h" \ 
&&   echo "  - parmetis@4.0.3" \ 
&&   echo "  - perl@5.30.3" \
&&   echo "  - petsc@3.14.0" \ 
&&   echo "  - pkgconf@1.7.3" \ 
&&   echo "  - python@3.8.6" \ 
&&   echo "  - readline@8.0" \ 
&&   echo "  - sqlite@3.33.0" \ 
&&   echo "  - tar@1.32" \ 
&&   echo "  - util-macros@1.19.1" \ 
&&   echo "  - xz@5.2.5" \
&&   echo "  - zlib@1.2.11" \ 
&&   echo "  view: /opt/view" \
&&   echo "  concretization: together" \
&&   echo "  config:" \
&&   echo "    install_tree: /opt/software") > /opt/spack-environment/spack.yaml

# Install the software, remove unecessary deps
RUN cd /opt/precice && spack env activate . && spack install --fail-fast && spack gc -y

# Strip all the binaries
RUN find -L /opt/view/* -type f -exec readlink -f '{}' \; | \
    xargs file -i | \
    grep 'charset=binary' | \
    grep 'x-executable\|x-archive\|x-sharedlib' | \
    awk -F: '{print $1}' | xargs strip -s

# Modifications to the environment that are necessary to run
RUN cd /opt/precice && \
    spack env activate --sh -d . >> /etc/profile.d/z10_precice.sh


# Bare OS image to run the installed executables
FROM ubuntu:18.04

COPY --from=builder /opt/precice /opt/precice
COPY --from=builder /opt/software /opt/software
COPY --from=builder /opt/view /opt/view
COPY --from=builder /etc/profile.d/z10_precice.sh /etc/profile.d/z10_precice.sh




ENTRYPOINT ["/bin/bash", "--rcfile", "/etc/profile", "-l"]
