# acc_design7

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


####
####  When love and skil work together, expect a masterpiece
####  - John Ruskin - 
####

##
## skpark
## run way
## build directory configuration
flutter config --build-dir=../release/accTest0390  

#visual code 를 재기동한다.
## flutter run -d web-server --web-renderer html
flutter run -d chrome --web-renderer html

## build and release process
flutter build web --web-renderer html --release --base-href="/accTest0390/"

## first time after create repository
cd ../release/accTest0391/web
echo "# accTest0390" >> README.md
git init
git add .
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/skpark33/accTest0390.git
git push -u origin main

## GitHub 페이지에서 Settings 에서 GitHub pages 'click it out here' 를 누른다.
# Source choice 박스에서 main 을 고른뒤 save 를 눌러주면 웹페이지가 생기다.
# https://skpark33.github.io/accTest0390/

# for windows configuration

flutter config --enable-windows-desktop 
flutter create --platforms=windows . 
# you need to install Xcode or VisualStudio or gcc toolchains.
flutter run -d windows
flutter build windows
