#version 330

uniform float u_Time;

in vec3 a_Position;
in float a_Mass;
in vec2 a_Vel;
in float a_RV;
in float a_RV1;
in float a_RV2;

const float c_PI = 3.141592;
const vec2 c_G= vec2(0, -9.8);

void Basic()
{
	float t = mod(u_Time*10,1.0);	// 0~1
	vec4 newPosition;
	//newPosition = vec4(a_Position, 1);	// ??? 왜 이거 없음?
	newPosition.x = a_Position.x + t;
	newPosition.y = a_Position.y;
	newPosition.z = a_Position.z;
    newPosition.w = 1.0;                    // 분명 이거 없었는데?????
	gl_Position = newPosition;
    gl_PointSize = 3.0;
}

void sin1()
{
	float t = mod(u_Time*10,1.0);	// 0~1
	vec4 newPosition;
	newPosition = vec4(a_Position, 1);
	newPosition.x = a_Position.x + t;
	newPosition.y = a_Position.y + 0.5*sin(t*2*3.141592);
	newPosition.z = a_Position.z;
	gl_Position = newPosition;
    gl_PointSize = 3.0;
}

void sin2()
{
	float t = mod(u_Time * 0.5, 1.0);   // 0~1 반복

	vec4 newPosition = vec4(a_Position, 1.0);
	newPosition.x = a_Position.x + (-1.0 + 2.0 * t);
	newPosition.y = a_Position.y + 0.3 * sin(t * 2.0 * 3.141592);
	newPosition.z = a_Position.z;

	gl_Position = newPosition;
    gl_PointSize = 3.0;
}

void Circle()
{
	float t = mod(u_Time * 0.5, 1.0);   // 0~1 반복
	float r = 0.5;
	vec4 newPosition = vec4(a_Position, 1.0);	// 교수님 코드 이거 왜 없냐고
	newPosition.x = a_Position.x + 1 * r*cos(t * 2 * 3.141592);
	newPosition.y = a_Position.y + 1 * r*sin(t * 2 * 3.141592);
	newPosition.z = a_Position.z;

	gl_Position = newPosition;
    gl_PointSize = 3.0;
}

void GPT1()
{
    float t = u_Time * 2.0;
    float pi = 3.141592;
    float angle = t;

    vec2 p = a_Position.xy;

    float len = length(p);
    float localAngle = atan(p.y, p.x);

    // 도형 자체가 숨쉬듯 커졌다 작아짐
    float scale = 1.0 + 0.35 * sin(t * 2.5);

    // 정점마다 위상이 달라지는 꽃잎 모양 왜곡
    float flower = 0.15 * sin(localAngle * 6.0 + t * 4.0);

    // 도형 자체가 회전하면서 비틀림
    float twist = localAngle + t * 2.0 + len * 4.0 * sin(t * 1.5);

    // 반지름 변화
    float radius = (len * scale) + flower;

    vec2 warped;
    warped.x = radius * cos(twist);
    warped.y = radius * sin(twist);

    // 전체 오브젝트는 큰 원을 따라 공전
    vec2 orbit;
    orbit.x = 0.55 * cos(angle);
    orbit.y = 0.55 * sin(angle);

    // 추가로 위아래로 살짝 파도치게
    warped.y += 0.12 * sin(t * 5.0 + warped.x * 8.0);

    gl_Position = vec4(warped + orbit, a_Position.z, 1.0);
    gl_PointSize = 3.0;
}

void GPT2() { 
    float pi = 3.141592;
    float t = u_Time * 1.2;

    vec2 p = a_Position.xy;

    float len = length(p);
    float ang = atan(p.y, p.x);

    // 꽃잎처럼 퍼졌다 오므라드는 반지름 변화
    float bloom = 1.0 + 0.25 * sin(ang * 6.0 - t * 2.0);

    // 전체 도형이 숨 쉬듯 커졌다 작아짐
    float breath = 1.0 + 0.12 * sin(t * 1.8);

    // 도형 자체가 천천히 회전
    float spin = ang + t * 0.8;

    vec2 flower;
    flower.x = len * bloom * breath * cos(spin);
    flower.y = len * bloom * breath * sin(spin);

    // 중심 자체가 부드럽게 원운동
    vec2 orbit;
    orbit.x = 0.45 * cos(t * 0.7);
    orbit.y = 0.25 * sin(t * 0.7);

    // 위아래로 은은하게 출렁임
    flower.y += 0.08 * sin(t * 2.5 + flower.x * 4.0);

    gl_Position = vec4(flower + orbit, a_Position.z, 1.0);
    gl_PointSize = 3.0;
}

float pseudoRandom (float n) {
    return fract(sin(n) * 43758.5453123);
}

