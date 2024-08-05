# Compiler and flags
CC = gcc
CFLAGS = -Wall -Wextra -pedantic -O2

# Directories
SRC_DIR = src
OBJ_DIR = obj
BIN_DIR = bin
INC_DIR = include

# Target executable
TARGET = $(BIN_DIR)/BlackMarlinExec

# Source and object files
SRCS = $(wildcard $(SRC_DIR)/*.c)
OBJS = $(SRCS:$(SRC_DIR)/%.c=$(OBJ_DIR)/%.o)
DEPS = $(SRCS:$(SRC_DIR)/%.c=$(OBJ_DIR)/%.d)

# Include directories
INCLUDES = -I$(INC_DIR)

# Rules
.PHONY: all clean docker-build docker-run

all: $(TARGET)

$(TARGET): $(OBJS)
	@mkdir -p $(BIN_DIR)
	$(CC) $(CFLAGS) $(OBJS) -o $(TARGET)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(OBJ_DIR)
	$(CC) $(CFLAGS) $(INCLUDES) -MMD -c $< -o $@

-include $(DEPS)

clean:
	rm -rf $(OBJ_DIR) $(BIN_DIR)

install: $(TARGET)
	install -m 0755 $(TARGET) /usr/local/bin

uninstall:
	rm -f /usr/local/bin/BlackMarlinExec

test: $(TARGET)
	./$(TARGET) --test

format:
	clang-format -i $(SRCS)

lint:
	cpplint $(SRCS)

docs:
	doxygen Doxyfile

help:
	@echo "Usage: make SRC_DIR"
	@echo "Targets:"
	@echo "  all          - Build the project"
	@echo "  clean        - Remove build artifacts"
	@echo "  install      - Install the executable"
	@echo "  uninstall    - Remove the installed executable"
	@echo "  test         - Run tests"
	@echo "  format       - Format source code"
	@echo "  lint         - Lint source code"
	@echo "  docs         - Generate documentation"
	@echo "  help         - Display this help message"
	@echo "  docker-setup - Build the RAW-Docker"
	@echo "  docker-build - Build the Docker image"
	@echo "  docker-run   - Run the Docker container"

docker-build:
	docker build -t blackmarlinexec .

docker-run:
	docker run --rm -it blackmarlinexec
