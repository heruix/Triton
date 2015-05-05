# Path to the pin kit directory
PIN_ROOT =	../../..

ifndef SYSCALL_HEADER
  SYSCALL_HEADER = /usr/include/asm/unistd_64.h
endif

NAME = 		triton

CXX =		g++

INCLUDES =	-I$(PIN_ROOT)/source/include/pin \
		-I$(PIN_ROOT)/source/include/pin/gen \
		-I$(PIN_ROOT)/extras/components/include \
		-I$(PIN_ROOT)/extras/xed-intel64/include \
		-I$(PIN_ROOT)/source/tools/InstLib \
		-I./src/includes

CXXFLAGS = 	$(INCLUDES) -DBIGARRAY_MULTIPLIER=1 -DUSING_XED -Wall -Werror -Wno-unknown-pragmas \
		-fno-stack-protector -DTARGET_IA32E -DHOST_IA32E -fPIC -DTARGET_LINUX  \
		-O3 -fomit-frame-pointer -fno-strict-aliasing -std=c++11

ifdef DEBUG
  CXXFLAGS += -g
endif

LIBS =		-L$(PIN_ROOT)/intel64/lib \
		-L$(PIN_ROOT)/intel64/lib-ext \
		-L$(PIN_ROOT)/intel64/runtime/glibc \
		-L$(PIN_ROOT)/extras/xed-intel64/lib \
		-lpin \
		-lxed \
		-lpindwarf \
		-ldl \
		-lz3 \
		-lpython2.7

SRC =           ./src/analysisProcessor/analysisProcessor.cpp \
		./src/bindings/python/init.cpp \
		./src/bindings/python/initCallbackEnv.cpp \
		./src/bindings/python/initFlagEnv.cpp \
		./src/bindings/python/initLinux64Env.cpp \
		./src/bindings/python/initOpcodeCategoryEnv.cpp \
		./src/bindings/python/initOpcodeEnv.cpp \
		./src/bindings/python/initOperandEnv.cpp \
		./src/bindings/python/initRegEnv.cpp \
		./src/bindings/python/initSyscallEnv.cpp \
		./src/bindings/python/processingPyConf.cpp \
		./src/bindings/python/smt2libCallbacks.cpp \
		./src/bindings/python/tritonCallbacks.cpp \
		./src/bindings/python/tritonPyObject.cpp \
		./src/bindings/python/xPyFunc.cpp \
		./src/components/Inst.cpp \
		./src/components/Stats.cpp \
		./src/components/Trace.cpp \
		./src/contextHandler/PINContextHandler.cpp \
		./src/contextHandler/PINConverter.cpp \
		./src/core/main.cpp \
		./src/ir/IRBuilderFactory.cpp \
		./src/ir/builders/AdcIRBuilder.cpp \
		./src/ir/builders/AddIRBuilder.cpp \
		./src/ir/builders/AndIRBuilder.cpp \
		./src/ir/builders/BaseIRBuilder.cpp \
		./src/ir/builders/CallIRBuilder.cpp \
		./src/ir/builders/ClcIRBuilder.cpp \
		./src/ir/builders/CldIRBuilder.cpp \
		./src/ir/builders/CmcIRBuilder.cpp \
		./src/ir/builders/CmpIRBuilder.cpp \
		./src/ir/builders/ControlFlow.cpp \
		./src/ir/builders/DecIRBuilder.cpp \
		./src/ir/builders/EflagsBuilder.cpp \
		./src/ir/builders/IncIRBuilder.cpp \
		./src/ir/builders/JbIRBuilder.cpp \
		./src/ir/builders/JnsIRBuilder.cpp \
		./src/ir/builders/JnzIRBuilder.cpp \
		./src/ir/builders/JsIRBuilder.cpp \
		./src/ir/builders/JzIRBuilder.cpp \
		./src/ir/builders/LeaveIRBuilder.cpp \
		./src/ir/builders/MovIRBuilder.cpp \
		./src/ir/builders/MovsxIRBuilder.cpp \
		./src/ir/builders/MovzxIRBuilder.cpp \
		./src/ir/builders/NotIRBuilder.cpp \
		./src/ir/builders/OrIRBuilder.cpp \
		./src/ir/builders/PopIRBuilder.cpp \
		./src/ir/builders/PushIRBuilder.cpp \
		./src/ir/builders/RetIRBuilder.cpp \
		./src/ir/builders/SbbIRBuilder.cpp \
		./src/ir/builders/StcIRBuilder.cpp \
		./src/ir/builders/StdIRBuilder.cpp \
		./src/ir/builders/SubIRBuilder.cpp \
		./src/ir/builders/TestIRBuilder.cpp \
		./src/ir/builders/XorIRBuilder.cpp \
		./src/ir/templates/NoneOperandTemplate.cpp \
		./src/ir/templates/OneOperandTemplate.cpp \
		./src/ir/templates/OperandTemplate.cpp \
		./src/ir/templates/TwoOperandsTemplate.cpp \
		./src/snapshotEngine/snapshotEngine.cpp \
		./src/solverEngine/smt2lib.cpp \
		./src/solverEngine/solverEngine.cpp \
		./src/symbolicEngine/symbolicElement.cpp \
		./src/symbolicEngine/symbolicEngine.cpp \
		./src/taintEngine/taintEngine.cpp \
		./src/trigger/trigger.cpp \
		./src/utils/syscallNumberToString.cpp \
		./src/utils/syscalls.cpp


OBJ = $(SRC:.cpp=.o)


# Rules
all: $(NAME)

$(NAME): $(OBJ)
	$(CXX) -shared -Wl,--hash-style=sysv -Wl,-Bsymbolic -Wl,--version-script=$(PIN_ROOT)/source/include/pin/pintool.ver -o $(NAME).so $(OBJ) $(LIBS)

./src/utils/syscalls.cpp: ./scripts/extract_syscall.py
	$< $(SYSCALL_HEADER) >$@ || rm $@

clean:
	 /bin/rm -f $(OBJ) ./src/utils/syscalls.cpp

cleanall: clean
	 /bin/rm -f $(NAME).so

re: cleanall all

.PHONY: re clean cleanall all

