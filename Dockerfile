FROM debian:stretch

RUN apt-get update && \
    apt-get install -y bzip2 clang-format-3.9 clang-tidy-3.9 \
        cloc cmake curl doxygen gcc git graphviz g++ libpcap-dev lcov make \
        mpich python-dev python3 python3-pip valgrind autoconf automake libtool perl && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN cd /tmp && \
    curl -o cppcheck-1.80.tar.gz -L https://github.com/danmar/cppcheck/archive/1.80.tar.gz && \
    tar xf cppcheck-1.80.tar.gz && \
    cd cppcheck-1.80 && \
    mkdir build && \
    cmake ../cppcheck-1.80 && \
    make install && \
    cd .. && \
    rm -rf cppcheck-1.80*

RUN pip3 install --force-reinstall pip==9.0.3 && \
    pip3 install conan==1.9.1 coverage==4.4.2 flake8==3.5.0 gcovr==3.4 && \
    rm -rf /root/.cache/pip/*

ENV CONAN_USER_HOME=/conan

RUN mkdir $CONAN_USER_HOME && \
    conan

COPY files/registry.txt $CONAN_USER_HOME/.conan/

COPY files/default_profile $CONAN_USER_HOME/.conan/profiles/default

RUN ln -s /usr/lib/llvm-3.9/bin/clang-format /usr/bin/clang-format
RUN ln -s /usr/lib/llvm-3.9/bin/clang-tidy /usr/bin/clang-tidy

RUN conan install cmake_installer/3.10.0@conan/stable

RUN git clone https://github.com/ess-dmsc/build-utils.git && \
    cd build-utils && \
    git checkout c05ed046dd273a2b9090d41048d62b7d1ea6cdf3 && \
    make install

RUN adduser jenkins

RUN chown -R jenkins $CONAN_USER_HOME/.conan

USER jenkins

WORKDIR /home/jenkins
