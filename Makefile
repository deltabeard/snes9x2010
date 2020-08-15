DEBUG := 0
GIT_VERSION := " $(shell git rev-parse --short HEAD)"
CFLAGS :=
LDLIBS :=

TARGET_NAME := snes9x2010

# Function substitutes variables depending on the value set in $(CC)
ccparam = $(if $(subst cl,,$(CC)),$(1),$(2))

ifeq ($(OS)$(MSYSTEM),Windows_NT)
	SHELL := cmd
	NULL := nul
	RM := del
	CC := cl
	OBJEXT := obj
	OUTEXT := dll
	CFLAGS += /nologo /W1 /DWINVER=0x0400 /D_WIN32_WINNT=0x0400 /DWIN32 /DCORRECT_VRAM_READS /D_WINDOWS /D_USRDLL /D_CRT_SECURE_NO_WARNINGS /DMSVC2010_EXPORTS
	INLINE := __inline
else
	SHELL := sh
	NULL := /dev/null
	CC := cc
	OBJEXT := o
	OUTEXT := so
	CFLAGS += -shared -fPIC -Wl,--version-script=libretro/link.T -Wall -Wextra
	LDLIBS += -lm
	INLINE := inline
endif

ifneq ($(DEBUG),0)
	CFLAGS += $(call ccparam,-Og -g3,/Zi /Od)
else
	CFLAGS += $(call ccparam,-O2 -ffast-math -g1,/O2 /GL)
endif

TARGET := $(TARGET_NAME)_libretro.$(OUTEXT)

LIBRETRO_COMM_DIR := libretro/libretro-common
INCFLAGS := -Ilibretro -Isrc -I$(LIBRETRO_COMM_DIR)/include
CFLAGS += -DLAGFIX -DHAVE_STRINGS_H -DHAVE_INTTYPES_H -D__LIBRETRO__ \
	-DRIGHTSHIFT_IS_SAR /DFRONTEND_SUPPORTS_RGB565 -DINLINE=$(INLINE) $(INCFLAGS)

SRCS	:= $(wildcard $(CORE_DIR)src/*.c) $(LIBRETRO_COMM_DIR)/streams/memory_stream.c libretro/libretro.c

OBJECTS := $(SRCS:.c=.$(OBJEXT))

all: $(TARGET)
$(TARGET_NAME)_libretro.dll: $(OBJECTS)
	$(CC) $(CFLAGS) $(CPPFLAGS) /LD $^ /link /DLL /OUT:$@

$(TARGET_NAME)_libretro.so: $(OBJECTS)
	$(CC) $(CFLAGS) $(CPPFLAGS) -o$@ $^ $(LDLIBS)

%.obj: %.c
	$(CC) $(CFLAGS) $(CPPFLAGS) /Fo$@ /c /TC $^

clean:
	$(RM) $(OBJECTS) $(TARGET)
