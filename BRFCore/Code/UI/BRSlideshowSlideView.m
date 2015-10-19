//
//  BRSlideshowSlideView.m
//  BRFCore
//
//  Created by Matt on 19/10/15.
//  Copyright © 2015 Blue Rocket, Inc. Distributable under the terms of the Apache License, Version 2.0.
//

#import "BRSlideshowSlideView.h"

#import <BRScroller/BRScroller.h>

@interface BRSlideshowZoomingImageSlideView : BRCenteringScrollView

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation BRSlideshowSlideView {
	UIImageView *imageView;
	BRCachedPreviewPdfPageZoomView *pdfZoomer;
	BRSlideshowZoomingImageSlideView *imageZoomer;
	CGPDFDocumentRef pdf;
}

- (void)dealloc {
	CGPDFDocumentRelease(pdf);
}

- (UIImageView *)imageView {
	UIImageView *view = imageView;
	if ( !imageView ) {
		view = [[UIImageView alloc] initWithFrame:self.bounds];
		view.contentMode = UIViewContentModeScaleAspectFill;
		[self addSubview:view];
		imageView = view;
	}
	return view;
}

- (BRSlideshowZoomingImageSlideView *)imageZoomer {
	BRSlideshowZoomingImageSlideView *view = imageZoomer;
	if ( !view ) {
		view = [[BRSlideshowZoomingImageSlideView alloc] initWithFrame:self.bounds];
		[self addSubview:view];
		imageZoomer = view;
	}
	return view;
}

- (BRCachedPreviewPdfPageZoomView *)pdfZoomer {
	BRCachedPreviewPdfPageZoomView *view = pdfZoomer;
	if ( !view ) {
		view = [[BRCachedPreviewPdfPageZoomView alloc] initWithFrame:self.bounds];
		view.pdfView.previewService = [BRDefaultImageRenderService new];
		view.doubleTapToZoom = YES;
		[self addSubview:view];
		pdfZoomer = view;
	}
	return view;
}

- (void)openPdf:(NSString *)pdfPath {
	if ( pdf != NULL && CGPDFDocumentIsUnlocked(pdf) ) {
		return;
	}
	if ( pdf == NULL ) {
		if ( pdfPath != nil ) {
			CFURLRef url = CFURLCreateWithFileSystemPath(NULL, (CFStringRef)pdfPath, kCFURLPOSIXPathStyle, 0);
			if ( url != NULL ) {
				pdf = CGPDFDocumentCreateWithURL(url);
				CFRelease(url);
			}
		} else {
			// neither path nor dataProvider available
			return;
		}
	}
}

- (void)closePdf {
	CGPDFDocumentRelease(pdf);
	pdf = NULL;
}

- (void)showImageResource:(NSString *)imagePath withZoom:(BOOL)allowZoom {
	NSString *extension = [[imagePath pathExtension] lowercaseString];
	if ( [extension isEqualToString:@"png"] || [extension isEqualToString:@"jpg"] ) {
		UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
		if ( allowZoom ) {
			UIImageView *view = [self imageZoomer].imageView;
			if ( !view ) {
				view = [[UIImageView alloc] initWithImage:image];
				[self imageZoomer].imageView = view;
			} else {
				view.image = image;
			}
		} else {
			[self imageView].image = image;
		}
		pdfZoomer.hidden = YES;
		imageView.hidden = allowZoom;
		imageZoomer.hidden = !allowZoom;
	} else if ( [extension isEqualToString:@"pdf"] ) {
		BRCachedPreviewPdfPageZoomView *zoomer = [self pdfZoomer];
		[self openPdf:imagePath];
		CGPDFPageRef page = CGPDFDocumentGetPage(pdf, 1);
		[zoomer setPage:page forIndex:0 withKey:[[[imagePath lastPathComponent] stringByDeletingPathExtension] stringByAppendingPathExtension:@"png"]];
		pdfZoomer.hidden = NO;
		imageView.hidden = YES;
		imageZoomer.hidden = YES;
	}
}

- (void)layoutSubviews {
	imageView.frame = self.bounds;
	pdfZoomer.frame = self.bounds;
	imageZoomer.frame = self.bounds;
	[super layoutSubviews];
}

@end

@implementation BRSlideshowZoomingImageSlideView {
	UIImageView *imageView;
}

@synthesize imageView;

- (void)setImageView:(UIImageView *)view {
	if ( view != imageView ) {
		[imageView removeFromSuperview];
		imageView = view;
		if ( view ) {
			[self addSubview:view];
		}
	}
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return imageView;
}

@end
