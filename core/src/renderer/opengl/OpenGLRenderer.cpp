#include "renderer/opengl/OpenGLRenderer.hpp"

#include <format>

#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>

namespace {
    const char* vertexShaderSource = R"(
        #version 330 core
        layout (location = 0) in vec3 aPos;
        layout (location = 1) in vec2 aUV;
        layout (location = 2) in vec3 aNormal;

        out vec2 uv;
        out vec3 Normal; // Передаем нормаль для света

        uniform mat4 projection;
        uniform mat4 view;
        uniform mat4 model;

        void main() {
            uv = aUV;
            // Правильное преобразование нормали в мировое пространство
            Normal = mat3(transpose(inverse(model))) * aNormal;
            gl_Position = projection * view * model * vec4(aPos, 1.0);
        }
    )";

    const float quadVertices[] = {
        -1.0f,  1.0f,
        -1.0f, -1.0f,
         1.0f, -1.0f,
        -1.0f,  1.0f,
         1.0f, -1.0f,
         1.0f,  1.0f
    };

} // namespace

OpenGLRenderer::OpenGLRenderer(int width, int height)
    : _width(width), _height(height) {
    initialize(width, height);
}

OpenGLRenderer::~OpenGLRenderer() {
    glDeleteProgram(_shaderProgram);
    glDeleteFramebuffers(1, &_framebuffer);
    glDeleteTextures(1, &_texture);
    // glDeleteVertexArrays(1, &_vao);
    // glDeleteBuffers(1, &_vbo);
    glDeleteVertexArrays(1, &sphereVAO);
    glDeleteBuffers(1, &sphereVBO);
    glDeleteBuffers(1, &sphereEBO);

    glDeleteRenderbuffers(1, &_rbo);

    if (_window) {
        glfwDestroyWindow(_window);
        glfwTerminate();
    }
}

bool OpenGLRenderer::initialize(int width, int height) {
    if (!glfwInit()) {
        std::cerr << "OpenGLRenderer::initialize: Failed to initialize GLFW" << std::endl;
        return false;
    }

    glfwWindowHint(GLFW_VISIBLE, GLFW_FALSE);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

    _window = glfwCreateWindow(width, height, "OpenGL Renderer", nullptr, nullptr);
    if (!_window) {
        std::cerr << "OpenGLRenderer::initialize: Failed to create GLFW window" << std::endl;

        glfwTerminate();
        return false;
    }
    glfwMakeContextCurrent(_window);

    glewExperimental = GL_TRUE;
    if (glewInit() != GLEW_OK) {
        std::cerr << "OpenGLRenderer::initialize: Failed to initialize GLEW" << std::endl;
        return false;
    }

    glGenFramebuffers(1, &_framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);

    glGenTextures(1, &_texture);
    glBindTexture(GL_TEXTURE_2D, _texture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, nullptr);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _texture, 0);

    glGenRenderbuffers(1, &_rbo);
    glBindRenderbuffer(GL_RENDERBUFFER, _rbo);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH24_STENCIL8, width, height);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT, GL_RENDERBUFFER, _rbo);

    // setupQuad();
    setupSphere();

    _pixelBuffer.resize(width * height * 4); // RGBA

    return true;
}

void OpenGLRenderer::setupQuad() {
    glGenVertexArrays(1, &_vao);
    glGenBuffers(1, &_vbo);

    glBindVertexArray(_vao);

    glBindBuffer(GL_ARRAY_BUFFER, _vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(quadVertices), &quadVertices, GL_STATIC_DRAW);

    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(float), (void *)0);
}

void OpenGLRenderer::setupSphere() {
    std::vector<float> vertices;
    std::vector<unsigned int> indices;

    const unsigned int X_SEGMENTS = 64;
    const unsigned int Y_SEGMENTS = 64;
    const float PI = 3.14159265359f;

    for (unsigned int y = 0; y <= Y_SEGMENTS; ++y) {
        for (unsigned int x = 0; x <= X_SEGMENTS; ++x) {
            float xSegment = (float)x / (float)X_SEGMENTS;
            float ySegment = (float)y / (float)Y_SEGMENTS;

            float xPos = std::cos(xSegment * 2.0f * PI) * std::sin(ySegment * PI);
            float yPos = std::cos(ySegment * PI);
            float zPos = std::sin(xSegment * 2.0f * PI) * std::sin(ySegment * PI);

            // pos (3)
            vertices.push_back(xPos);
            vertices.push_back(yPos);
            vertices.push_back(zPos);
            // UV (2)
            vertices.push_back(xSegment);
            vertices.push_back(ySegment);
            // Normal (3) - for a sphere, the normal is the same as the position
            vertices.push_back(xPos);
            vertices.push_back(yPos);
            vertices.push_back(zPos);
        }
    }

    // generate indices
    for (unsigned int y = 0; y < Y_SEGMENTS; ++y) {
        for (unsigned int x = 0; x < X_SEGMENTS; ++x) {
            indices.push_back(y * (X_SEGMENTS + 1) + x);
            indices.push_back((y + 1) * (X_SEGMENTS + 1) + x);
            indices.push_back(y * (X_SEGMENTS + 1) + x + 1);

            indices.push_back((y + 1) * (X_SEGMENTS + 1) + x);
            indices.push_back((y + 1) * (X_SEGMENTS + 1) + x + 1);
            indices.push_back(y * (X_SEGMENTS + 1) + x + 1);
        }
    }
    sphereIndexCount = static_cast<unsigned int>(indices.size());

    // load into GPU
    glGenVertexArrays(1, &sphereVAO);
    glGenBuffers(1, &sphereVBO);
    glGenBuffers(1, &sphereEBO);

    glBindVertexArray(sphereVAO);
    glBindBuffer(GL_ARRAY_BUFFER, sphereVBO);
    glBufferData(GL_ARRAY_BUFFER, vertices.size() * sizeof(float), vertices.data(), GL_STATIC_DRAW);

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, sphereEBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.size() * sizeof(unsigned int), indices.data(), GL_STATIC_DRAW);

    // Stride = 8 floats (3 pos + 2 uv + 3 normal)
    int stride = 8 * sizeof(float);
    glEnableVertexAttribArray(0);

        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, stride, (void *)0);
        glEnableVertexAttribArray(1);
        glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, stride, (void *)(3 * sizeof(float)));
        glEnableVertexAttribArray(2);
        glVertexAttribPointer(2, 3, GL_FLOAT, GL_FALSE, stride, (void *)(5 * sizeof(float)));

    glBindVertexArray(0);
}

