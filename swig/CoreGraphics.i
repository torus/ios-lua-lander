/* /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS6.1.sdk/System/Library/Frameworks/CoreGraphics.framework/Headers/
 */

%module cg

%{
#import <CoreGraphics/CoreGraphics.h>
#import "LuaBridge.h"

#define WRAP_TYPE_FUNC(srctype)                                         \
int srctype ## _to_NSValue (lua_State *L)                               \
{                                                                       \
  int SWIG_arg = 0;                                                     \
  struct srctype *arg1 = (struct srctype *) 0 ;                         \
                                                                        \
  if(!SWIG_isptrtype(L,1)) SWIG_fail_arg(#srctype "Wrap",1,"struct " #srctype " *"); \
                                                                        \
  if (!SWIG_IsOK(SWIG_ConvertPtr(L,1,(void**)&arg1,SWIGTYPE_p_ ## srctype,0))){ \
    SWIG_fail_ptr(#srctype "Wrap",1,SWIGTYPE_p_ ## srctype);            \
  }                                                                     \
                                                                        \
  {                                                                     \
      NSValue *val = [NSValue valueWith ## srctype:*arg1];              \
      luabridge_push_object(L, val); SWIG_arg ++;                       \
  }                                                                     \
  return SWIG_arg;                                                      \
                                                                        \
fail:                                                                   \
  lua_error(L);                                                         \
  return SWIG_arg;                                                      \
}

WRAP_TYPE_FUNC(CGAffineTransform)
WRAP_TYPE_FUNC(CGRect)

%}

%native(CGAffineTransformWrap) int CGAffineTransform_to_NSValue (lua_State *L);
%native(CGRectWrap) int CGRect_to_NSValue (lua_State *L);

/* %include <AvailabilityInternal.h> */
/* %include <Availability.h> */

/* cat *.h | perl -e '$/=undef;$b=<>;@a=$b=~/CG_EXTERN (?:const )?\w+ (\w+)[^\n]*\n[^\n]*__IPHONE_NA/mg;print join("\n",@a)'  */

%ignore CGColorCreateGenericGray;
%ignore CGColorCreateGenericRGB;
%ignore CGColorCreateGenericCMYK;
%ignore CGColorGetConstantColor;
%ignore kCGColorWhite;
%ignore kCGColorBlack;
%ignore kCGColorClear;
%ignore kCGColorSpaceGenericGray;
%ignore kCGColorSpaceGenericRGB;
%ignore kCGColorSpaceGenericCMYK;
%ignore kCGColorSpaceGenericRGBLinear;
%ignore kCGColorSpaceAdobeRGB1998;
%ignore kCGColorSpaceSRGB;
%ignore kCGColorSpaceGenericGrayGamma2_2;
%ignore CGColorSpaceCreateWithPlatformColorSpace;
%ignore CGColorSpaceCopyName;
%ignore CGColorSpaceCopyICCProfile;
%ignore CGContextDrawPDFDocument;
%ignore CGFontCreateWithPlatformFont;
%ignore kCGPDFContextOutputIntent;
%ignore kCGPDFXOutputIntentSubtype;
%ignore kCGPDFXOutputConditionIdentifier;
%ignore kCGPDFXOutputCondition;
%ignore kCGPDFXRegistryName;
%ignore kCGPDFXInfo;
%ignore kCGPDFXDestinationOutputProfile;
%ignore kCGPDFContextOutputIntents;
%ignore CGPDFDocumentGetMediaBox;
%ignore CGPDFDocumentGetCropBox;
%ignore CGPDFDocumentGetBleedBox;
%ignore CGPDFDocumentGetTrimBox;
%ignore CGPDFDocumentGetArtBox;
%ignore CGPDFDocumentGetRotationAngle;

#define CG_BUILDING_CG
%include <CGBase.h>
%include <CGAffineTransform.h>
%include <CGBitmapContext.h>
%include <CGColor.h>
%include <CGColorSpace.h>
%include <CGContext.h>
%include <CGDataConsumer.h>
%include <CGDataProvider.h>
%include <CGError.h>
%include <CGFont.h>
%include <CGFunction.h>
%include <CGGeometry.h>
%include <CGGradient.h>
%include <CGImage.h>
%include <CGLayer.h>
%include <CGPDFArray.h>
%include <CGPDFContentStream.h>
%include <CGPDFContext.h>
%include <CGPDFDictionary.h>
%include <CGPDFDocument.h>
%include <CGPDFObject.h>
%include <CGPDFOperatorTable.h>
%include <CGPDFPage.h>
%include <CGPDFScanner.h>
%include <CGPDFStream.h>
%include <CGPDFString.h>
%include <CGPath.h>
%include <CGPattern.h>
%include <CGShading.h>
