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


/* UIGraphics.h */
#define UIKIT_EXTERN
#define NS_AVAILABLE_IOS(x)

UIKIT_EXTERN CGContextRef UIGraphicsGetCurrentContext(void);
/* UIKIT_EXTERN void UIGraphicsPushContext(CGContextRef context); */
/* UIKIT_EXTERN void UIGraphicsPopContext(void); */

/* UIKIT_EXTERN void UIRectFillUsingBlendMode(CGRect rect, CGBlendMode blendMode); */
/* UIKIT_EXTERN void UIRectFill(CGRect rect); */

/* UIKIT_EXTERN void UIRectFrameUsingBlendMode(CGRect rect, CGBlendMode blendMode); */
/* UIKIT_EXTERN void UIRectFrame(CGRect rect); */

/* UIKIT_EXTERN void UIRectClip(CGRect rect); */

/* // UIImage context */

/* UIKIT_EXTERN void     UIGraphicsBeginImageContext(CGSize size); */
/* UIKIT_EXTERN void     UIGraphicsBeginImageContextWithOptions(CGSize size, BOOL opaque, CGFloat scale) NS_AVAILABLE_IOS(4_0); */
/* UIKIT_EXTERN UIImage* UIGraphicsGetImageFromCurrentImageContext(void); */
/* UIKIT_EXTERN void     UIGraphicsEndImageContext(void);  */

/* // PDF context */

/* UIKIT_EXTERN BOOL UIGraphicsBeginPDFContextToFile(NSString *path, CGRect bounds, NSDictionary *documentInfo) NS_AVAILABLE_IOS(3_2); */
/* UIKIT_EXTERN void UIGraphicsBeginPDFContextToData(NSMutableData *data, CGRect bounds, NSDictionary *documentInfo) NS_AVAILABLE_IOS(3_2); */
/* UIKIT_EXTERN void UIGraphicsEndPDFContext(void) NS_AVAILABLE_IOS(3_2); */

/* UIKIT_EXTERN void UIGraphicsBeginPDFPage(void) NS_AVAILABLE_IOS(3_2); */
/* UIKIT_EXTERN void UIGraphicsBeginPDFPageWithInfo(CGRect bounds, NSDictionary *pageInfo) NS_AVAILABLE_IOS(3_2); */

/* UIKIT_EXTERN CGRect UIGraphicsGetPDFContextBounds(void) NS_AVAILABLE_IOS(3_2); */

/* UIKIT_EXTERN void UIGraphicsSetPDFContextURLForRect(NSURL *url, CGRect rect) NS_AVAILABLE_IOS(3_2); */
/* UIKIT_EXTERN void UIGraphicsAddPDFContextDestinationAtPoint(NSString *name, CGPoint point) NS_AVAILABLE_IOS(3_2); */
/* UIKIT_EXTERN void UIGraphicsSetPDFContextDestinationForRect(NSString *name, CGRect rect) NS_AVAILABLE_IOS(3_2); */
