@ECHO OFF
SET release=7.1.2
SET comment=
SET version=%release%

IF [%comment%] EQU [] (SET version=%release%) ELSE (SET version=%release%-%comment%)
ECHO Building Umbraco %version%

ReplaceIISExpressPortNumber.exe ..\src\Umbraco.Web.UI\Umbraco.Web.UI.csproj %release%

ECHO Installing the Microsoft.Bcl.Build package before anything else, otherwise you'd have to run build.cmd twice
SET nuGetFolder=%CD%\..\src\packages\
..\src\.nuget\NuGet.exe install ..\src\Umbraco.Web.UI\packages.config -OutputDirectory %nuGetFolder%

ECHO Removing the belle build folder to make sure everything is clean as a whistle
RD ..\src\Umbraco.Web.UI.Client\build /Q /S

ECHO Performing MSBuild and producing Umbraco binaries zip files
%windir%\Microsoft.NET\Framework\v4.0.30319\msbuild.exe "Build.proj" /p:BUILD_RELEASE=%release% /p:BUILD_COMMENT=%comment%

ECHO Adding dummy files to include in the NuGet package so that empty folders actually get created
echo This file is only here so that the containing folder will be included in the NuGet package, it is safe to delete. > .\_BuildOutput\WebApp\App_Code\dummy.txt
echo This file is only here so that the containing folder will be included in the NuGet package, it is safe to delete. > .\_BuildOutput\WebApp\App_Data\dummy.txt
echo This file is only here so that the containing folder will be included in the NuGet package, it is safe to delete. > .\_BuildOutput\WebApp\App_Plugins\dummy.txt
echo This file is only here so that the containing folder will be included in the NuGet package, it is safe to delete. > .\_BuildOutput\WebApp\css\dummy.txt
echo This file is only here so that the containing folder will be included in the NuGet package, it is safe to delete. > .\_BuildOutput\WebApp\masterpages\dummy.txt
echo This file is only here so that the containing folder will be included in the NuGet package, it is safe to delete. > .\_BuildOutput\WebApp\media\dummy.txt
echo This file is only here so that the containing folder will be included in the NuGet package, it is safe to delete. > .\_BuildOutput\WebApp\scripts\dummy.txt
echo This file is only here so that the containing folder will be included in the NuGet package, it is safe to delete. > .\_BuildOutput\WebApp\usercontrols\dummy.txt
echo This file is only here so that the containing folder will be included in the NuGet package, it is safe to delete. > .\_BuildOutput\WebApp\Views\Partials\dummy.txt
echo This file is only here so that the containing folder will be included in the NuGet package, it is safe to delete. > .\_BuildOutput\WebApp\Views\MacroPartials\dummy.txt

ECHO Adding Web.config transform files to the NuGet package
ren .\_BuildOutput\WebApp\MacroScripts\Web.config Web.config.transform
ren .\_BuildOutput\WebApp\Views\Web.config Web.config.transform
ren .\_BuildOutput\WebApp\Xslt\Web.config Web.config.transform

ECHO Packing the NuGet release files
..\src\.nuget\NuGet.exe Pack NuSpecs\UmbracoCms.Core.nuspec -Version %version%
..\src\.nuget\NuGet.exe Pack NuSpecs\UmbracoCms.Core.Symbols.nuspec -Symbols -Version %version%
..\src\.nuget\NuGet.exe Pack NuSpecs\UmbracoCms.nuspec -Version %version%
                        
IF ERRORLEVEL 1 GOTO :showerror

GOTO :EOF

:showerror
PAUSE
