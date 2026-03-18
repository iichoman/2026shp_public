#include "stdafx.h"
#include "Renderer.h"

Renderer::Renderer(int windowSizeX, int windowSizeY)
{
	Initialize(windowSizeX, windowSizeY);
}

Renderer::~Renderer()
{
}

void Renderer::Initialize(int windowSizeX, int windowSizeY)
{
	// Set window size
	m_WindowSizeX = windowSizeX;
	m_WindowSizeY = windowSizeY;

	srand((unsigned int)time(NULL));

	// Load shaders
	m_SolidRectShader = CompileShaders("./Shaders/SolidRect.vs", "./Shaders/SolidRect.fs");
	m_TriangleShader = CompileShaders("./Shaders/Triangle.vs", "./Shaders/Triangle.fs");

	// Create VBOs
	CreateVertexBufferObjects();

	GenParticles(30000);

	if (m_SolidRectShader > 0 && m_VBORect > 0)
	{
		m_Initialized = true;
	}
}

bool Renderer::IsInitialized()
{
	return m_Initialized;
}

void Renderer::CreateVertexBufferObjects()
{
	float rect[] =
	{
		-1.f / m_WindowSizeX, -1.f / m_WindowSizeY, 0.f,
		-1.f / m_WindowSizeX,  1.f / m_WindowSizeY, 0.f,
		 1.f / m_WindowSizeX,  1.f / m_WindowSizeY, 0.f,

		-1.f / m_WindowSizeX, -1.f / m_WindowSizeY, 0.f,
		 1.f / m_WindowSizeX,  1.f / m_WindowSizeY, 0.f,
		 1.f / m_WindowSizeX, -1.f / m_WindowSizeY, 0.f,
	};

	glGenBuffers(1, &m_VBORect);
	glBindBuffer(GL_ARRAY_BUFFER, m_VBORect);
	glBufferData(GL_ARRAY_BUFFER, sizeof(rect), rect, GL_STATIC_DRAW);
}

void Renderer::AddShader(GLuint ShaderProgram, const char* pShaderText, GLenum ShaderType)
{
	GLuint ShaderObj = glCreateShader(ShaderType);

	if (ShaderObj == 0)
	{
		fprintf(stderr, "Error creating shader type %d\n", ShaderType);
	}

	const GLchar* p[1];
	p[0] = pShaderText;

	GLint Lengths[1];
	Lengths[0] = (GLint)strlen(pShaderText);

	glShaderSource(ShaderObj, 1, p, Lengths);
	glCompileShader(ShaderObj);

	GLint success;
	glGetShaderiv(ShaderObj, GL_COMPILE_STATUS, &success);

	if (!success)
	{
		GLchar InfoLog[1024];
		glGetShaderInfoLog(ShaderObj, 1024, NULL, InfoLog);
		fprintf(stderr, "Error compiling shader type %d: '%s'\n", ShaderType, InfoLog);
		printf("%s \n", pShaderText);
	}

	glAttachShader(ShaderProgram, ShaderObj);
}

bool Renderer::ReadFile(char* filename, std::string* target)
{
	std::ifstream file(filename);

	if (file.fail())
	{
		std::cout << filename << " file loading failed.. \n";
		file.close();
		return false;
	}

	std::string line;
	while (getline(file, line))
	{
		target->append(line.c_str());
		target->append("\n");
	}

	file.close();
	return true;
}

GLuint Renderer::CompileShaders(char* filenameVS, char* filenameFS)
{
	GLuint ShaderProgram = glCreateProgram();

	if (ShaderProgram == 0)
	{
		fprintf(stderr, "Error creating shader program\n");
	}

	std::string vs, fs;

	if (!ReadFile(filenameVS, &vs))
	{
		printf("Error compiling vertex shader\n");
		return -1;
	}

	if (!ReadFile(filenameFS, &fs))
	{
		printf("Error compiling fragment shader\n");
		return -1;
	}

	AddShader(ShaderProgram, vs.c_str(), GL_VERTEX_SHADER);
	AddShader(ShaderProgram, fs.c_str(), GL_FRAGMENT_SHADER);

	GLint Success = 0;
	GLchar ErrorLog[1024] = { 0 };

	glLinkProgram(ShaderProgram);
	glGetProgramiv(ShaderProgram, GL_LINK_STATUS, &Success);

	if (Success == 0)
	{
		glGetProgramInfoLog(ShaderProgram, sizeof(ErrorLog), NULL, ErrorLog);
		std::cout << filenameVS << ", " << filenameFS << " Error linking shader program\n" << ErrorLog;
		return -1;
	}

	glValidateProgram(ShaderProgram);
	glGetProgramiv(ShaderProgram, GL_VALIDATE_STATUS, &Success);

	if (!Success)
	{
		glGetProgramInfoLog(ShaderProgram, sizeof(ErrorLog), NULL, ErrorLog);
		std::cout << filenameVS << ", " << filenameFS << " Error validating shader program\n" << ErrorLog;
		return -1;
	}

	glUseProgram(ShaderProgram);
	std::cout << filenameVS << ", " << filenameFS << " Shader compiling is done." << std::endl;

	return ShaderProgram;
}

