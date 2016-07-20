//
//  VideoChatViewController.m
//  Agora iOS Tutorial Objective-C
//
//  Created by James Fang on 7/15/16.
//  Copyright © 2016 Agora.io. All rights reserved.
//

#import "VideoChatViewController.h"

@interface VideoChatViewController ()

@property (strong, nonatomic) AgoraRtcEngineKit *agoraKit;          // Tutorial Step 1
@property (weak, nonatomic) IBOutlet UIView *localVideo;            // Tutorial Step 3
@property (weak, nonatomic) IBOutlet UIView *remoteVideo;           // Tutorial Step 5
@property (weak, nonatomic) IBOutlet UIButton *videoMuteButton;     // Tutorial Step 9
@property (weak, nonatomic) IBOutlet UIImageView *remoteVideoMutedIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *localVideoMutedBg;
@property (weak, nonatomic) IBOutlet UIImageView *localVideoMutedIndicator;
@property (weak, nonatomic) IBOutlet UIButton *muteButton;          // Tutorial Step 8
@property (weak, nonatomic) IBOutlet UIButton *switchCameraButton;  // Tutorial Step 10
@property (weak, nonatomic) IBOutlet UIButton *hangUpButton;        // Tutorial Step 6

@end

@implementation VideoChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self hideButtons];             // Tutorial Step 7
    [self hideVideoMuted];          // Tutorial Step 9
    [self initializeAgoraEngine];   // Tutorial Step 1
    [self setupVideo];              // Tutorial Step 2
    [self setupLocalVideo];         // Tutorial Step 3
    [self joinChannel];             // Tutorial Step 4
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Tutorial Step 1
- (void)initializeAgoraEngine {
    self.agoraKit = [AgoraRtcEngineKit sharedEngineWithVendorKey:vendorKey delegate:self];
}

// Tutorial Step 2
- (void)setupVideo {
    [self.agoraKit enableVideo];
    // Default mode is disableVideo
    
    [self.agoraKit setVideoProfile:AgoraRtc_VideoProfile_360P_2];
    // Default video profile is 360P
}

// Tutorial Step 3
- (void)setupLocalVideo {
    AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
    videoCanvas.uid = 0;
    // UID = 0 means we let Agora pick a UID for us
    
    videoCanvas.view = self.localVideo;
    videoCanvas.renderMode = AgoraRtc_Render_Adaptive;
    [self.agoraKit setupLocalVideo:videoCanvas];
    // Bind local video stream to view
}

// Tutorial Step 4
- (void)joinChannel {
    [self.agoraKit joinChannelByKey:nil channelName:@"demoChannel1" info:nil uid:0 joinSuccess:^(NSString *channel, NSUInteger uid, NSInteger elapsed) {
        // Join channel "demoChannel1"
        [self showButtons];     // Tutorial Step 7
        [self.agoraKit setEnableSpeakerphone:YES];
        [UIApplication sharedApplication].idleTimerDisabled = YES;
    }];
    // The UID database is maintained by your app to track which users joined which channels. If not assigned (or set to 0), the SDK will allocate one and returns it in joinSuccessBlock callback. The App needs to record and maintain the returned value as the SDK does not maintain it.
}

// Tutorial Step 5
- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed {
    AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
    videoCanvas.uid = uid;
    // Since we are making a simple 1:1 video chat app, for simplicity sake, we are not storing the UIDs. You could use a mechanism such as an array to store the UIDs in a channel.
    
    videoCanvas.view = self.remoteVideo;
    videoCanvas.renderMode = AgoraRtc_Render_Adaptive;
    [self.agoraKit setupRemoteVideo:videoCanvas];
    // Bind remote video stream to view
}

// Tutorial Step 6
- (IBAction)hangUpButton:(UIButton *)sender {
    [self leaveChannel];
}

- (void)leaveChannel {
    [self.agoraKit leaveChannel:^(AgoraRtcStats *stat) {
        [self hideButtons];     // Tutorial Step 7
        [UIApplication sharedApplication].idleTimerDisabled = NO;
    }];
}

// Tutorial Step 7
- (void) showButtons {
    self.videoMuteButton.hidden = false;
    self.muteButton.hidden = false;
    self.switchCameraButton.hidden = false;
    self.hangUpButton.hidden = false;
}

- (void) hideButtons {
    self.videoMuteButton.hidden = true;
    self.muteButton.hidden = true;
    self.switchCameraButton.hidden = true;
    self.hangUpButton.hidden = true;
}

// Tutorial Step 8
- (IBAction)didClickMuteButton:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self.agoraKit muteLocalAudioStream:sender.selected];
}

// Tutorial Step 9
- (IBAction)didClickVideoMuteButton:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self.agoraKit muteLocalVideoStream:sender.selected];
    self.localVideo.hidden = sender.selected;
    self.localVideoMutedBg.hidden = !sender.selected;
    self.localVideoMutedIndicator.hidden = !sender.selected;
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didVideoMuted:(BOOL)muted byUid:(NSUInteger)uid {
    self.remoteVideo.hidden = muted;
    self.remoteVideoMutedIndicator.hidden = !muted;
}

- (void) hideVideoMuted {
    self.remoteVideoMutedIndicator.hidden = true;
    self.localVideoMutedBg.hidden = true;
    self.localVideoMutedIndicator.hidden = true;
}

// Tutorial Step 10
- (IBAction)didClickSwitchCameraButton:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self.agoraKit switchCamera];
}


@end


