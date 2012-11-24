QMAKE_TARGET  = sample
QMAKE         = $(QNX_HOST)/usr/bin/qmake
TARGET        = $(QMAKE_TARGET)
GHC_X86       = ghc
GHC_ARM       = echo


all: Makefile $(QMAKE_TARGET)

clean:
	$(MAKE) -C ./arm -f Makefile sureclean
	$(MAKE) -C ./x86 -f Makefile sureclean
	$(RM) ./x86/o/.obj/*
	$(RM) ./x86/o-g/.obj/*
	$(RM) ./x86/o.le-v7/.obj/*
	$(RM) ./x86/o.le-v7-g/.obj/*

Makefile: FORCE
	$(QMAKE) -spec unsupported/blackberry-armv7le-qcc -o arm/Makefile $(QMAKE_TARGET).pro CONFIG+=device
	$(QMAKE) -spec unsupported/blackberry-x86-qcc -o x86/Makefile $(QMAKE_TARGET).pro CONFIG+=simulator
	$(MAKE) -C ./translations -f Makefile update release

FORCE:

$(QMAKE_TARGET): device simulator

device:
	$(MAKE) -C ./arm -f Makefile all
	$(GHC_ARM) --make -threaded -o ./arm/o.le-v7-g/Main -outputdir ./arm/o.le-v7-g/.obj/ src/Main.hs -optl-Wl,-rpath-link="$(QNX_TARGET)/armle-v7/usr/lib/qt4/lib" -L./arm/o.le-v7-g/ -l$(QMAKE_TARGET)
	$(GHC_ARM) --make -threaded -o ./arm/o.le-v7/Main -outputdir ./arm/o.le-v7/.obj/ src/Main.hs -optl-Wl,-rpath-link="$(QNX_TARGET)/armle-v7/usr/lib/qt4/lib" -L./arm/o.le-v7/ -l$(QMAKE_TARGET)

Device-Debug: Makefile
	$(MAKE) -C ./arm -f Makefile debug
	$(GHC_ARM) --make -threaded -o ./arm/o.le-v7-g/Main -outputdir ./arm/o.le-v7-g/.obj/ src/Main.hs -optl-Wl,-rpath-link="$(QNX_TARGET)/armle-v7/usr/lib/qt4/lib" -L./arm/o.le-v7-g/ -l$(QMAKE_TARGET)

Device-Release: Makefile
	$(MAKE) -C ./arm -f Makefile release
	$(GHC_ARM) --make -threaded -o ./arm/o.le-v7/Main -ouputdir ./arm/o.le-v7/ src/Main.hs -optl-Wl,-rpath-link="$(QNX_TARGET)/armle-v7/usr/lib/qt4/lib" -L./arm/o.le-v7/ -l$(QMAKE_TARGET)

simulator:
	$(MAKE) -C ./x86 -f Makefile all
	$(GHC_X86) --make -threaded -o ./x86/o/Main -outputdir ./x86/o/.obj/ src/Main.hs -optl-Wl,-rpath-link="$(QNX_TARGET)/x86/usr/lib/qt4/lib" -L./x86/o/ -l$(QMAKE_TARGET)
	$(GHC_X86) --make -threaded -o ./x86/o-g/Main -outputdir ./x86/o-g/.obj/ src/Main.hs -optl-Wl,-rpath-link="$(QNX_TARGET)/x86/usr/lib/qt4/lib" -L./x86/o-g/ -l$(QMAKE_TARGET)

Simulator-Debug: Makefile
	$(MAKE) -C ./x86 -f Makefile debug
	$(GHC_X86) --make -threaded -o ./x86/o-g/Main -outputdir ./x86/o-g/.obj/ src/Main.hs -optl-Wl,-rpath-link="$(QNX_TARGET)/x86/usr/lib/qt4/lib" -L./x86/o-g/ -l$(QMAKE_TARGET)
