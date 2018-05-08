FROM debian:stretch

RUN apt-get update && \
    apt-get install -y bzip2 clang-format-3.9 clang-tidy-3.9 cloc cmake cppcheck curl doxygen gcc git graphviz \
        g++ lcov make mpich python3 python3-pip valgrind autoconf automake libtool perl && \
    apt-get autoremove -y && \
    apt-get clean

RUN pip3 install conan==1.0.2 coverage==4.4.2 flake8==3.5.0 gcovr==3.3 && \
    rm -rf /root/.cache/pip/*

ENV CONAN_USER_HOME=/conan

RUN mkdir $CONAN_USER_HOME && \
    conan

COPY files/registry.txt $CONAN_USER_HOME/.conan/

COPY files/default_profile $CONAN_USER_HOME/.conan/profiles/default

RUN git clone https://github.com/ess-dmsc/utils.git && \
    cd utils && \
    git checkout 3f89fad6e801471baabee446ba4d327e54642b32 && \
    make install

RUN adduser jenkins

RUN chown -R jenkins $CONAN_USER_HOME/.conan

USER jenkins

WORKDIR /home/jenkins
