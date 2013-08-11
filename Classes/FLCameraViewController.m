//
//	FLImagePickerController.m
//	FishLamp
//
//	Created by Mike Fullerton on 9/18/10.
//	Copyright (c) 2013 GreenTongue Software LLC, Mike Fullerton. 
//  The FishLamp Framework is released under the MIT License: http://fishlamp.com/license 
//

#import "FLCameraViewController.h"
#import "FLCameraOverlayView.h"
#import "FLGpsUtilities.h"
#import "NSFileManager+FLExtras.h"

#if FL_CUSTOM_CAMERA

@implementation FLCameraViewController

@synthesize tookPhotoBlock = _tookPhotoBlock;

@synthesize folder = _folder;
@synthesize locationManager = _locationManager;
@synthesize cameraConfig = _cameraConfig;

@synthesize photos = _photos;

- (id) initWithPhotoFolder:(FLFolder*) folder 
			cameraType:(FLCameraViewControllerCameraType) cameraType
			cameraConfig:(FLCameraConfig*) cameraConfig
{
	if(self = [super initWithNibName:@"FLCamera" bundle:nil])
	{	
		self.cameraConfig = cameraConfig;
		self.folder = folder;
		self.title = @"Camera";
		
		_cameraControllerFlags.cameraType = cameraType;
		
		switch(cameraType)
		{
			case FLCameraViewControllerCameraTypeStill:
				_cameraViewStrategy = [[FLPhotoViewControllerStillStrategy alloc] initWithViewController:self];
			break;
			
			case FLCameraViewControllerCameraTypeFrames:
				_cameraViewStrategy = [[FLPhotoViewControllerVideoFrameStrategy alloc] initWithViewController:self];
			break;
		}
		 
		_photos = [[NSMutableArray alloc] init];
	
		self.wantsFullScreenLayout = YES;

		[UIAccelerometer sharedAccelerometer].updateInterval = 0.25;
		[UIAccelerometer sharedAccelerometer].delegate = self;
		
		[self startLocationManager];
	}
	
	return self;
}

- (void) setCameraType:(FLCameraViewControllerCameraType) cameraType
			  position:(AVCaptureDevicePosition) position
			 flashMode:(AVCaptureFlashMode) flash
{
	switch(cameraType)
	{
		case FLCameraViewControllerCameraTypeStill:
			_cameraViewStrategy = [[FLPhotoViewControllerStillStrategy alloc] initWithViewController:self];
			break;
			
		case FLCameraViewControllerCameraTypeFrames:
			_cameraViewStrategy = [[FLPhotoViewControllerVideoFrameStrategy alloc] initWithViewController:self];
			break;
	}
}

- (FLCameraPhoto*) photo
{
	return [_photos lastObject];
}

- (void) _cleanupCameraController
{
	FLReleaseWithNil(_overlay);
}

- (void) startLocationManager
{
	if(OSVersionIsAtLeast4_1() && [CLLocationManager locationServicesEnabled])
	{	
		FLRelease(_locationManager);
		_locationManager =[[CLLocationManager alloc] init];
		//		 _locationManager.delegate=self;
		_locationManager.desiredAccuracy=kCLLocationAccuracyBest;
		_locationManager.purpose = @"GPS latitude and longitude will be stored in your photos.";
		[_locationManager startUpdatingLocation];
	}
}

- (void) dealloc
{
	_locationManager.delegate = nil;
	[_locationManager stopUpdatingLocation];
	FLRelease(_locationManager);
	
	FLRelease(_cameraViewStrategy);
	FLRelease(_tookPhotoBlock);
	FLRelease(_photos);
	FLRelease(_folder);
	FLRelease(_cameraConfig);
	[self _cleanupCameraController];
	
	FLSuperDealloc();
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[UIAccelerometer sharedAccelerometer].delegate = self;
	
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
	if(self.navigationController)
	{
		[self.navigationController setNavigationBarHidden:YES animated:YES];
	}
	
	[_cameraViewStrategy viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[UIAccelerometer sharedAccelerometer].delegate = nil;
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
	if(self.navigationController)
	{
		[self.navigationController setNavigationBarHidden:NO animated:YES];
	}
	
	[_cameraViewStrategy viewWillDisappear:animated];
}

double MoveDelta(double lhs, double rhs)
{
	return fabsf(lhs - rhs);
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)aceler
{
	[_overlay setShakyIconVisible:MoveDelta(aceler.x, _lastX) > 0.05 || MoveDelta(aceler.y, _lastY) > 0.05 || MoveDelta(aceler.z, _lastZ) > 0.05];

	_lastX = aceler.x;
	_lastY = aceler.y;
	_lastZ = aceler.z;
}

- (void) viewDidLoad
{
	[super viewDidLoad];
	_overlay = [[FLCameraOverlayView alloc] initWithFrame:self.view.bounds];
	[self.view addSubview:_overlay];
	[_cameraViewStrategy viewDidLoad];
}

- (void) viewDidUnload
{
	[super viewDidUnload];
	[self _cleanupCameraController];
	[_cameraViewStrategy viewDidUnload];
}

@end

@implementation FLCameraViewController (Internal)

- (FLCameraOverlayView*) overlayView
{
	return _overlay;
}
@end
	
#endif