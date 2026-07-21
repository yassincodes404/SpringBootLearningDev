@REM ----------------------------------------------------------------------------
@REM Licensed to the Apache Software Foundation (ASF) under one
@REM or more contributor license agreements.  See the NOTICE file
@REM distributed with this work for additional information
@REM regarding copyright ownership.  The ASF licenses this file
@REM to you under the Apache License, Version 2.0 (the
@REM "License"); you may not use this file except in compliance
@REM with the License.  You may obtain a copy of the License at
@REM
@REM    http://www.apache.org/licenses/LICENSE-2.0
@REM
@REM Unless required by applicable law or agreed to in writing,
@REM software distributed under the License is distributed on an
@REM "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
@REM KIND, either express or implied.  See the License for the
@REM specific language governing permissions and limitations
@REM under the License.
@REM ----------------------------------------------------------------------------

@REM ----------------------------------------------------------------------------
@REM Apache Maven Wrapper startup batch script, version 3.3.2
@REM ----------------------------------------------------------------------------

@REM Begin all REM://foo style comments
@REM Set local scope for the variables with windows NT shell
@IF "%OS%"=="Windows_NT" @SETLOCAL

@REM Set the current directory to the location of this script
SET WRAPPER_DIR=%~dp0

@REM Find java.exe
IF NOT "%JAVA_HOME%"=="" GOTO findJavaFromJavaHome

SET JAVACMD=java.exe
%JAVACMD% -version >NUL 2>&1
IF "%ERRORLEVEL%"=="0" GOTO init

ECHO ERROR: JAVA_HOME is not set and no 'java' command could be found in your PATH.
ECHO.
ECHO Please set the JAVA_HOME variable in your environment to match the
ECHO location of your Java installation.
GOTO error

:findJavaFromJavaHome
SET JAVA_HOME=%JAVA_HOME:"=%
SET JAVACMD=%JAVA_HOME%\bin\java.exe

IF EXIST "%JAVACMD%" GOTO init

ECHO ERROR: JAVA_HOME is set to an invalid directory: %JAVA_HOME%
ECHO.
ECHO Please set the JAVA_HOME variable in your environment to match the
ECHO location of your Java installation.
GOTO error

:init
SET WRAPPER_JAR="%WRAPPER_DIR%\.mvn\wrapper\maven-wrapper.jar"
SET WRAPPER_URL="https://repo.maven.apache.org/maven2/org/apache/maven/wrapper/maven-wrapper/3.3.2/maven-wrapper-3.3.2.jar"

@REM Download maven-wrapper.jar if needed
IF EXIST %WRAPPER_JAR% GOTO execute

@REM Use PowerShell to download
powershell -Command "(New-Object Net.WebClient).DownloadFile('%WRAPPER_URL%', '%WRAPPER_JAR%')"
IF "%ERRORLEVEL%"=="0" GOTO execute

ECHO ERROR: Could not download maven-wrapper.jar
GOTO error

:execute
"%JAVACMD%" ^
  -classpath %WRAPPER_JAR% ^
  org.apache.maven.wrapper.MavenWrapperMain ^
  %MAVEN_CONFIG% %*

IF ERRORLEVEL 1 GOTO error
GOTO end

:error
SET ERROR_CODE=1

:end
@ENDLOCAL & SET ERROR_CODE=%ERROR_CODE%

EXIT /B %ERROR_CODE%
