//
//  VKMusicBypass.h
//  VKMusicBypass
//
//  Created by Даниил on 03/01/2019.
//  Copyright © 2019 Даниил. All rights reserved.
//

#import <Foundation/NSString.h>

extern BOOL vkb_shouldBypassMusic;
extern NSString *vkb_certificateTID;

static NSString *const vkb_defaultSettingsDomain = @"ru.danpashin.vkparams";
static NSString *const vkb_apiURL = @"https://api.danpashin.ru/v1.3/";
