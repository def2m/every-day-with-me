@echo off
chcp 65001 > nul
set "PATH=%LOCALAPPDATA%\Programs\Git\cmd;%PATH%"
title 365 Gun - GitHub'a Yukle (every-day-with-me)
color 0b

echo =======================================================
echo        365 GUN - GOKYUZU GUNLUGU GITHUB YUKLEYICI
echo =======================================================
echo.
echo Hedef Depo: https://github.com/def2m/every-day-with-me.git
echo.

set "REPO_URL=https://github.com/def2m/every-day-with-me.git"

git remote remove origin > nul 2>&1
git remote add origin %REPO_URL%

echo Git commit ve dal kontrol ediliyor...
git branch -M main
git add .
git commit -m "feat: 365 Gun Gokyuzu Gunlugu - Mobil Uygulama ve GitHub APK Workflow" > nul 2>&1

echo.
echo Kodlar GitHub'a gonderiliyor...
echo (Eger tarayiciniz acilirsa lutfen 'Sign in with your browser' / Giris yap'a tiklayin)
echo.

git push -u origin main

if %ERRORLEVEL% EQU 0 (
    echo.
    echo =======================================================
    echo               BASARIYLA YUKLENDI! ?
    echo =======================================================
    echo.
    echo GitHub Actions simdi telefonunuz icin APK dosyasini derliyor!
    echo.
    echo APK'yi indirmek icin:
    echo 1. GitHub deponuza gidin: https://github.com/def2m/every-day-with-me/actions
    echo 2. "Android APK Olustur ve Yayinla" islemine tiklayin (Derleme ~2-3 dk surer).
    echo 3. Derleme tamamlandiginda "Releases" kismindan veya Actions icinden
    echo    "gun365-release.apk" dosyasini telefonunuza indirip yukleyin!
    echo.
) else (
    echo.
    echo =======================================================
    echo Bir hata veya giris istegi olustu.
    echo Eger GitHub Personal Access Token (PAT) kullanmak isterseniz:
    echo https://github.com/settings/tokens adresinden 'repo' yetkili bir token olusturup
    echo asagidaki adrese yapistirarak push edebilirsiniz.
    echo =======================================================
)

pause
