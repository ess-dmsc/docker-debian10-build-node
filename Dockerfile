FROM debian:stretch

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y bzip2 clang-format-3.9 clang-tidy-3.9 \
        cloc cmake curl doxygen gcc git graphviz g++ libpcap-dev lcov make \
        mpich valgrind autoconf automake libtool perl build-essential \
        libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev \
        libncurses5-dev libncursesw5-dev xz-utils libffi-dev liblzma-dev && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN cd /tmp && \
    curl -o Python-3.6.8.tgz -L https://www.python.org/ftp/python/3.6.8/Python-3.6.8.tgz && \
    tar xf Python-3.6.8.tgz && \
    cd Python-3.6.8 && \
    ./configure --enable-optimizations --with-ensurepip=install && \
    make && \
    make altinstall && \
    cd .. && \
    rm -rf Python-3.6.8*

RUN cd /tmp && \
    curl -o cppcheck-1.86.tar.gz -L https://github.com/danmar/cppcheck/archive/1.86.tar.gz && \
    tar xf cppcheck-1.86.tar.gz && \
    cd cppcheck-1.86 && \
    mkdir build && \
    cmake ../cppcheck-1.86 && \
    make install && \
    cd .. && \
    rm -rf cppcheck-1.86*

RUN pip3.6 install conan==1.15.0 coverage==4.4.2 flake8==3.5.0 gcovr==4.1 && \
    rm -rf /root/.cache/pip/*

ENV CONAN_USER_HOME=/conan

RUN mkdir $CONAN_USER_HOME && \
    conan

COPY files/remotes.json $CONAN_USER_HOME/.conan/
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
