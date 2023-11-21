FROM gitpod/workspace-full-vnc
SHELL ["/bin/bash", "-c"]

ENV ANDROID_HOME=/home/gitpod/androidsdk \
    FLUTTER_VERSION=2.2.3-stable
# Install Open JDK
USER root
RUN apt update \
    && apt install openjdk-11-jdk -y \
    && update-java-alternatives --set java-1.11.0-openjdk-amd64
    
# Install dart
USER root
RUN curl -fsSL https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/dart-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/dart-archive-keyring.gpg] https://storage.googleapis.com/download.dartlang.org/linux/debian stable main" | sudo tee /etc/apt/sources.list.d/dart.list > /dev/null \
    && apt update \
    && apt install -y dart

# Install flutter
USER gitpod
RUN cd /home/gitpod \
    && wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}.tar.xz \
    && tar xf flutter_linux_${FLUTTER_VERSION}.tar.xz \
    && rm flutter_linux_${FLUTTER_VERSION}.tar.xz \
    && flutter/bin/flutter precache \
    && echo 'export PATH="$PATH:/home/gitpod/flutter/bin"' >> /home/gitpod/.bashrc 

# Install SDK Manager
USER gitpod
RUN wget https://dl.google.com/android/repository/commandlinetools-linux-7302050_latest.zip \
    && mkdir -p $ANDROID_HOME/cmdline-tools/latest \
    && unzip commandlinetools-linux-*.zip -d $ANDROID_HOME \
    && rm commandlinetools-linux-*.zip \
    && mv $ANDROID_HOME/cmdline-tools/bin $ANDROID_HOME/cmdline-tools/latest \
    && mv $ANDROID_HOME/cmdline-tools/lib $ANDROID_HOME/cmdline-tools/latest \
    && echo "export ANDROID_HOME=$ANDROID_HOME" >> /home/gitpod/.bashrc \
    && echo 'export PATH=$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$ANDROID_HOME/cmdline-tools/bin:$ANDROID_HOME/platform-tools:$PATH' >> /home/gitpod/.bashrc


# Install Android Image version 30
USER gitpod
RUN yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "platform-tools" "platforms;android-30" "emulator"
RUN yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "system-images;android-30;google_apis;x86_64"
RUN echo no | $ANDROID_HOME/cmdline-tools/latest/bin/avdmanager create avd -n avd28 -k "system-images;android-30;google_apis;x86_64"


# misc deps
USER root
RUN apt-get install -y \
  libasound2-dev \
  libgtk-3-dev \
  libnss3-dev \
  fonts-noto \
  fonts-noto-cjk

# For Qt WebEngine on docker
ENV QTWEBENGINE_DISABLE_SANDBOX 1
