#  Makefile - makefile for MsdScript
#  Date: Spring 2024

# These are rules for all three "versions"/entry points that use the base MsdScript source code.
# See the README for more information.
# As used below in various combinations:
#     CLI: referring to the command-line execution of MsdScript
#     FUZZ: referring to the fuzz-testing of MsdScript
#     GUI: referring to the (Qt) GUI version of MsdScript

##################################  TARGETS  ##################################

# all - see the rule itself, it changes a lot
# run - runs msdscript
# build - builds msdscript

# msdscript - builds + runs the base program (CLI version)
# fuzz - builds + runs the fuzz tester
# gui - builds + runs the base program with the gui

# help - runs program with "--help" argument
# test - runs program with "--test" argument
# interp - runs program with "--interp" argument
# print - runs program with "--print" argument
# pprint - runs program with "--pretty-print" argument

# open - updates documentation, opens doxygen index.html
# pdf - uses pdflatex to make a pdf of Doxygen documentation
# doc - updates/produces Doxygen documentation files

# clean - deletes msdscript and test_msdscript executables

##################################  VARIABLES  ################################

# LAYOUT
DIR_SRC_CLI = src
DIR_SRC_FUZZ = tests/fuzz/drivers
DIR_SRC_GUI = gui

DIR_BIN = bin
DIR_OBJ = $(DIR_BIN)/obj

DIR_OBJ_CLI = $(DIR_OBJ)/src
DIR_OBJ_FUZZ = $(DIR_OBJ)/test
DIR_OBJ_GUI = $(DIR_OBJ)/gui

