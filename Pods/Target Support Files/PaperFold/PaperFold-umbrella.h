#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "FacingView.h"
#import "FoldView.h"
#import "MultiFoldView.h"
#import "PaperFoldConstants.h"
#import "PaperFoldNavigationController.h"
#import "PaperFoldSwipeHintView.h"
#import "PaperFoldView.h"
#import "ShadowView.h"
#import "TouchThroughUIView.h"
#import "UIView+Screenshot.h"

FOUNDATION_EXPORT double PaperFoldVersionNumber;
FOUNDATION_EXPORT const unsigned char PaperFoldVersionString[];

