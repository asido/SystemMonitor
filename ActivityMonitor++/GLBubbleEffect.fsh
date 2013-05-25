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