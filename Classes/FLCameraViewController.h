//
//	FLImagePickerController.h
//	FishLamp
//
//	Created by Mike Fullerton on 9/18/10.
//	Copyright (c) 2013 GreenTongue Software LLC, Mike Fullerton. 
//  The FishLamp Framework is released under the MIT License: http://fishlamp.com/license 
//

#import <Foundation/Foundation.h>
#import "FLCameraOverlayView.h"
#import "FLViewController.h"
#import "FLJpegFileImageAsset.h"
#import "FLStillCamera.h"
#import "FLViewController.h"
#import "FLCameraPhotoViewController.h"
#import "FLJpegFileImageAsset.h"
#import "FLVideoFrameGrabberCamera.h"

#import "FLCameraController.h"

#import "FLStillCameraController.h"
#import "FLFramesCameraController.h"
#import "FLPhotoViewControllerStrategy.h"
#import "FLCameraConfig.h"

#if FL_CUSTOM_CAMERA

typedef void (^FLCameraViewControllerDidTakePhotoBlock)(FLCameraPhoto* image);

typedef enum { 
	FLCameraViewControllerCameraTypeStill,
	FLCameraViewControllerCameraTypeFrames
} FLCameraViewControllerCameraType;

@class FLCameraPhoto;

@interface FLCameraViewController : FLViewController<
	UIAccelerometerDelegate> {
@private
	
	IBOutlet FLCameraOverlayView* _overlay;
	UIAccelerationValue _lastX;
	UIAccelerationValue _lastY;
	UIAccelerationValue _lastZ;
	
	FLFolder* _folder;
	
	FLCameraConfig* _cameraConfig;
		 
	FLPhotoViewControllerStrategy* _cameraViewStrategy;
	
	FLCameraViewControllerDidTakePhotoBlock _tookPhotoBlock;
	
	CLLocationManager* _locationManager;
		
	struct {
		FLCameraViewControllerCameraType cameraType:2;
	} _cameraControllerFlags;
}

- (id) initWithPhotoFolder:(FLFolder*) folder
	 cameraType:(FLCameraViewControllerCameraType) cameraType
	 cameraConfig:(FLCameraConfig*) cameraConfig;

@property (readonly, retain, nonatomic) FLCameraConfig* cameraConfig;

@property (readwrite, retain) FLCameraViewControllerDidTakePhotoBlock tookPhotoBlock;
@property (readwrite, retain, nonatomic) FLFolder* folder;

@property (readonly, nonatomic, retain) NSMutableArray* photos;

@property (readonly, nonatomic, retain) CLLocationManager* locationManager;

- (void) startLocationManager;

- (void) setCameraType:(FLCameraViewControllerCameraType) cameraType
			  position:(AVCaptureDevicePosition) position
			 flashMode:(AVCaptureFlashMode) flash;
@end

@interface FLCameraViewController (Internal)

@property (readonly, assign, retain) FLCameraOverlayView* overlayView;


@end


#endif