void Renderer::DrawSolidRect(float x, float y, float z, float size, float r, float g, float b, float a)
{
	float newX, newY;

	GetGLPosition(x, y, &newX, &newY);

	glUseProgram(m_SolidRectShader);

	glUniform4f(glGetUniformLocation(m_SolidRectShader, "u_Trans"), newX, newY, 0, size);
	glUniform4f(glGetUniformLocation(m_SolidRectShader, "u_Color"), r, g, b, a);

	int attribPosition = glGetAttribLocation(m_SolidRectShader, "a_Position");
	glEnableVertexAttribArray(attribPosition);

	glBindBuffer(GL_ARRAY_BUFFER, m_VBORect);
	glVertexAttribPointer(attribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(float) * 3, 0);

	glDrawArrays(GL_TRIANGLES, 0, 6);

	glDisableVertexAttribArray(attribPosition);

	glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

float g_Time = 0;

void Renderer::DrawTriangle()
{
	g_Time += 0.0001f;

	glUseProgram(m_TriangleShader);

	int u_Time = glGetUniformLocation(m_TriangleShader, "u_Time");
	glUniform1f(u_Time, g_Time);

	int attribPosition = glGetAttribLocation(m_TriangleShader, "a_Position");
	int attriMass = glGetAttribLocation(m_TriangleShader, "a_Mass");
	int attriVel = glGetAttribLocation(m_TriangleShader, "a_Vel");
	int attriRV = glGetAttribLocation(m_TriangleShader, "a_RV");
	glEnableVertexAttribArray(attribPosition);
	glEnableVertexAttribArray(attriMass);
	glEnableVertexAttribArray(attriVel);
	glEnableVertexAttribArray(attriRV);
	glBindBuffer(GL_ARRAY_BUFFER, m_TriangleVBO);

	glVertexAttribPointer(attribPosition, 3,
		GL_FLOAT, GL_FALSE,
		7 * sizeof(float), 0);

	glVertexAttribPointer(attriMass, 1,
		GL_FLOAT, GL_FALSE,
		7 * sizeof(float), (GLvoid*)(sizeof(float) * 3));

	glVertexAttribPointer(attriVel, 2,
		GL_FLOAT, GL_FALSE,
		7 * sizeof(float), (GLvoid*)(sizeof(float) * 4));
	glVertexAttribPointer(attriRV, 2,
		GL_FLOAT, GL_FALSE,
		7 * sizeof(float), (GLvoid*)(sizeof(float) * 5));

	glDrawArrays(GL_POINTS, 0, m_TriangleVertexCount);

	glDisableVertexAttribArray(attribPosition);
	glDisableVertexAttribArray(attriMass);
	glDisableVertexAttribArray(attriVel);
}

void Renderer::GenParticles(int Num)
{
	if (Num <= 0)
		return;

	std::vector<float> particles;
	particles.reserve(Num * 7);

	for (int i = 0; i < Num; i++)
	{
		float x = ((float)rand() / RAND_MAX) * 2.0f - 1.0f;
		float y = ((float)rand() / RAND_MAX) * 2.0f - 1.0f;
		float z = 0.0f;

		float mass = ((float)rand() / RAND_MAX) * 0.9f + 0.1f;

		float vx = ((float)rand() / RAND_MAX) * 2.0f - 1.0f;
		float vy = ((float)rand() / RAND_MAX) * 2.0f - 1.0f;
		float rv = ((float)rand() / RAND_MAX) * 2.0f - 1.0f;
		particles.push_back(x);
		particles.push_back(y);
		particles.push_back(z);
		particles.push_back(mass);
		particles.push_back(vx);
		particles.push_back(vy);
		particles.push_back(rv);
	}

	m_TriangleVertexCount = Num;

	if (m_TriangleVBO == 0)
	{
		glGenBuffers(1, &m_TriangleVBO);
	}

	glBindBuffer(GL_ARRAY_BUFFER, m_TriangleVBO);
	glBufferData(GL_ARRAY_BUFFER, sizeof(float) * particles.size(), particles.data(), GL_STATIC_DRAW);
}
void Renderer::GetGLPosition(float x, float y, float* newX, float* newY)
{
	*newX = x * 2.f / m_WindowSizeX;
	*newY = y * 2.f / m_WindowSizeY;
}