void OpenGLRenderer::updateShader(const std::string &fragmentShaderCode) {
    glfwMakeContextCurrent(_window);

    std::string fullSource = std::format(
        "#version 330 core\n"
        "out vec4 FragColor;\n"
        "in vec2 uv;\n"
        "in vec3 Normal;\n  "
        "uniform float uTime;\n"
        "{}\n"
        "\nvoid main() {{\n"
        "    vec4 baseColor;"
        "    mainImage(baseColor, uv);\n"
        "    vec3 lightDir = normalize(vec3(1.0, 1.0, 1.0));\n"
        "    float diff = max(dot(normalize(Normal), lightDir), 0.0);\n"
        "    vec3 ambient = vec3(0.15);\n"
        "    FragColor = vec4(baseColor.rgb * (diff + ambient), baseColor.a);\n"
        "}}\n",
        fragmentShaderCode);

    GLuint vs = compileShader(GL_VERTEX_SHADER, vertexShaderSource);
    GLuint fs = compileShader(GL_FRAGMENT_SHADER, fullSource);

    if (_shaderProgram) {
        glDeleteProgram(_shaderProgram);
    }

    _shaderProgram = glCreateProgram();
    glAttachShader(_shaderProgram, vs);
    glAttachShader(_shaderProgram, fs);
    glLinkProgram(_shaderProgram);

    GLint success;
    glGetProgramiv(_shaderProgram, GL_LINK_STATUS, &success);
    if (!success) {
        char infoLog[1024];
        glGetProgramInfoLog(_shaderProgram, 1024, NULL, infoLog);
        std::cerr << std::format("OpenGLRenderer::updateShader: Shader linking error:\n{}", infoLog) << std::endl;
    }

    glDeleteShader(vs);
    glDeleteShader(fs);
}

void OpenGLRenderer::render() {
    glfwMakeContextCurrent(_window);

    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
    glViewport(0, 0, _width, _height);

    glEnable(GL_DEPTH_TEST);
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);

    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glUseProgram(_shaderProgram);

    GLint timeLoc = glGetUniformLocation(_shaderProgram, "uTime");
    if (timeLoc != -1) {
        GLfloat timeValue = static_cast<GLfloat>(glfwGetTime());
        glUniform1f(timeLoc, timeValue);
    }

    glm::mat4 projection = glm::perspective(glm::radians(45.0f), static_cast<float>(_width) / static_cast<float>(_height), 0.1f, 100.0f);
    glm::mat4 view = glm::translate(glm::mat4(1.0f), glm::vec3(0.0f, 0.0f, -3.0f)); // Камера чуть назад

    glm::mat4 model = glm::rotate(glm::mat4(1.0f), (float)glfwGetTime() * 0.5f, glm::vec3(0.0f, 1.0f, 0.0f));

    glUniformMatrix4fv(glGetUniformLocation(_shaderProgram, "projection"), 1, GL_FALSE, glm::value_ptr(projection));
    glUniformMatrix4fv(glGetUniformLocation(_shaderProgram, "view"), 1, GL_FALSE, glm::value_ptr(view));
    glUniformMatrix4fv(glGetUniformLocation(_shaderProgram, "model"), 1, GL_FALSE, glm::value_ptr(model));

    glBindVertexArray(sphereVAO);
    glDrawElements(GL_TRIANGLES, sphereIndexCount, GL_UNSIGNED_INT, 0);

    // glUseProgram(_shaderProgram);
    // glBindVertexArray(_vao);
    // glDrawArrays(GL_TRIANGLES, 0, 6);

    glReadPixels(0, 0, _width, _height, GL_RGBA, GL_UNSIGNED_BYTE, _pixelBuffer.data());
}

GLuint OpenGLRenderer::compileShader(GLenum type, const std::string &source) {
    GLuint shader = glCreateShader(type);

    const char *src = source.c_str();
    glShaderSource(shader, 1, &src, nullptr);
    glCompileShader(shader);

    GLint success;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &success);
    if (!success) {
        char infoLog[1024];
        glGetShaderInfoLog(shader, 1024, NULL, infoLog);
        std::cerr << std::format("OpenGLRenderer::compileShader: Shader compilation error:\n{}", infoLog) << std::endl;
        std::string shaderType = std::format("{}", (type == GL_VERTEX_SHADER) ? "VERTEX" : "FRAGMENT");

        std::cerr << std::format("OpenGLRenderer::compileShader: {} shader compilation error:\n{}", shaderType, infoLog) << std::endl;
        std::cerr << std::format("OpenGLRenderer::compileShader: Shader source:\n{}", source) << std::endl;
    }

    return shader;
}