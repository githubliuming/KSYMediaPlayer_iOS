//
//  KSYProberVC.m
//  KSYPlayerDemo
//
//  Created by 施雪梅 on 16/7/10.
//  Copyright © 2016年 kingsoft. All rights reserved.
//
#import "KSYUIView.h"
#import "KSYProberVC.h"

#define ELEMENT_GAP  10

@implementation KSYProberVC {
    KSYUIView *ctrlView;
    UILabel *stat;
    UIButton *btnProbe;
    UIButton *btnThumbnail;
    UIButton *btnQuit;
    
    NSURL *_url;
    KSYMediaInfoProber *_prober;
}

- (instancetype)initWithURL:(NSURL *)url {
    if((self = [super init])) {
        _url = url;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
    stat.text = [NSString stringWithFormat:@"url is : %@", [_url isFileURL] ? [_url path] : [_url absoluteString]];
    _prober = [[KSYMediaInfoProber alloc] initWithContentURL: _url];
    _prober.timeout = 10;
}

- (void)setupUI {
    ctrlView = [[KSYUIView alloc] initWithFrame:self.view.bounds];
    ctrlView.backgroundColor = [UIColor whiteColor];
    ctrlView.gap = ELEMENT_GAP;
    
    @WeakObj(self);
    ctrlView.onBtnBlock = ^(id sender){
        [selfWeak  onBtn:sender];
    };
    
    btnProbe = [ctrlView addButton:@"探测格式"];
    btnThumbnail = [ctrlView addButton:@"缩略图"];
    btnQuit = [ctrlView addButton:@"退出"];

    stat = [ctrlView addLable:nil];
    stat.backgroundColor = [UIColor clearColor];
    stat.textColor = [UIColor redColor];
    stat.numberOfLines = -1;
    stat.textAlignment = NSTextAlignmentLeft;
    
    [self layoutUI];
    
    [self.view addSubview: ctrlView];
}

- (void)layoutUI {
    ctrlView.frame = self.view.frame;
    [ctrlView layoutUI];
    
    ctrlView.yPos  = ctrlView.frame.size.height -  ctrlView.btnH - ELEMENT_GAP;
    [ctrlView putRow:@[btnProbe, btnThumbnail, btnQuit]];

    stat.frame = ctrlView.frame;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.returnKeyType == UIReturnKeyDone) {
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)onBtn:(UIButton *)btn{
    if (btn == btnProbe) {
        [self onProbeMediaInfo];
    }else if (btn == btnThumbnail){
        [self onThumbnail];
    }else if (btn == btnQuit){
        [self onQuit];
    }
}

- (void)onProbeMediaInfo {

    if(nil == _prober)
        return ;
    
    NSMutableString *result = [[NSMutableString alloc] init];
    int i = 0;
    
    KSYMediaInfo *mediaInfo = _prober.ksyMediaInfo;
    if(mediaInfo)
    {
        [result appendFormat:@"\nmux type:%@", [self convertMuxType:mediaInfo.type]];
        [result appendFormat:@"\nbitrate:%lld", mediaInfo.bitrate];
        
        i = 0;
        [result appendFormat:@"\n\nvideo num is : %lu", (unsigned long)[mediaInfo.videos count]];
        for (KSYVideoInfo  *videoInfo in mediaInfo.videos) {
            [result appendFormat:@"\n\nvideo[%d] codec:%@", i, [self convertAVCodec:videoInfo.vcodec]];
            [result appendFormat:@"\nvideo[%d] frame width:%d", i, videoInfo.frame_width];
            [result appendFormat:@"\nvideo[%d] frame height:%d", i, videoInfo.frame_height];
            i++;
        }
        
        i = 0;
        [result appendFormat:@"\n\naudio num is : %lu", (unsigned long)[mediaInfo.audios count]];
        for(KSYAudioInfo  *audioInfo in mediaInfo.audios)
        {
            [result appendFormat:@"\n\naudio[%d] codec:%@", i, [self convertAVCodec:audioInfo.acodec]];
            [result appendFormat:@"\naudio[%d] language:%@", i, audioInfo.language];
            [result appendFormat:@"\naudio[%d] bitrate:%lld", i, audioInfo.bitrate];
            [result appendFormat:@"\naudio[%d] channels:%d", i, audioInfo.channels];
            [result appendFormat:@"\naudio[%d] frame_size:%d", i, audioInfo.framesize];
            [result appendFormat:@"\naudio[%d] sample_format:%@", i, [self convertSampleFMT:audioInfo.sample_format]];
            [result appendFormat:@"\naudio[%d] samplerate:%d", i, audioInfo.samplerate];
            i++;
        }
    }
    else
        [result appendFormat:@"\nprobe mediainfo failed!"];
    
    stat.text = [NSString stringWithFormat:@"%@", result];
}

- (void)onThumbnail{
    
    if(nil == _prober)
        return ;
    
    UIImage *thumbnailImage = [_prober getVideoThumbnailImageAtTime:0 width:0 height:0];
    if(thumbnailImage)
        [KSYUIVC saveImageToPhotosAlbum:thumbnailImage];
    else
    {
        UIAlertView *toast = [[UIAlertView alloc] initWithTitle:@"￣へ￣"
                                                        message:@"缩略图截取失败！"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        [toast show];
    }
}

- (void)onQuit {
    [self dismissViewControllerAnimated:FALSE completion:nil];
}

#pragma mark converMediaInfo

- (NSString *)convertMuxType:(MEDIAINFO_MUX_TYPE)muxType
{
    NSString *muxTypeStr = @"unknow mux type";

    if(MEDIAINFO_MUXTYPE_MP2T == muxType)
        muxTypeStr = @"mpeg-ts";
    else if(MEDIAINFO_MUXTYPE_MOV == muxType)
        muxTypeStr = @"mov";
    else if(MEDIAINFO_MUXTYPE_AVI == muxType)
        muxTypeStr = @"avi";
    else if(MEDIAINFO_MUXTYPE_FLV == muxType)
        muxTypeStr = @"flv";
    else if(MEDIAINFO_MUXTYPE_MKV == muxType)
        muxTypeStr = @"mkv";
    else if(MEDIAINFO_MUXTYPE_ASF == muxType)
        muxTypeStr = @"asf";
    else if(MEDIAINFO_MUXTYPE_RM == muxType)
        muxTypeStr = @"rm";
    else if(MEDIAINFO_MUXTYPE_WAV == muxType)
        muxTypeStr = @"wav";
    else if(MEDIAINFO_MUXTYPE_OGG == muxType)
        muxTypeStr = @"ogg";
    else if(MEDIAINFO_MUXTYPE_APE == muxType)
        muxTypeStr = @"ape";
    else if(MEDIAINFO_MUXTYPE_RAWVIDEO == muxType)
        muxTypeStr = @"rawvideo";
    else if(MEDIAINFO_MUXTYPE_HLS == muxType)
        muxTypeStr = @"hls";
    
    return muxTypeStr;
}

- (NSString *)convertAVCodec:(MEDIAINFO_CODEC_ID)codecID
{
    NSString *codecIDStr = @"unknow codec";
    
    if(MEDIAINFO_CODEC_MPEG2VIDEO == codecID)
        codecIDStr = @"mpeg2";
    else if(MEDIAINFO_CODEC_MPEG4 == codecID)
        codecIDStr = @"mpeg4";
    else if(MEDIAINFO_CODEC_MJPEG == codecID)
        codecIDStr = @"mjpeg";
    else if(MEDIAINFO_CODEC_JPEG2000 == codecID)
        codecIDStr = @"jpeg2000";
    else if(MEDIAINFO_CODEC_H264 == codecID)
        codecIDStr = @"h264";
    else if(MEDIAINFO_CODEC_HEVC == codecID)
        codecIDStr = @"hevc";
    else if(MEDIAINFO_CODEC_VC1 == codecID)
        codecIDStr = @"vc1";
    else if(MEDIAINFO_CODEC_AAC == codecID)
        codecIDStr = @"aac";
    else if(MEDIAINFO_CODEC_AC3 == codecID)
        codecIDStr = @"ac3";
    else if(MEDIAINFO_CODEC_MP3 == codecID)
        codecIDStr = @"mp3";
    else if(MEDIAINFO_CODEC_PCM == codecID)
        codecIDStr = @"pcm";
    else if(MEDIAINFO_CODEC_DTS == codecID)
        codecIDStr = @"dts";
    else if(MEDIAINFO_CODEC_NELLYMOSER == codecID)
        codecIDStr = @"nellymoser";
    
    return codecIDStr;
}


- (NSString *)convertSampleFMT:(MEDIAINFO_SAMPLE_FMT)afmt
{
    NSString *sampleFMTStr = @"unknown sample formats";
    
    if(MEDIAINFO_SAMPLE_FMT_U8 == afmt)
        sampleFMTStr = @"unsigned 8 bits";
    else if(MEDIAINFO_SAMPLE_FMT_S16 == afmt)
        sampleFMTStr = @"signed 16 bits";
    else if(MEDIAINFO_SAMPLE_FMT_S32 == afmt)
        sampleFMTStr = @"signed 32 bits";
    else if(MEDIAINFO_SAMPLE_FMT_FLT == afmt)
        sampleFMTStr = @"float";
    else if(MEDIAINFO_SAMPLE_FMT_DBL == afmt)
        sampleFMTStr = @"double";
    else if(MEDIAINFO_SAMPLE_FMT_U8P == afmt)
        sampleFMTStr = @"unsigned 8 bits, planar";
    else if(MEDIAINFO_SAMPLE_FMT_S16P == afmt)
        sampleFMTStr = @"signed 16 bits, planar";
    else if(MEDIAINFO_SAMPLE_FMT_S32P == afmt)
        sampleFMTStr = @"signed 32 bits, planar";
    else if(MEDIAINFO_SAMPLE_FMT_FLTP == afmt)
        sampleFMTStr = @"float, planar";
    else if(MEDIAINFO_SAMPLE_FMT_DBLP == afmt)
        sampleFMTStr = @"double, planar";
    else if(MEDIAINFO_SAMPLE_FMT_NB == afmt)
        sampleFMTStr = @"Number of sample formats";

    return sampleFMTStr;
}

@end