FROM debian:buster

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y bzip2 clang-format clang-tidy \
        cloc cmake curl doxygen gcc git graphviz g++ flex lcov make ninja-build \
        mpich valgrind autoconf automake libtool perl build-essential \
        libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev \
        libncurses5-dev libncursesw5-dev xz-utils libffi-dev liblzma-dev \
        python3-pip && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN cd /tmp && \
    curl -o cppcheck-1.90.tar.gz -L https://github.com/danmar/cppcheck/archive/1.90.tar.gz && \
    tar xf cppcheck-1.90.tar.gz && \
    cd cppcheck-1.90 && \
    mkdir build && \
    cmake ../cppcheck-1.90 && \
    make install && \
    cd .. && \
    rm -rf cppcheck-1.90*

RUN pip3 install conan==1.46.0 coverage==4.4.2 flake8==3.5.0 gcovr==4.1 && \
    rm -rf /root/.cache/pip/*

ENV CONAN_USER_HOME=/conan

RUN mkdir $CONAN_USER_HOME && \
    conan

RUN git clone http://github.com/ess-dmsc/conan-configuration.git && \
    cd conan-configuration && \
    git checkout 7696e110684968b6dc821a86f9d6d206cf384e16 && \
    cd .. && \
    conan config install conan-configuration

COPY files/default_profile $CONAN_USER_HOME/.conan/profiles/default

# RUN ln -s /usr/lib/llvm-7/bin/clang-format /usr/bin/clang-format
# RUN ln -s /usr/lib/llvm-7/bin/clang-tidy /usr/bin/clang-tidy

RUN git clone https://github.com/ess-dmsc/build-utils.git && \
    cd build-utils && \
    git checkout c05ed046dd273a2b9090d41048d62b7d1ea6cdf3 && \
    make install

RUN adduser jenkins

RUN chown -R jenkins $CONAN_USER_HOME/.conan

RUN conan config set general.revisions_enabled=True

USER jenkins

WORKDIR /home/jenkins
