SWIG = swig
# SWIG = ../../swig/swig -I../../swig/Lib -I../../swig/Lib/lua

all: Box2D_wrap.cxx CoreGraphics_wrap.m

Box2D_wrap.cxx: Box2D.i
	$(SWIG) -I../work/Box2D_v2.2.1 -c++ -lua -o $@ $^

CoreGraphics_wrap.m: CoreGraphics.i
	$(SWIG) -I/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS7.1.sdk/System/Library/Frameworks/CoreGraphics.framework/Headers/ -I/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform//Developer/SDKs/iPhoneOS7.1.sdk/usr/include/ -lua -o $@ $^

clean:
	rm -f *_wrap.* *~