void Falling()
{
    //emitTime
    //float newTime = u_Time - pseudoRandom(a_RV);
    float newTime = u_Time - a_RV1;

    if( newTime > 0) {
        float scale = 0.15 + a_RV2 * 0.75;
        float t = mod(newTime, 1.0);
        float vx = a_Vel.x;
        float vy = a_Vel.y;
        //float initPosX = cos(a_RV*2*c_PI);  // 이게 왜 됨 
        //float initPosY = sin(a_RV*2*c_PI);  // 이게 왜 되지?
        //float initPosX = a_Position.x*scale + cos(a_RV*2*c_PI);  // 교수님 답안인데 이거 왜 안됨?
        //float initPosY = a_Position.y*scale + sin(a_RV*2*c_PI);  // " 이게 왜 안되지? // 0323추가 이제 왜 되지?
        float initPosX = a_Position.x + scale * cos(a_RV*2*c_PI);
        float initPosY = a_Position.y + scale * sin(a_RV*2*c_PI);
        vec4 newPosition;
        newPosition.x = initPosX + vx * t + 0.5 * c_G.x * t * t;
        newPosition.y = initPosY + vy * t + 0.5 * c_G.y * t * t;
        newPosition.z = 0;
        newPosition.w = 1;
        gl_Position = newPosition;
        gl_PointSize = 2.0 + a_RV2 * 8.0;
    }
    else
    {
        gl_Position = vec4(-10000, 1000, 0, 1);
        gl_PointSize = 1.0;
    }
}

mat2 Rotation(float angle)
{
    float c = cos(angle);
    float s = sin(angle);
    return mat2(c, -s, s, c);
}

void FancyExplosion_by_GPT()
{
    float delay = a_RV1 * 1.2;
    float localTime = u_Time - delay;

    if (localTime <= 0.0)
    {
        gl_Position = vec4(-10000.0, 10000.0, 0.0, 1.0);
        gl_PointSize = 1.0;
        return;
    }

    float t = mod(localTime, 1.6);
    float life = t / 1.6;

    float baseAngle = a_RV * 2.0 * c_PI;
    float rand0 = pseudoRandom(a_RV * 31.17 + a_RV1 * 17.73);
    float rand1 = pseudoRandom(a_RV1 * 91.31 + a_RV2 * 11.19);
    float rand2 = pseudoRandom(a_RV2 * 57.77 + a_RV * 43.11);

    float radius = 0.08 + 0.45 * a_RV2;
    vec2 ringOffset = radius * vec2(cos(baseAngle), sin(baseAngle));

    float burstPower = 0.35 + rand0 * 0.9;
    vec2 burstVel = normalize(vec2(cos(baseAngle), sin(baseAngle))) * burstPower;

    vec2 vel = a_Vel * (0.6 + rand1 * 1.8) + burstVel;

    float spinSpeed = 2.0 + 6.0 * rand2;
    float spiralAmount = 0.08 + 0.22 * a_RV2;
    float spiralRadius = spiralAmount * (1.0 - life) * (0.5 + 0.5 * sin(10.0 * life + a_RV1 * 9.0));

    vec2 spiral;
    spiral.x = cos(baseAngle + spinSpeed * t + rand1 * 6.0) * spiralRadius;
    spiral.y = sin(baseAngle + spinSpeed * t + rand1 * 6.0) * spiralRadius;

    float swirlAngle = sin(t * 2.5 + a_RV1 * 8.0) * (0.8 + a_RV2 * 1.6);
    vec2 moved = ringOffset + vel * t + 0.5 * (c_G / a_Mass) * t * t;
    moved = Rotation(swirlAngle) * moved;

    float waveX = 0.05 * sin(18.0 * life + a_RV * 15.0 + moved.y * 6.0);
    float waveY = 0.05 * cos(16.0 * life + a_RV2 * 13.0 + moved.x * 6.0);

    float pulse = 1.0 + 0.35 * sin(20.0 * life + a_RV1 * 20.0);
    float shrink = 1.0 - 0.65 * life;

    vec2 finalPos = a_Position.xy
        + moved * pulse * shrink
        + spiral
        + vec2(waveX, waveY);

    gl_Position = vec4(finalPos, a_Position.z, 1.0);

    // 입자 크기 랜덤 + 시간에 따라 변화
    float sizePulse = 0.5 + 0.5 * sin(25.0 * life + a_RV * 30.0 + a_RV2 * 10.0);
    float sizeBase = 2.0 + 10.0 * a_RV2;
    //gl_PointSize = max(1.0, sizeBase * (1.0 - 0.7 * life) + 4.0 * sizePulse);
    //gl_PointSize = 2500;
}

void Falling2()
{
    float newTime = u_Time - a_RV1;

    if (newTime > 0.0) {
        float t = mod(newTime, 1.0);
        float vx = a_Vel.x;
        float vy = a_Vel.y;

        float radius = 0.2 + a_RV2 * 1.0;

        float initPosX = a_Position.x + radius * cos(a_RV * 2.0 * c_PI);
        float initPosY = a_Position.y + radius * sin(a_RV * 2.0 * c_PI);

        vec4 newPosition;
        newPosition.x = initPosX + vx * t + 0.5 * c_G.x * t * t;
        newPosition.y = initPosY + vy * t + 0.5 * c_G.y * t * t;
        newPosition.z = 0.0;
        newPosition.w = 1.0;

        gl_Position = newPosition;
    }
    else
    {
        gl_Position = vec4(-10000.0, 1000.0, 0.0, 1.0);
    }
}

void main()
{
    FancyExplosion_by_GPT();
}