@echo off
chcp 65001 > nul
set "PATH=%LOCALAPPDATA%\Programs\Git\cmd;%PATH%"
title 365 Gun - GitHub'a Yukle ve APK Derle
color 0b

echo =======================================================
echo        365 GUN - GOKYUZU GUNLUGU GITHUB YUKLEYICI
echo =======================================================
echo.
echo Bu arac projenizi GitHub'a yukler ve GitHub Actions 
echo uzerinden telefonunuz icin APK dosyasini otomatik derler.
echo.
echo 1. github.com adresinde oturum acin.
echo 2. "New repository" (Yeni Depo) butonuna tiklayin.
echo 3. Deponuza bir isim verin (ornegin: gun365) ve Public secip Olusturun.
echo 4. Olusturulan deponun linkini kopyalayin.
echo.
set /p REPO_URL="GitHub Depo Linkinizi Buraya Yapistirin (Ornek: https://github.com/kullanici/gun365.git): "

if "%REPO_URL%"=="" (
    echo.
    echo Hata: Gecerli bir GitHub linki girmediniz!
    pause
    exit /b
)

echo.
echo Git ayarlaniyor...
git init
git branch -M main
git add .
git commit -m "365 Gun Uygulamasi - Otomatik APK Derleme Kurulumu"

git remote remove origin > nul 2>&1
git remote add origin %REPO_URL%

echo.
echo Kodlar GitHub'a gonderiliyor...
git push -u origin main

if %ERRORLEVEL% EQU 0 (
    echo.
    echo =======================================================
    echo               BASARIYLA YUKLENDI! ✨
    echo =======================================================
    echo.
    echo GitHub Actions simdi telefonunuz icin APK dosyasini derliyor!
    echo.
    echo APK'yi indirmek icin:
    echo 1. GitHub deponuza gidin: %REPO_URL%
    echo 2. "Actions" sekmesine tiklayin (Derleme ~2-3 dakika surer).
    echo 3. Islem bittiginde "Releases" kismindan veya Actions icinden
    echo    "gun365-release.apk" dosyasini telefonunuza indirip yukleyin!
    echo.
) else (
    echo.
    echo Bir hata olustu. Lutfen GitHub kullanici adi ve sifrenizi / Personal Access Token'inizi kontrol edin.
)

pause
