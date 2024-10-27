FROM gcc:latest

WORKDIR /usr/src/BlackMarlinExec

COPY . .

RUN apt-get update && apt-get install -y \
    clang-format \
    doxygen \
    && rm -rf /var/lib/apt/lists/*

RUN make all
