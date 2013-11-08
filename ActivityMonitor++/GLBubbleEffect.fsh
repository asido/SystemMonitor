//
//  GLBubbleEffect.fsh
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

uniform sampler2D   u_samplers2D[1];

varying lowp float  v_visible;
varying lowp float  v_color;

void main()
{
    lowp vec4 color;
    
    if (v_visible > 0.5)
    {
        color = texture2D(u_samplers2D[0], gl_PointCoord);
    }
    else
    {
        color = texture2D(u_samplers2D[0], gl_PointCoord);
        color.a = 0.0;
    }
    
    gl_FragColor = color;
}