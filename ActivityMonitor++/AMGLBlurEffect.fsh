precision mediump float;

uniform sampler2D u_texture0;

varying vec2 v_texCoord0;

const float blurSize = 1.0 / 512.0;

void main()
{
    
    vec4 sum = vec4(0.0);
    
    // Take 9 samples, with the distance blurSize between them.
    sum += texture2D(u_texture0, vec2(v_texCoord0.x, v_texCoord0.y - 4.0*blurSize)) * 0.02;
    sum += texture2D(u_texture0, vec2(v_texCoord0.x, v_texCoord0.y - 3.0*blurSize)) * 0.05;
    sum += texture2D(u_texture0, vec2(v_texCoord0.x, v_texCoord0.y - 2.0*blurSize)) * 0.09;
    sum += texture2D(u_texture0, vec2(v_texCoord0.x, v_texCoord0.y - blurSize)) * 0.12;
    sum += texture2D(u_texture0, vec2(v_texCoord0.x, v_texCoord0.y)) * 0.16;
    sum += texture2D(u_texture0, vec2(v_texCoord0.x, v_texCoord0.y + blurSize)) * 0.12;
    sum += texture2D(u_texture0, vec2(v_texCoord0.x, v_texCoord0.y + 2.0*blurSize)) * 0.09;
    sum += texture2D(u_texture0, vec2(v_texCoord0.x, v_texCoord0.y + 3.0*blurSize)) * 0.05;
    sum += texture2D(u_texture0, vec2(v_texCoord0.x, v_texCoord0.y + 4.0*blurSize)) * 0.02;
    
        sum += texture2D(u_texture0, vec2(v_texCoord0.x - 4.0*blurSize, v_texCoord0.y)) * 0.02;
        sum += texture2D(u_texture0, vec2(v_texCoord0.x - 3.0*blurSize, v_texCoord0.y)) * 0.05;
        sum += texture2D(u_texture0, vec2(v_texCoord0.x - 2.0*blurSize, v_texCoord0.y)) * 0.09;
        sum += texture2D(u_texture0, vec2(v_texCoord0.x - blurSize, v_texCoord0.y)) * 0.12;
        sum += texture2D(u_texture0, vec2(v_texCoord0.x, v_texCoord0.y)) * 0.16;
        sum += texture2D(u_texture0, vec2(v_texCoord0.x + blurSize, v_texCoord0.y)) * 0.12;
        sum += texture2D(u_texture0, vec2(v_texCoord0.x + 2.0*blurSize, v_texCoord0.y)) * 0.09;
        sum += texture2D(u_texture0, vec2(v_texCoord0.x + 3.0*blurSize, v_texCoord0.y)) * 0.05;
        sum += texture2D(u_texture0, vec2(v_texCoord0.x + 4.0*blurSize, v_texCoord0.y)) * 0.02;
    
    
    /*
    vec2 texCoord = v_texCoord0;
    int j;
    int i;
    
    
    for (i = -4; i < 4; i++)
    {
        for (j = -3; j < 3; j++)
        {
            sum += texture2D(u_texture0, texCoord + vec2(j,i)*0.004) * 0.25;
        }
    }
    
    if (texture2D(u_texture0, texCoord).r < 0.3)
    {
        gl_FragColor = sum * sum * 0.012 + texture2D(u_texture0, texCoord);
    }
    else
    {
        if (texture2D(u_texture0, texCoord).r < 0.5)
        {
            gl_FragColor = sum * sum * 0.009 + texture2D(u_texture0, texCoord);
        }
        else
        {
            gl_FragColor = sum * sum * 0.0075 + texture2D(u_texture0, texCoord);
        }
    }
    */
    
    gl_FragColor = sum;
}