# IMPLEMENTATION FILES / HEADERS
IMPLS_CLI := $(wildcard $(DIR_SRC_CLI)/*.cpp)
IMPLS_FUZZ := $(wildcard $(DIR_SRC_FUZZ)/*.cpp)
IMPLS_GUI := $(wildcard $(DIR_SRC_GUI)/*.cpp)

HEADERS_CLI := $(wildcard $(DIR_SRC_CLI)/*.h)
HEADERS_FUZZ := $(wildcard $(DIR_SRC_FUZZ)/*.h)
HEADERS_GUI := $(wildcard $(DIR_SRC_GUI)/*.h)

# COMPILATION
COMPILER = c++
COMPILER_FLAGS = -std=c++17

# OBJECT FILES
OBJS_CLI := $(patsubst $(DIR_SRC_CLI)/%.cpp, $(DIR_OBJ_CLI)/%.o, $(IMPLS_CLI))
OBJS_FUZZ := $(patsubst $(DIR_SRC_FUZZ)/%.cpp, $(DIR_OBJ_FUZZ)/%.o, $(IMPLS_FUZZ))
OBJS_GUI := $(patsubst $(DIR_SRC_GUI)/%.cpp,  $(DIR_OBJ_GUI)/%.o,  $(IMPLS_GUI))

# Base objects excluding main.o (for fuzz/gui links)
OBJ_CLI_NOMAIN := $(filter-out $(DIR_OBJ_CLI)/main.o, $(OBJS_CLI))

# EXECUTABLES
EXECUTABLE_CLI = $(DIR_BIN)/msd-script
EXECUTABLE_FUZZ = $(DIR_BIN)/msd-test
EXECUTABLE_GUI = $(DIR_BIN)/msd-gui

# Qt6
ifneq ($(filter gui,$(MAKECMDGOALS)),)
QT_PREFIX := $(HOME)/Qt/6.10.0/macos
QT_CFLAGS := -F$(QT_PREFIX)/lib
QT_LIBS := -F$(QT_PREFIX)/lib -framework QtCore -framework QtGui -framework QtWidgets
MOC := $(QT_PREFIX)/bin/moc
endif

# DOXYGEN
DOXY_CONFIG = Doxyfile
DOXY_OUTPUT = docs

# MISC
# This just gives a default binary as a required argument for fuzz tester (the `msdscript0` executable)
TEST_ARGS ?= msdscript0

################################  DIRECTIVES  #################################

.SILENT:
.PHONY: all run build msdscript fuzz gui help test interp print pprint open pdf doc clean

###################################  RULES  ###################################

all: msdscript
run: all ; ./$(EXECUTABLE_CLI)

# CLI PROGRAM
msdscript: $(EXECUTABLE_CLI)
	@echo "...building msdscript..." && ./$(EXECUTABLE_CLI)

$(EXECUTABLE_CLI): $(OBJS_CLI)
	@mkdir -p $(DIR_BIN)
	$(COMPILER) $(COMPILER_FLAGS) -fsanitize=undefined $^ -o $@

$(DIR_OBJ_CLI)/%.o: $(DIR_SRC_CLI)/%.cpp $(HEADERS_CLI)
	@mkdir -p $(DIR_OBJ_CLI) $(DIR_BIN)
	$(COMPILER) $(COMPILER_FLAGS) -c $< -o $@

# FUZZ TESTER
fuzz: $(EXECUTABLE_FUZZ)
	@echo "...building fuzz..." && ./$(EXECUTABLE_FUZZ) $(TEST_ARGS)
$(EXECUTABLE_FUZZ): $(OBJS_FUZZ) $(OBJ_CLI_NOMAIN)
	@mkdir -p $(DIR_BIN)
	$(COMPILER) $(COMPILER_FLAGS) $^ -o $@

$(DIR_OBJ_FUZZ)/%.o: $(DIR_SRC_FUZZ)/%.cpp $(HEADERS_FUZZ) # tests includes headers from src with -Isrc
	@mkdir -p $(DIR_OBJ_FUZZ) $(DIR_BIN)
	$(COMPILER) $(COMPILER_FLAGS) -Isrc -c $< -o $@

# GUI
gui: $(EXECUTABLE_GUI)
	@echo "...building gui..." && ./$(EXECUTABLE_GUI)

# moc generation (only needed if gui/msdwidget.h has Q_OBJECT)
$(DIR_OBJ_GUI)/moc_msdwidget.cpp: $(DIR_SRC_GUI)/msdwidget.h | $(DIR_OBJ_GUI)
	$(MOC) $(QT_CFLAGS) -o $@ $<
$(DIR_OBJ_GUI)/moc_msdwidget.o: $(DIR_OBJ_GUI)/moc_msdwidget.cpp | $(DIR_OBJ_GUI)
	$(COMPILER) $(COMPILER_FLAGS) $(QT_CFLAGS) -c $< -o $@
# add moc object to GUI objects
OBJ_GUI += $(DIR_OBJ_GUI)/moc_msdwidget.o

# compile GUI objs with -Isrc and Qt cflags
$(DIR_OBJ_GUI)/%.o: $(DIR_SRC_GUI)/%.cpp $(HEADERS_GUI)
	@mkdir -p $(DIR_OBJ_GUI) $(DIR_BIN)
	$(COMPILER) $(COMPILER_FLAGS) -Isrc $(QT_CFLAGS) -c $< -o $@

# link GUI against core objects (excluding main.o) + Qt libs
$(EXECUTABLE_GUI): $(OBJS_GUI) $(OBJ_CLI_NOMAIN)
	@mkdir -p $(DIR_BIN)
	$(COMPILER) $(COMPILER_FLAGS) $^ -o $@ $(QT_LIBS)

# RUN WITH FLAGS
help:   msdscript ; ./$(EXECUTABLE_CLI) --help
test:   msdscript ; ./$(EXECUTABLE_CLI) --test
interp: msdscript ; ./$(EXECUTABLE_CLI) --interp
print:  msdscript ; ./$(EXECUTABLE_CLI) --print
pprint: msdscript ; ./$(EXECUTABLE_CLI) --pretty-print

# DOCS
doc:
	cd $(DOXY_OUTPUT) && doxygen $(DOXY_CONFIG) > /dev/null
pdf: doc
	cd $(DOXY_OUTPUT)/latex && make pdf > /dev/null && cp refman.pdf ../msdscript_man.pdf

open: doc
	cd $(DOXY_OUTPUT)/html && open index.html

# MISC
clean:
	@rm -rf $(DIR_BIN)/* 2>/dev/null || true
