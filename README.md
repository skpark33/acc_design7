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
flutter config --build-dir=../release/accTest0383  

#visual code 를 재기동한다.
## flutter run -d web-server --web-renderer html
flutter run -d chrome --web-renderer html

## build and release process
flutter build web --web-renderer html --release --base-href="/accTest0383/"

## first time after create repository
cd ../release/accTest0383/web
echo "# accTest0383" >> README.md
git init
git add .
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/skpark33/accTest0383.git
git push -u origin main

# for windows configuration

flutter config --enable-windows-desktop 
flutter create --platforms=windows . 
# you need to install Xcode or VisualStudio or gcc toolchains.
flutter run -d windows
flutter build windows

#   a c c _ d e s i g n 7  
 