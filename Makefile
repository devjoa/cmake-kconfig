CMAKE_BINARY_DIR=build/Test
#Use  $(MAKEOVERRIDES) for variables


.PHONY: all
all:
	cmake --build $(CMAKE_BINARY_DIR) --parallel

.PHONY: configure
configure:
	cmake -B "${CMAKE_BINARY_DIR}" -GNinja

.PHONY: %
%:
	cmake --build $(CMAKE_BINARY_DIR) --parallel -- $@

