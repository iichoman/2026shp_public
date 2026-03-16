#version 330

uniform float u_Time;

in vec3 a_Position;

void Basic()
{
	float t = mod(u_Time*10,1.0);	// 0~1
	vec4 newPosition;
	//newPosition = vec4(a_Position, 1);	// ??? 왜 이거 없음?
	newPosition.x = a_Position.x + t;
	newPosition.y = a_Position.y;
	newPosition.z = a_Position.z;
	gl_Position = newPosition;
}

void sin1()
{
	float t = mod(u_Time*10,1.0);	// 0~1
	vec4 newPosition;
	//newPosition = vec4(a_Position, 1);
	newPosition.x = a_Position.x + t;
	newPosition.y = a_Position.y + 0.5*sin(t*2*3.141592);
	newPosition.z = a_Position.z;
	gl_Position = newPosition;
}

void sin2()
{
	float t = mod(u_Time * 0.5, 1.0);   // 0~1 반복

	vec4 newPosition = vec4(a_Position, 1.0);
	newPosition.x = a_Position.x + (-1.0 + 2.0 * t);
	newPosition.y = a_Position.y + 0.3 * sin(t * 2.0 * 3.141592);
	newPosition.z = a_Position.z;

	gl_Position = newPosition;
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

    gl_Position = vec4(flower + orbit, a_Position.z, 1.0);}

void main()
{
	//Basic();
	//Circle();
	//GPT2();
    sin1();
}
