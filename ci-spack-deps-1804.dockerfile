# Build stage with Spack pre-installed and ready to be used
FROM spack/ubuntu-bionic:latest
RUN spack install boost@1.74.0 cmake@3.18.4 eigen@3.3.8 petsc@3.14.1
RUN spack env create precice
