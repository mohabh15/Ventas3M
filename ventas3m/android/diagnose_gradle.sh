#!/bin/bash

echo "=== DIAGNÓSTICO DE ERROR GRADLE ==="
echo "Fecha: $(date)"
echo "Usuario: $(whoami)"
echo "Directorio actual: $(pwd)"
echo ""

echo "1. VERIFICANDO RUTA DEL SDK DE FLUTTER..."
FLUTTER_SDK_PATH="/opt/homebrew/share/flutter"
if [ -d "$FLUTTER_SDK_PATH" ]; then
    echo "✓ Ruta del SDK de Flutter existe: $FLUTTER_SDK_PATH"
    if [ -x "$FLUTTER_SDK_PATH/bin/flutter" ]; then
        echo "✓ Binario de Flutter encontrado y ejecutable"
        FLUTTER_VERSION=$($FLUTTER_SDK_PATH/bin/flutter --version 2>&1)
        echo "Versión de Flutter: $FLUTTER_VERSION"
    else
        echo "✗ Binario de Flutter no encontrado o no ejecutable en $FLUTTER_SDK_PATH/bin/"
    fi
else
    echo "✗ Ruta del SDK de Flutter NO existe: $FLUTTER_SDK_PATH"
fi
echo ""

echo "2. VERIFICANDO RUTA DEL SDK DE ANDROID..."
ANDROID_SDK_PATH="/Users/mohabalich/Library/Android/sdk"
if [ -d "$ANDROID_SDK_PATH" ]; then
    echo "✓ Ruta del SDK de Android existe: $ANDROID_SDK_PATH"
    if [ -x "$ANDROID_SDK_PATH/platform-tools/adb" ]; then
        echo "✓ ADB encontrado y ejecutable"
    else
        echo "✗ ADB no encontrado en $ANDROID_SDK_PATH/platform-tools/"
    fi
else
    echo "✗ Ruta del SDK de Android NO existe: $ANDROID_SDK_PATH"
fi
echo ""

echo "3. VERIFICANDO VERSIÓN DE GRADLE..."
if command -v gradle &> /dev/null; then
    GRADLE_VERSION=$(gradle --version 2>&1)
    echo "Versión de Gradle instalada: $GRADLE_VERSION"
else
    echo "Gradle no encontrado en PATH"
fi
echo ""

echo "4. VERIFICANDO GRADLE WRAPPER..."
if [ -f "gradlew" ]; then
    echo "✓ Gradle Wrapper encontrado"
    if [ -x "gradlew" ]; then
        echo "✓ Gradle Wrapper es ejecutable"
        WRAPPER_VERSION=$(./gradlew --version 2>&1)
        echo "Versión del Gradle Wrapper: $WRAPPER_VERSION"
    else
        echo "✗ Gradle Wrapper no es ejecutable"
    fi
else
    echo "✗ Gradle Wrapper no encontrado"
fi
echo ""

echo "5. VERIFICANDO ARCHIVO GRADLE WRAPPER PROPERTIES..."
if [ -f "gradle/wrapper/gradle-wrapper.properties" ]; then
    echo "✓ Archivo gradle-wrapper.properties encontrado"
    cat gradle/wrapper/gradle-wrapper.properties
else
    echo "✗ Archivo gradle-wrapper.properties NO encontrado"
fi
echo ""

echo "6. VERIFICANDO PERMISOS DE ARCHIVOS..."
echo "Permisos del directorio android:"
ls -la ../
echo ""
echo "Permisos del archivo build.gradle.kts:"
ls -la build.gradle.kts
echo ""

echo "7. VERIFICANDO VARIABLES DE ENTORNO..."
echo "JAVA_HOME: $JAVA_HOME"
echo "ANDROID_HOME: $ANDROID_HOME"
echo "FLUTTER_ROOT: $FLUTTER_ROOT"
echo "PATH (primeros elementos): $(echo $PATH | cut -d: -f1-3)"
echo ""

echo "8. INTENTANDO EJECUTAR GRADLE CON LOGS DETALLADOS..."
echo "Ejecutando: ./gradlew assembleDebug --stacktrace --info"
echo "=== INICIO DE LOGS DE GRADLE ==="
./gradlew assembleDebug --stacktrace --info 2>&1 | head -50
echo "=== FIN DE LOGS DE GRADLE (primeras 50 líneas) ==="
echo ""

echo "=== FIN DEL DIAGNÓSTICO ==="