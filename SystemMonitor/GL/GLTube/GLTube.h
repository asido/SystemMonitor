//
//  GLTube.h
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import <GLKit/GLKit.h>

@interface GLTube : GLKViewController
- (id)initWithGLKView:(GLKView*)aGLView fromValue:(double)from toValue:(double)to;
- (void)setValue:(double)value;
@end
