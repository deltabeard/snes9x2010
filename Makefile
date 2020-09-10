DEBUG := 0
CC := cc
CFLAGS = -shared -fPIC -Wl,--version-script=libretro/link.T -Wall
LDLIBS = -lm
OBJEXT := o
OUTEXT := so
INLINE := inline
GIT_VERSION = " $(shell git rev-parse --short HEAD)"
LDFLAGS :=

TARGET_NAME := snes9x2010

# Function substitutes variables depending on the value set in $(CC)
ccparam = $(if $(subst cl,,$(CC)),$(1),$(2))

ifneq ($(DEBUG),0)
	CFLAGS += $(call ccparam,-Og -g3 -Wextra,/Zi /Od /W3)
else
	CFLAGS += $(call ccparam,-O2 -ffast-math -g1,/O2 /GL /W1)
endif

TARGET := $(TARGET_NAME)_libretro.$(OUTEXT)

LIBRETRO_COMM_DIR := libretro/libretro-common
INCFLAGS := -Ilibretro -Isrc -I$(LIBRETRO_COMM_DIR)/include
override CFLAGS += -DLAGFIX -DHAVE_STRINGS_H -DHAVE_INTTYPES_H -D__LIBRETRO__ \
	-DRIGHTSHIFT_IS_SAR -DFRONTEND_SUPPORTS_RGB565 -DINLINE=$(INLINE) $(INCFLAGS)

SRCS	:= $(wildcard $(CORE_DIR)src/*.c) $(LIBRETRO_COMM_DIR)/streams/memory_stream.c libretro/libretro.c
OBJECTS := $(SRCS:.c=.$(OBJEXT))

all: $(TARGET)

$(TARGET_NAME)_libretro.so: $(OBJECTS)
	$(CC) $(CFLAGS) $(CPPFLAGS) -o$@ $^ $(LDFLAGS) $(LDLIBS)
	
$(TARGET_NAME)_libretro.dll: $(OBJECTS)
	$(CC) $(CFLAGS) $(CPPFLAGS) /LD /Fe$@ $^ /link $(LDFLAGS)

%.obj: %.c
	$(CC) $(CFLAGS) $(CPPFLAGS) /Fo$@ /c /TC $^

clean:
	$(RM) $(OBJECTS) $(TARGET)
