//
//  GLBubbleEffect.vsh
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

attribute vec3      a_position;
attribute vec3      a_velocity;
attribute float     a_size;
attribute float     a_starttime;

uniform highp mat4  u_mvpMatrix;
uniform highp float u_elapsedTime;
uniform highp float u_maxRightPosition;
uniform sampler2D   u_samplers2D[1];

varying lowp float  v_visible;
varying lowp float  v_color;

void main()
{
    float xPos = (u_elapsedTime - a_starttime) * a_velocity.x;
    
    vec4 position = vec4(a_position, 1.0);
    position.x += xPos;

    if (position.x < u_maxRightPosition)
    {
        v_visible = 1.0;
    }
    else
    {
        v_visible = 0.0;
    }
    
    gl_Position = u_mvpMatrix * position;

    gl_PointSize = a_size;
}